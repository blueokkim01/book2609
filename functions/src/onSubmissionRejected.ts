import { onDocumentUpdated } from "firebase-functions/v2/firestore";

import { notifyUser } from "./notify";
import { isNewlyRejected } from "./submissionTransitions";

/**
 * 교사가 제출물 상태를 `rejected`로 변경했을 때 발동한다.
 * 포인트/뱃지 변경은 없으며, 반려 사유를 포함한 FCM 알림만 발송한다.
 */
export const onSubmissionRejected = onDocumentUpdated(
  "submissions/{submissionId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    if (!isNewlyRejected(before.status, after.status)) return;

    const reason = (after.reviewerNote as string) || "사유가 입력되지 않았어요.";
    const bookTitle = after.bookTitle as string;

    await notifyUser({
      uid: after.userId as string,
      type: "submissionRejected",
      title: "인증이 반려되었어요",
      body: `'${bookTitle}' 인증이 반려됐어요. 사유: ${reason}`,
    });
  }
);
