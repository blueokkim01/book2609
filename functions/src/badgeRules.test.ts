import {
  BADGE_DEFINITIONS,
  POINTS_PER_APPROVED_SUBMISSION,
  computeEarnedBadgeIds,
  computeNextPoints,
  diffNewlyEarnedBadgeIds,
} from "./badgeRules";

describe("computeNextPoints", () => {
  it("승인 1건마다 정해진 포인트만큼 증가한다", () => {
    expect(computeNextPoints(0)).toBe(POINTS_PER_APPROVED_SUBMISSION);
    expect(computeNextPoints(30)).toBe(30 + POINTS_PER_APPROVED_SUBMISSION);
  });
});

describe("computeEarnedBadgeIds", () => {
  it("승인 건수가 0이면 아무 뱃지도 없다", () => {
    expect(computeEarnedBadgeIds(0)).toEqual([]);
  });

  it("임계값을 넘긴 모든 뱃지를 반환한다", () => {
    const earned = computeEarnedBadgeIds(5);
    expect(earned).toContain("first-book");
    expect(earned).toContain("five-books");
    expect(earned).not.toContain("ten-books");
  });

  it("정의된 가장 높은 임계값을 넘기면 전체 뱃지를 반환한다", () => {
    const earned = computeEarnedBadgeIds(999);
    expect(earned.length).toBe(BADGE_DEFINITIONS.length);
  });
});

describe("diffNewlyEarnedBadgeIds", () => {
  it("이미 보유한 뱃지는 다시 반환하지 않는다", () => {
    const result = diffNewlyEarnedBadgeIds(["first-book"], 5);
    expect(result).toEqual(["five-books"]);
  });

  it("새로 조건을 충족한 뱃지가 없으면 빈 배열을 반환한다", () => {
    const result = diffNewlyEarnedBadgeIds(["first-book", "five-books"], 5);
    expect(result).toEqual([]);
  });

  it("여러 뱃지를 한 번에 건너뛰어 획득해도 모두 반환한다", () => {
    const result = diffNewlyEarnedBadgeIds([], 20);
    expect(result).toEqual([
      "first-book",
      "five-books",
      "ten-books",
      "twenty-books",
    ]);
  });
});
