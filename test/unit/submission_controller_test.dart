import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/features/submission/application/submission_controller.dart';
import 'package:reading_challenge/features/submission/domain/quiz_answer.dart';
import 'package:reading_challenge/features/submission/domain/submission.dart';
import 'package:reading_challenge/features/submission/domain/submission_repository.dart';

class _FakeSubmissionRepository implements SubmissionRepository {
  bool createCalled = false;

  @override
  Future<String> createSubmission({
    required String userId,
    required String challengeId,
    required String bookTitle,
    required Uint8List photoBytes,
    required String photoFileName,
    String? reviewText,
    List<QuizAnswer>? quizAnswers,
  }) async {
    createCalled = true;
    return 'fake-submission-id';
  }

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
  group('SubmissionController.submit 검증(요구사항 3: 사진 + 독후감/퀴즈 중 1개 이상)', () {
    late _FakeSubmissionRepository repository;
    late SubmissionController controller;

    setUp(() {
      repository = _FakeSubmissionRepository();
      controller = SubmissionController(repository);
    });

    test('독후감도 퀴즈도 없으면 에러 상태가 되고 repository를 호출하지 않는다', () async {
      await controller.submit(
        userId: 'u1',
        challengeId: 'c1',
        bookTitle: '어린왕자',
        photoBytes: Uint8List(10),
        photoFileName: 'photo.jpg',
      );

      expect(controller.state.hasError, isTrue);
      expect(repository.createCalled, isFalse);
    });

    test('독후감이 너무 짧으면 에러 상태가 된다', () async {
      await controller.submit(
        userId: 'u1',
        challengeId: 'c1',
        bookTitle: '어린왕자',
        photoBytes: Uint8List(10),
        photoFileName: 'photo.jpg',
        reviewText: '좋아요',
      );

      expect(controller.state.hasError, isTrue);
      expect(repository.createCalled, isFalse);
    });

    test('독후감에 금칙어가 있으면 에러 상태가 된다', () async {
      await controller.submit(
        userId: 'u1',
        challengeId: 'c1',
        bookTitle: '어린왕자',
        photoBytes: Uint8List(10),
        photoFileName: 'photo.jpg',
        reviewText: '이 책 진짜 바보 같아요 별로였어요',
      );

      expect(controller.state.hasError, isTrue);
      expect(repository.createCalled, isFalse);
    });

    test('유효한 독후감이 있으면 제출이 성공한다', () async {
      await controller.submit(
        userId: 'u1',
        challengeId: 'c1',
        bookTitle: '어린왕자',
        photoBytes: Uint8List(10),
        photoFileName: 'photo.jpg',
        reviewText: '정말 감동적으로 읽었어요. 또 읽고 싶어요.',
      );

      expect(controller.state.hasError, isFalse);
      expect(repository.createCalled, isTrue);
    });

    test('퀴즈만 있어도 제출이 성공한다', () async {
      await controller.submit(
        userId: 'u1',
        challengeId: 'c1',
        bookTitle: '어린왕자',
        photoBytes: Uint8List(10),
        photoFileName: 'photo.jpg',
        quizAnswers: const [QuizAnswer(question: 'OX', selectedOption: 'O')],
      );

      expect(controller.state.hasError, isFalse);
      expect(repository.createCalled, isTrue);
    });

    test('사진 용량이 5MB를 초과하면 에러 상태가 된다', () async {
      await controller.submit(
        userId: 'u1',
        challengeId: 'c1',
        bookTitle: '어린왕자',
        photoBytes: Uint8List(6 * 1024 * 1024),
        photoFileName: 'photo.jpg',
        reviewText: '정말 감동적으로 읽었어요. 또 읽고 싶어요.',
      );

      expect(controller.state.hasError, isTrue);
      expect(repository.createCalled, isFalse);
    });
  });
}
