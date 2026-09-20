import { db, messaging } from "./admin";
import { logger } from "firebase-functions/v2";

export type NotificationType =
  | "submissionApproved"
  | "submissionRejected"
  | "challengeDeadline";

/**
 * 특정 사용자에게 FCM 푸시를 보내고, 동일한 내용을 인앱 알림 이력
 * (`users/{uid}/notifications`)에도 기록한다.
 *
 * 두 동작(FCM 발송, 이력 기록)은 서로 독립적으로 최선을 다해(best-effort)
 * 수행한다 — 만료된 토큰 때문에 인앱 알림 기록까지 실패해서는 안 된다.
 */
export async function notifyUser(params: {
  uid: string;
  type: NotificationType;
  title: string;
  body: string;
}): Promise<void> {
  const { uid, type, title, body } = params;

  await db.collection("users").doc(uid).collection("notifications").add({
    type,
    title,
    body,
    read: false,
    createdAt: new Date(),
  });

  const tokensSnapshot = await db
    .collection("users")
    .doc(uid)
    .collection("fcmTokens")
    .get();

  if (tokensSnapshot.empty) return;

  const tokens = tokensSnapshot.docs.map((doc) => doc.id);

  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: { type },
  });

  const staleTokens: string[] = [];
  response.responses.forEach((result, index) => {
    if (
      !result.success &&
      (result.error?.code === "messaging/registration-token-not-registered" ||
        result.error?.code === "messaging/invalid-registration-token")
    ) {
      staleTokens.push(tokens[index]);
    }
  });

  if (staleTokens.length > 0) {
    logger.info(`만료된 FCM 토큰 ${staleTokens.length}개 정리`, { uid });
    await Promise.all(
      staleTokens.map((token) =>
        db
          .collection("users")
          .doc(uid)
          .collection("fcmTokens")
          .doc(token)
          .delete()
      )
    );
  }
}
