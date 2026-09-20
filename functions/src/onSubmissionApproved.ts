import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { db } from "./admin";
import {
  computeNextPoints,
  diffNewlyEarnedBadgeIds,
} from "./badgeRules";
import { notifyUser } from "./notify";
import { isNewlyApproved } from "./submissionTransitions";

/**
 * 교사가 제출물 상태를 `approved`로 변경했을 때 발동한다.
 *
 * ⚠️ 이 함수가 `users/{uid}.points`와 `users/{uid}.badgeIds`를 갱신하는
 * 유일한 경로다. Firestore 보안 규칙은 클라이언트가 이 두 필드를 직접
 * 쓰지 못하도록 막고 있으므로, 포인트·뱃지는 항상 여기서 트랜잭션으로만
 * 갱신된다(동시에 여러 제출물이 승인되어도 정합성이 깨지지 않도록).
 */
export const onSubmissionApproved = onDocumentUpdated(
  "submissions/{submissionId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    if (!isNewlyApproved(before.status, after.status)) return;

    const userId = after.userId as string;
    const userRef = db.collection("users").doc(userId);

    const result = await db.runTransaction(async (tx) => {
      const userSnap = await tx.get(userRef);
      if (!userSnap.exists) {
        logger.error("승인 처리 대상 사용자를 찾을 수 없습니다.", { userId });
        return null;
      }
      const user = userSnap.data()!;

      const currentPoints = (user.points as number) ?? 0;
      const currentBadgeIds = (user.badgeIds as string[]) ?? [];
      const currentApprovedCount = (user.approvedSubmissionCount as number) ?? 0;

      const nextApprovedCount = currentApprovedCount + 1;
      const nextPoints = computeNextPoints(currentPoints);
      const newlyEarnedBadgeIds = diffNewlyEarnedBadgeIds(
        currentBadgeIds,
        nextApprovedCount
      );
      const nextBadgeIds = [...currentBadgeIds, ...newlyEarnedBadgeIds];

      tx.update(userRef, {
        points: nextPoints,
        badgeIds: nextBadgeIds,
        approvedSubmissionCount: nextApprovedCount,
      });

      // 학급 리더보드 갱신(학급 단위 랭킹 표시용 비정규화 문서).
      const leaderboardId = `${user.schoolCode}_${user.classCode}`;
      const leaderboardEntryRef = db
        .collection("leaderboards")
        .doc(leaderboardId)
        .collection("entries")
        .doc(userId);
      tx.set(
        leaderboardEntryRef,
        {
          nickname: user.nickname,
          points: nextPoints,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      return {
        nextPoints,
        newlyEarnedBadgeIds,
        bookTitle: after.bookTitle as string,
      };
    });

    if (!result) return;

    const badgeSuffix =
      result.newlyEarnedBadgeIds.length > 0
        ? ` 새 뱃지도 ${result.newlyEarnedBadgeIds.length}개 획득했어요!`
        : "";

    await notifyUser({
      uid: userId,
      type: "submissionApproved",
      title: "인증이 승인되었어요 🎉",
      body: `'${result.bookTitle}' 독서 인증이 승인되어 포인트가 적립됐어요.${badgeSuffix}`,
    });
  }
);
