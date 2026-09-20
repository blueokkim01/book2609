/**
 * 포인트 적립량과 뱃지 부여 기준을 정의하는 유일한 권위(authoritative) 소스.
 *
 * ⚠️ 이 파일의 값이 실제로 사용자에게 지급되는 포인트/뱃지를 결정한다.
 * 클라이언트(Flutter)에는 이 로직이 존재하지 않으며, `onSubmissionApproved`
 * Cloud Function만이 여기 정의된 규칙으로 `users/{uid}` 문서를 갱신한다.
 */

/** 제출물 1건이 승인될 때마다 지급되는 포인트. */
export const POINTS_PER_APPROVED_SUBMISSION = 10;

export interface BadgeDefinition {
  id: string;
  name: string;
  description: string;
  iconName: string;
  criteriaDescription: string;
  /** 이 뱃지를 획득하기 위해 필요한 누적 승인 제출 건수. */
  requiredApprovedCount: number;
}

/**
 * 뱃지 카탈로그. `badges/{id}` Firestore 문서와 id가 일치해야 하며,
 * 배포 스크립트가 이 배열을 `badges` 컬렉션에 seed한다.
 */
export const BADGE_DEFINITIONS: BadgeDefinition[] = [
  {
    id: "first-book",
    name: "첫 발걸음",
    description: "첫 독서 인증을 완료했어요!",
    iconName: "menu_book",
    criteriaDescription: "1권 완독 시 획득",
    requiredApprovedCount: 1,
  },
  {
    id: "five-books",
    name: "꾸준한 독서가",
    description: "다섯 권의 책을 완독했어요!",
    iconName: "local_fire_department",
    criteriaDescription: "5권 완독 시 획득",
    requiredApprovedCount: 5,
  },
  {
    id: "ten-books",
    name: "책벌레",
    description: "열 권의 책을 완독했어요!",
    iconName: "star",
    criteriaDescription: "10권 완독 시 획득",
    requiredApprovedCount: 10,
  },
  {
    id: "twenty-books",
    name: "독서왕",
    description: "스무 권의 책을 완독했어요!",
    iconName: "emoji_events",
    criteriaDescription: "20권 완독 시 획득",
    requiredApprovedCount: 20,
  },
];

/**
 * 누적 승인 제출 건수를 기준으로 이 시점까지 획득했어야 하는 모든 뱃지 id를
 * 계산한다. 이미 보유한 뱃지 목록과의 비교(diff)는 호출부에서 수행한다.
 */
export function computeEarnedBadgeIds(approvedCount: number): string[] {
  return BADGE_DEFINITIONS.filter(
    (badge) => approvedCount >= badge.requiredApprovedCount
  ).map((badge) => badge.id);
}

/**
 * 기존 뱃지 목록과 새로 계산된 뱃지 목록을 비교해 이번에 "새로" 획득한
 * 뱃지 id만 반환한다(중복 알림 방지 등에 사용).
 */
export function diffNewlyEarnedBadgeIds(
  previousBadgeIds: string[],
  approvedCount: number
): string[] {
  const earned = computeEarnedBadgeIds(approvedCount);
  return earned.filter((id) => !previousBadgeIds.includes(id));
}

/** 승인 1건 처리 후 사용자의 새 포인트 총합을 계산한다. */
export function computeNextPoints(currentPoints: number): number {
  return currentPoints + POINTS_PER_APPROVED_SUBMISSION;
}
