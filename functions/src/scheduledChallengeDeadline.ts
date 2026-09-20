import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";
import { Timestamp } from "firebase-admin/firestore";

import { db } from "./admin";
import { notifyUser } from "./notify";

const DEADLINE_WINDOW_HOURS = 24;

/**
 * 매시간 실행되어 마감이 24시간 이내로 임박한 챌린지를 찾아 해당 학급
 * 학생 전원에게 알림을 보낸다. 중복 발송을 막기 위해 챌린지 문서에
 * `deadlineNotifiedAt`을 기록해두고, 이미 값이 있으면 건너뛴다.
 */
export const scheduledChallengeDeadline = onSchedule(
  { schedule: "every 60 minutes", timeZone: "Asia/Seoul" },
  async () => {
    const now = Timestamp.now();
    const windowEnd = Timestamp.fromMillis(
      now.toMillis() + DEADLINE_WINDOW_HOURS * 60 * 60 * 1000
    );

    const challengesSnap = await db
      .collection("challenges")
      .where("period.end", ">=", now)
      .where("period.end", "<=", windowEnd)
      .get();

    for (const challengeDoc of challengesSnap.docs) {
      const challenge = challengeDoc.data();
      if (challenge.deadlineNotifiedAt) continue;

      const studentsSnap = await db
        .collection("users")
        .where("role", "==", "student")
        .where("schoolCode", "==", challenge.schoolCode)
        .where("classCode", "==", challenge.classCode)
        .get();

      logger.info(
        `챌린지 '${challenge.title}' 마감 임박 알림 대상 학생 ${studentsSnap.size}명`
      );

      await Promise.all(
        studentsSnap.docs.map((studentDoc) =>
          notifyUser({
            uid: studentDoc.id,
            type: "challengeDeadline",
            title: "챌린지 마감이 얼마 안 남았어요",
            body: `'${challenge.title}' 챌린지가 곧 마감돼요. 서둘러 인증을 제출해주세요!`,
          })
        )
      );

      await challengeDoc.ref.update({
        deadlineNotifiedAt: Timestamp.now(),
      });
    }
  }
);
