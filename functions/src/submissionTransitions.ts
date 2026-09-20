/**
 * 제출물 상태 전이 판별 로직. Firestore 트리거의 before/after 스냅샷에서
 * 실제로 "새로 승인/반려된" 이벤트인지 순수 함수로 판별해, 중복 실행이나
 * 이미 처리된 상태 재적용을 방지한다.
 */

export type SubmissionStatus = "pending" | "approved" | "rejected";

export function isNewlyApproved(
  beforeStatus: SubmissionStatus,
  afterStatus: SubmissionStatus
): boolean {
  return beforeStatus !== "approved" && afterStatus === "approved";
}

export function isNewlyRejected(
  beforeStatus: SubmissionStatus,
  afterStatus: SubmissionStatus
): boolean {
  return beforeStatus !== "rejected" && afterStatus === "rejected";
}
