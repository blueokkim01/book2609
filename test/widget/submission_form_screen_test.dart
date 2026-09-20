import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/features/auth/application/auth_providers.dart';
import 'package:reading_challenge/features/auth/domain/app_user.dart';
import 'package:reading_challenge/features/auth/domain/user_role.dart';
import 'package:reading_challenge/features/challenge/application/challenge_providers.dart';
import 'package:reading_challenge/features/challenge/domain/challenge.dart';
import 'package:reading_challenge/features/challenge/domain/challenge_period.dart';
import 'package:reading_challenge/features/challenge/domain/challenge_repository.dart';
import 'package:reading_challenge/features/challenge/domain/submission_method.dart';
import 'package:reading_challenge/features/submission/application/submission_providers.dart';
import 'package:reading_challenge/features/submission/domain/quiz_answer.dart';
import 'package:reading_challenge/features/submission/domain/submission.dart';
import 'package:reading_challenge/features/submission/domain/submission_repository.dart';
import 'package:reading_challenge/features/submission/presentation/submission_form_screen.dart';

final _testChallenge = Challenge(
  id: 'challenge-1',
  teacherId: 'teacher-1',
  title: '여름방학 독서 챌린지',
  description: '방학 동안 다섯 권 읽기',
  period: ChallengePeriod(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 30)),
  ),
  schoolCode: 'SCH001',
  classCode: '3-1',
  targetBookCount: 5,
  targetBooks: const [],
  requiredMethods: const [SubmissionMethod.review],
  createdAt: DateTime.now(),
);

final _testUser = AppUser(
  uid: 'student-1',
  role: UserRole.student,
  nickname: '독서왕',
  schoolCode: 'SCH001',
  classCode: '3-1',
  points: 0,
  badgeIds: const [],
  createdAt: DateTime.now(),
);

class _FakeChallengeRepository implements ChallengeRepository {
  @override
  Future<String> createChallenge({
    required String teacherId,
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    required String schoolCode,
    required String classCode,
    required int? targetBookCount,
    required List<String> targetBooks,
    required List<SubmissionMethod> requiredMethods,
  }) =>
      throw UnimplementedError();

  @override
  Stream<Challenge?> watchChallenge(String challengeId) =>
      Stream.value(_testChallenge);

  @override
  Stream<List<Challenge>> watchChallengesForClass({
    required String schoolCode,
    required String classCode,
  }) =>
      throw UnimplementedError();

  @override
  Stream<List<Challenge>> watchChallengesForTeacher(String teacherId) =>
      throw UnimplementedError();
}

class _FakeSubmissionRepository implements SubmissionRepository {
  @override
  Future<String> createSubmission({
    required String userId,
    required String challengeId,
    required String bookTitle,
    required Uint8List photoBytes,
    required String photoFileName,
    String? reviewText,
    List<QuizAnswer>? quizAnswers,
  }) =>
      throw UnimplementedError('이 위젯 테스트는 실제 제출을 수행하지 않는다');

  @override
  Future<void> approve(String submissionId) => throw UnimplementedError();

  @override
  Future<void> reject(String submissionId, {required String reason}) =>
      throw UnimplementedError();

  @override
  Stream<List<Submission>> watchPendingSubmissionsForChallenges(
    List<String> challengeIds,
  ) =>
      throw UnimplementedError();

  @override
  Stream<List<Submission>> watchSubmissionsForChallenge(String challengeId) =>
      throw UnimplementedError();

  @override
  Stream<List<Submission>> watchSubmissionsForStudent(String userId) =>
      throw UnimplementedError();
}

void main() {
  testWidgets('사진 필수 안내, 책 제목 입력란, 챌린지가 요구하는 독후감 입력란이 보인다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(_FakeChallengeRepository()),
          submissionRepositoryProvider
              .overrideWithValue(_FakeSubmissionRepository()),
          currentUserProvider.overrideWith((ref) => Stream.value(_testUser)),
        ],
        child: const MaterialApp(
          home: SubmissionFormScreen(challengeId: 'challenge-1'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('책 표지/페이지 사진 촬영 (필수)'), findsOneWidget);
    expect(find.text('책 제목'), findsOneWidget);
    // 챌린지가 review를 요구하므로 독후감 입력란이 나타나야 한다.
    expect(find.text('독후감 / 한줄평'), findsOneWidget);
    // quiz는 요구하지 않으므로 퀴즈 섹션은 없어야 한다.
    expect(find.text('퀴즈 (OX 또는 객관식)'), findsNothing);
  });

  testWidgets('사진 없이 제출하면 안내 스낵바가 뜨고 실제 제출은 호출되지 않는다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(_FakeChallengeRepository()),
          submissionRepositoryProvider
              .overrideWithValue(_FakeSubmissionRepository()),
          currentUserProvider.overrideWith((ref) => Stream.value(_testUser)),
        ],
        child: const MaterialApp(
          home: SubmissionFormScreen(challengeId: 'challenge-1'),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextFormField, '책 제목'), '어린왕자');
    await tester.tap(find.text('제출하기'));
    await tester.pump();

    expect(find.text('책 표지/페이지 사진을 첨부해주세요'), findsOneWidget);
  });
}
