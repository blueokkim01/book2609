import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reading_challenge/features/auth/data/auth_repository_impl.dart';
import 'package:reading_challenge/features/auth/domain/user_role.dart';
import 'package:reading_challenge/features/challenge/data/challenge_repository_impl.dart';
import 'package:reading_challenge/features/challenge/domain/submission_method.dart';
import 'package:reading_challenge/features/submission/data/submission_repository_impl.dart';
import 'package:reading_challenge/features/submission/domain/submission_status.dart';
import 'package:reading_challenge/firebase_options.dart';

/// 학생 제출 → 교사 승인 → 포인트/뱃지 반영 → 알림 발송까지의 전체 플로우 e2e 테스트.
///
/// ⚠️ 실행 전제:
///   1. `firebase emulators:start --only auth,firestore,storage,functions`로
///      로컬 에뮬레이터 스위트가 떠 있어야 한다(functions는 `cd functions &&
///      npm run build` 후 시작).
///   2. 연결 가능한 디바이스가 필요하다(예: `flutter test integration_test
///      -d linux` 또는 CI의 Android/iOS 에뮬레이터, 웹의 경우 chromedriver).
///
/// 이 테스트는 UI를 조작하지 않고 각 계층의 Repository를 실제 앱과 동일한
/// 구현으로 직접 구동해, "제출 승인 시 서버가 포인트/뱃지/알림을 갱신한다"는
/// 요구사항의 서버 권위 동작을 엔드투엔드로 검증한다.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const emulatorHost = 'localhost';

  late FirebaseFirestore firestore;
  late FirebaseAuth auth;

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;

    await auth.useAuthEmulator(emulatorHost, 9099);
    firestore.useFirestoreEmulator(emulatorHost, 8080);
    await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
  });

  testWidgets('학생 제출이 승인되면 포인트가 적립되고 뱃지·알림이 생긴다', (tester) async {
    final authRepository = AuthRepositoryImpl(firebaseAuth: auth, firestore: firestore);
    final challengeRepository = ChallengeRepositoryImpl(firestore: firestore);
    final submissionRepository = SubmissionRepositoryImpl(firestore: firestore);

    final unique = DateTime.now().millisecondsSinceEpoch;
    const schoolCode = 'E2E-SCHOOL';
    const classCode = 'E2E-CLASS';

    // 1) 교사·학생 가입.
    final teacher = await authRepository.signUp(
      email: 'teacher-$unique@example.com',
      password: 'password123',
      role: UserRole.teacher,
      nickname: '테스트교사',
      schoolCode: schoolCode,
      classCode: classCode,
    );

    await auth.signOut();

    final student = await authRepository.signUp(
      email: 'student-$unique@example.com',
      password: 'password123',
      role: UserRole.student,
      nickname: '테스트학생',
      schoolCode: schoolCode,
      classCode: classCode,
    );

    expect(student.points, 0);
    expect(student.badgeIds, isEmpty);

    // 2) 교사로 재로그인해 챌린지 생성.
    await auth.signOut();
    await auth.signInWithEmailAndPassword(
      email: 'teacher-$unique@example.com',
      password: 'password123',
    );

    final challengeId = await challengeRepository.createChallenge(
      teacherId: teacher.uid,
      title: 'E2E 테스트 챌린지',
      description: '',
      start: DateTime.now().subtract(const Duration(days: 1)),
      end: DateTime.now().add(const Duration(days: 7)),
      schoolCode: schoolCode,
      classCode: classCode,
      targetBookCount: 1,
      targetBooks: const [],
      requiredMethods: const [SubmissionMethod.review],
    );

    // 3) 학생으로 재로그인해 인증 제출.
    await auth.signOut();
    await auth.signInWithEmailAndPassword(
      email: 'student-$unique@example.com',
      password: 'password123',
    );

    final submissionId = await submissionRepository.createSubmission(
      userId: student.uid,
      challengeId: challengeId,
      bookTitle: '어린왕자',
      photoBytes: Uint8List.fromList(List.filled(100, 0xff)),
      photoFileName: 'photo.jpg',
      reviewText: 'E2E 테스트로 작성한 독후감입니다. 정말 감동적이었어요.',
    );

    // 4) 교사로 재로그인해 승인.
    await auth.signOut();
    await auth.signInWithEmailAndPassword(
      email: 'teacher-$unique@example.com',
      password: 'password123',
    );

    await submissionRepository.approve(submissionId);

    // 5) 승인 직후 submissions 문서 상태가 approved로 바뀌었는지 확인.
    final submissionDoc =
        await firestore.doc('submissions/$submissionId').get();
    expect(submissionDoc.data()!['status'], SubmissionStatus.approved.firestoreValue);

    // 6) Cloud Functions(onSubmissionApproved)가 트랜잭션으로 포인트/뱃지를
    //    갱신할 때까지 폴링한다(비동기 트리거이므로 즉시 반영되지 않을 수 있음).
    Map<String, dynamic>? userData;
    for (var attempt = 0; attempt < 20; attempt++) {
      final doc = await firestore.doc('users/${student.uid}').get();
      userData = doc.data();
      if ((userData?['points'] as int? ?? 0) > 0) break;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    expect(userData, isNotNull);
    expect(userData!['points'], greaterThan(0));
    expect(
      List<String>.from(userData['badgeIds'] as List? ?? []),
      contains('first-book'),
    );

    // 7) 승인 알림이 인앱 알림 이력에도 기록됐는지 확인.
    final notifications = await firestore
        .collection('users/${student.uid}/notifications')
        .where('type', isEqualTo: 'submissionApproved')
        .get();
    expect(notifications.docs, isNotEmpty);
  });
}
