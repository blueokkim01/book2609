import * as fs from "fs";
import * as path from "path";
import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { getDownloadURL, ref, uploadBytes } from "firebase/storage";

/**
 * storage.rules에 대한 역할별 read/write 권한 테스트.
 * `firebase emulators:exec --only firestore,storage ...`로 감싸 실행한다.
 * (storage.rules가 firestore.get()으로 교사-학생 관계를 조회하므로 두
 * 에뮬레이터가 모두 필요하다.)
 */
describe("storage.rules", () => {
  let testEnv: RulesTestEnvironment;

  const TEACHER_UID = "teacher-1";
  const STUDENT_UID = "student-1";
  const OTHER_TEACHER_UID = "teacher-2";
  const SCHOOL = "SCH001";
  const CLASS = "3-1";

  const smallJpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]); // 4 bytes

  beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: "demo-reading-challenge",
      storage: {
        rules: fs.readFileSync(
          path.resolve(__dirname, "../storage.rules"),
          "utf8"
        ),
      },
      firestore: {
        rules:
          "service cloud.firestore { match /databases/{db}/documents { match /{document=**} { allow read, write: if true; } } }",
      },
    });

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await db.doc(`users/${TEACHER_UID}`).set({
        role: "teacher",
        schoolCode: SCHOOL,
        classCode: CLASS,
      });
      await db.doc(`users/${OTHER_TEACHER_UID}`).set({
        role: "teacher",
        schoolCode: SCHOOL,
        classCode: "9-9",
      });
      await db.doc(`users/${STUDENT_UID}`).set({
        role: "student",
        schoolCode: SCHOOL,
        classCode: CLASS,
      });
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  const photoPath = `submission_photos/${STUDENT_UID}/submission-1/photo.jpg`;

  it("학생 본인은 자신의 인증 사진을 업로드할 수 있다", async () => {
    const student = testEnv.authenticatedContext(STUDENT_UID);
    await assertSucceeds(
      uploadBytes(ref(student.storage(), photoPath), smallJpeg, {
        contentType: "image/jpeg",
      })
    );
  });

  it("다른 학생은 남의 사진 경로에 업로드할 수 없다", async () => {
    const otherStudent = testEnv.authenticatedContext("student-2");
    await assertFails(
      uploadBytes(ref(otherStudent.storage(), photoPath), smallJpeg, {
        contentType: "image/jpeg",
      })
    );
  });

  it("5MB를 초과하는 파일은 업로드할 수 없다", async () => {
    const student = testEnv.authenticatedContext(STUDENT_UID);
    const oversized = new Uint8Array(6 * 1024 * 1024);
    await assertFails(
      uploadBytes(ref(student.storage(), photoPath), oversized, {
        contentType: "image/jpeg",
      })
    );
  });

  it("이미지가 아닌 파일 타입은 업로드할 수 없다", async () => {
    const student = testEnv.authenticatedContext(STUDENT_UID);
    await assertFails(
      uploadBytes(ref(student.storage(), photoPath), smallJpeg, {
        contentType: "application/pdf",
      })
    );
  });

  it("본인은 자신의 사진을 읽을 수 있다", async () => {
    const student = testEnv.authenticatedContext(STUDENT_UID);
    await uploadBytes(ref(student.storage(), photoPath), smallJpeg, {
      contentType: "image/jpeg",
    });
    await assertSucceeds(getDownloadURL(ref(student.storage(), photoPath)));
  });

  it("같은 학급 담당 교사는 학생 사진을 읽을 수 있다", async () => {
    const student = testEnv.authenticatedContext(STUDENT_UID);
    await uploadBytes(ref(student.storage(), photoPath), smallJpeg, {
      contentType: "image/jpeg",
    });
    const teacher = testEnv.authenticatedContext(TEACHER_UID);
    await assertSucceeds(getDownloadURL(ref(teacher.storage(), photoPath)));
  });

  it("⚠️ 다른 학급 교사는 학생 사진을 읽을 수 없다", async () => {
    const student = testEnv.authenticatedContext(STUDENT_UID);
    await uploadBytes(ref(student.storage(), photoPath), smallJpeg, {
      contentType: "image/jpeg",
    });
    const otherTeacher = testEnv.authenticatedContext(OTHER_TEACHER_UID);
    await assertFails(
      getDownloadURL(ref(otherTeacher.storage(), photoPath))
    );
  });

  it("로그인하지 않은 사용자는 읽을 수 없다", async () => {
    const student = testEnv.authenticatedContext(STUDENT_UID);
    await uploadBytes(ref(student.storage(), photoPath), smallJpeg, {
      contentType: "image/jpeg",
    });
    const anonymous = testEnv.unauthenticatedContext();
    await assertFails(getDownloadURL(ref(anonymous.storage(), photoPath)));
  });
});
