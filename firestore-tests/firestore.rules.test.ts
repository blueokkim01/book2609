import * as fs from "fs";
import * as path from "path";
import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";

/**
 * firestore.rules에 대한 역할별 read/write 권한 테스트.
 *
 * 실행 전제: `firebase emulators:exec --only firestore ...`로 감싸 실행되어야
 * 하며(package.json의 `test` 스크립트 참고), FIRESTORE_EMULATOR_HOST 환경
 * 변수를 에뮬레이터가 자동으로 주입한다.
 */
describe("firestore.rules", () => {
  let testEnv: RulesTestEnvironment;

  const TEACHER_UID = "teacher-1";
  const STUDENT_UID = "student-1";
  const OTHER_STUDENT_UID = "student-2";
  const PARENT_UID = "parent-1";
  const SCHOOL = "SCH001";
  const CLASS = "3-1";

  beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: "demo-reading-challenge",
      firestore: {
        rules: fs.readFileSync(
          path.resolve(__dirname, "../firestore.rules"),
          "utf8"
        ),
      },
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  afterEach(async () => {
    await testEnv.clearFirestore();
  });

  /** 규칙을 우회해 초기 상태(사용자/챌린지/제출물 등)를 만든다. */
  async function seed() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await db.doc(`users/${TEACHER_UID}`).set({
        role: "teacher",
        nickname: "김선생",
        schoolCode: SCHOOL,
        classCode: CLASS,
        points: 0,
        badgeIds: [],
      });
      await db.doc(`users/${STUDENT_UID}`).set({
        role: "student",
        nickname: "독서왕",
        schoolCode: SCHOOL,
        classCode: CLASS,
        points: 0,
        badgeIds: [],
      });
      await db.doc(`users/${OTHER_STUDENT_UID}`).set({
        role: "student",
        nickname: "다른학급",
        schoolCode: SCHOOL,
        classCode: "9-9",
        points: 0,
        badgeIds: [],
      });
      await db.doc(`users/${PARENT_UID}`).set({
        role: "parent",
        nickname: "학부모",
        schoolCode: "",
        classCode: "",
        points: 0,
        badgeIds: [],
      });
      await db.doc("challenges/challenge-1").set({
        teacherId: TEACHER_UID,
        title: "여름방학 독서 챌린지",
        description: "",
        period: { start: new Date(), end: new Date() },
        schoolCode: SCHOOL,
        classCode: CLASS,
        targetBookCount: 5,
        targetBooks: [],
        requiredMethods: ["review"],
      });
      await db.doc("submissions/submission-1").set({
        userId: STUDENT_UID,
        challengeId: "challenge-1",
        bookTitle: "어린왕자",
        photoUrl: "https://example.com/photo.jpg",
        reviewText: "정말 감동적이었어요.",
        status: "pending",
        submittedAt: new Date(),
      });
    });
  }

  describe("users 컬렉션", () => {
    it("본인은 자신의 프로필을 읽을 수 있다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertSucceeds(
        student.firestore().doc(`users/${STUDENT_UID}`).get()
      );
    });

    it("같은 학급 교사는 학생 프로필을 읽을 수 있다", async () => {
      await seed();
      const teacher = testEnv.authenticatedContext(TEACHER_UID);
      await assertSucceeds(
        teacher.firestore().doc(`users/${STUDENT_UID}`).get()
      );
    });

    it("다른 학급 교사(같은 학교, 다른 반 학생)는 읽을 수 없다", async () => {
      await seed();
      const teacher = testEnv.authenticatedContext(TEACHER_UID);
      await assertFails(
        teacher.firestore().doc(`users/${OTHER_STUDENT_UID}`).get()
      );
    });

    it("연결되지 않은 학부모는 학생 프로필을 읽을 수 없다", async () => {
      await seed();
      const parent = testEnv.authenticatedContext(PARENT_UID);
      await assertFails(
        parent.firestore().doc(`users/${STUDENT_UID}`).get()
      );
    });

    it("동의된 guardianLinks가 있으면 학부모가 학생 프로필을 읽을 수 있다", async () => {
      await seed();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context
          .firestore()
          .doc(`guardianLinks/${PARENT_UID}_${STUDENT_UID}`)
          .set({
            parentUid: PARENT_UID,
            studentUid: STUDENT_UID,
            consentAt: new Date(),
            consentBy: "보호자",
          });
      });
      const parent = testEnv.authenticatedContext(PARENT_UID);
      await assertSucceeds(
        parent.firestore().doc(`users/${STUDENT_UID}`).get()
      );
    });

    it("⚠️ 학생은 자신의 points 필드를 직접 수정할 수 없다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertFails(
        student
          .firestore()
          .doc(`users/${STUDENT_UID}`)
          .update({ points: 999999 })
      );
    });

    it("⚠️ 학생은 자신의 badgeIds 필드를 직접 수정할 수 없다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertFails(
        student
          .firestore()
          .doc(`users/${STUDENT_UID}`)
          .update({ badgeIds: ["ten-books"] })
      );
    });

    it("닉네임 등 일반 필드 수정은 허용된다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertSucceeds(
        student
          .firestore()
          .doc(`users/${STUDENT_UID}`)
          .update({ nickname: "새로운닉네임" })
      );
    });

    it("⚠️ 가입 시 points/badgeIds를 기본값이 아닌 값으로 생성할 수 없다", async () => {
      const db = testEnv.authenticatedContext("cheater-student").firestore();
      await assertFails(
        db.doc("users/cheater-student").set({
          role: "student",
          nickname: "치트유저",
          schoolCode: SCHOOL,
          classCode: CLASS,
          points: 500,
          badgeIds: ["ten-books"],
        })
      );
    });

    it("가입 시 points/badgeIds가 기본값(0, [])이면 생성이 허용된다", async () => {
      const db = testEnv.authenticatedContext("new-student").firestore();
      await assertSucceeds(
        db.doc("users/new-student").set({
          role: "student",
          nickname: "정상유저",
          schoolCode: SCHOOL,
          classCode: CLASS,
          points: 0,
          badgeIds: [],
        })
      );
    });
  });

  describe("challenges 컬렉션", () => {
    it("교사는 자신의 학급으로 챌린지를 생성할 수 있다", async () => {
      await seed();
      const teacher = testEnv.authenticatedContext(TEACHER_UID);
      await assertSucceeds(
        teacher
          .firestore()
          .collection("challenges")
          .add({
            teacherId: TEACHER_UID,
            title: "새 챌린지",
            description: "",
            period: { start: new Date(), end: new Date() },
            schoolCode: SCHOOL,
            classCode: CLASS,
            targetBookCount: 3,
            targetBooks: [],
            requiredMethods: ["quiz"],
          })
      );
    });

    it("학생은 챌린지를 생성할 수 없다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertFails(
        student
          .firestore()
          .collection("challenges")
          .add({
            teacherId: STUDENT_UID,
            title: "학생이 만든 챌린지",
            description: "",
            period: { start: new Date(), end: new Date() },
            schoolCode: SCHOOL,
            classCode: CLASS,
            targetBookCount: 3,
            targetBooks: [],
            requiredMethods: ["quiz"],
          })
      );
    });

    it("같은 학급 학생은 챌린지를 읽을 수 있다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertSucceeds(
        student.firestore().doc("challenges/challenge-1").get()
      );
    });
  });

  describe("submissions 컬렉션", () => {
    it("학생은 독후감을 포함한 pending 제출물을 생성할 수 있다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertSucceeds(
        student
          .firestore()
          .collection("submissions")
          .add({
            userId: STUDENT_UID,
            challengeId: "challenge-1",
            bookTitle: "데미안",
            photoUrl: "https://example.com/photo2.jpg",
            reviewText: "성장에 대한 이야기였어요.",
            status: "pending",
            submittedAt: new Date(),
          })
      );
    });

    it("⚠️ 학생은 상태를 approved로 직접 생성할 수 없다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertFails(
        student
          .firestore()
          .collection("submissions")
          .add({
            userId: STUDENT_UID,
            challengeId: "challenge-1",
            bookTitle: "데미안",
            photoUrl: "https://example.com/photo2.jpg",
            reviewText: "성장에 대한 이야기였어요.",
            status: "approved",
            submittedAt: new Date(),
          })
      );
    });

    it("독후감도 퀴즈도 없는 제출물은 생성할 수 없다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertFails(
        student
          .firestore()
          .collection("submissions")
          .add({
            userId: STUDENT_UID,
            challengeId: "challenge-1",
            bookTitle: "데미안",
            photoUrl: "https://example.com/photo2.jpg",
            status: "pending",
            submittedAt: new Date(),
          })
      );
    });

    it("담당 교사는 pending 제출물을 approved로 전이시킬 수 있다", async () => {
      await seed();
      const teacher = testEnv.authenticatedContext(TEACHER_UID);
      await assertSucceeds(
        teacher
          .firestore()
          .doc("submissions/submission-1")
          .update({ status: "approved", reviewedAt: new Date() })
      );
    });

    it("학생 본인은 자신의 제출물을 승인 처리할 수 없다", async () => {
      await seed();
      const student = testEnv.authenticatedContext(STUDENT_UID);
      await assertFails(
        student
          .firestore()
          .doc("submissions/submission-1")
          .update({ status: "approved" })
      );
    });

    it("⚠️ 교사도 승인 시 제출물의 points 관련 필드를 바꿀 수 없다(그런 필드 자체가 submissions에는 없음: bookTitle 변조 차단으로 대체 검증)", async () => {
      await seed();
      const teacher = testEnv.authenticatedContext(TEACHER_UID);
      await assertFails(
        teacher
          .firestore()
          .doc("submissions/submission-1")
          .update({ status: "approved", bookTitle: "다른 책으로 바꿔치기" })
      );
    });
  });
});
