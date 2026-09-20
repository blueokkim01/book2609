import { isNewlyApproved, isNewlyRejected } from "./submissionTransitions";

describe("isNewlyApproved", () => {
  it("pending -> approved는 새 승인이다", () => {
    expect(isNewlyApproved("pending", "approved")).toBe(true);
  });
  it("rejected -> approved(재승인)도 새 승인으로 취급한다", () => {
    expect(isNewlyApproved("rejected", "approved")).toBe(true);
  });
  it("approved -> approved(중복 이벤트)는 새 승인이 아니다", () => {
    expect(isNewlyApproved("approved", "approved")).toBe(false);
  });
  it("approved가 아닌 상태로의 전이는 새 승인이 아니다", () => {
    expect(isNewlyApproved("pending", "rejected")).toBe(false);
  });
});

describe("isNewlyRejected", () => {
  it("pending -> rejected는 새 반려다", () => {
    expect(isNewlyRejected("pending", "rejected")).toBe(true);
  });
  it("rejected -> rejected(중복 이벤트)는 새 반려가 아니다", () => {
    expect(isNewlyRejected("rejected", "rejected")).toBe(false);
  });
});
