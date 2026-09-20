import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/profanity_filter.dart';
import '../domain/quiz_answer.dart';
import '../domain/submission_repository.dart';
import 'submission_providers.dart';

/// 학생의 인증 제출 폼 상태를 관리한다.
///
/// 사진은 항상 필수이며, 독후감/한줄평 또는 퀴즈 중 최소 1개를 함께
/// 요구한다는 규칙(요구사항 3)을 여기서 검증한다. 단, 이 검증은 UX를 위한
/// 것일 뿐 최종 강제는 서버 규칙/함수가 아니라 챌린지 설정을 신뢰하는
/// 클라이언트 단 검증 수준이다.
class SubmissionController extends StateNotifier<AsyncValue<void>> {
  SubmissionController(this._repository) : super(const AsyncData(null));

  final SubmissionRepository _repository;

  Future<void> submit({
    required String userId,
    required String challengeId,
    required String bookTitle,
    required Uint8List photoBytes,
    required String photoFileName,
    String? reviewText,
    List<QuizAnswer>? quizAnswers,
  }) async {
    final hasReview = reviewText != null && reviewText.trim().isNotEmpty;
    final hasQuiz = quizAnswers != null && quizAnswers.isNotEmpty;

    if (!hasReview && !hasQuiz) {
      state = AsyncError(
        ArgumentError('독후감/한줄평 또는 퀴즈 중 하나는 반드시 작성해야 합니다.'),
        StackTrace.current,
      );
      return;
    }

    if (hasReview) {
      if (reviewText.trim().length < AppConstants.reviewMinLength) {
        state = AsyncError(
          ArgumentError('독후감/한줄평을 조금 더 자세히 작성해주세요.'),
          StackTrace.current,
        );
        return;
      }
      if (ProfanityFilter.containsProfanity(reviewText)) {
        state = AsyncError(
          ArgumentError('부적절한 표현이 포함되어 있어요. 다시 작성해주세요.'),
          StackTrace.current,
        );
        return;
      }
    }

    if (photoBytes.lengthInBytes > AppConstants.maxPhotoSizeBytes) {
      state = AsyncError(
        ArgumentError('사진 용량이 너무 커요. 5MB 이하로 압축해주세요.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.createSubmission(
        userId: userId,
        challengeId: challengeId,
        bookTitle: bookTitle,
        photoBytes: photoBytes,
        photoFileName: photoFileName,
        reviewText: hasReview ? reviewText.trim() : null,
        quizAnswers: hasQuiz ? quizAnswers : null,
      ),
    );
  }
}

final submissionControllerProvider =
    StateNotifierProvider<SubmissionController, AsyncValue<void>>((ref) {
  return SubmissionController(ref.watch(submissionRepositoryProvider));
});

/// 교사의 승인/반려 액션 상태.
class SubmissionReviewController extends StateNotifier<AsyncValue<void>> {
  SubmissionReviewController(this._repository) : super(const AsyncData(null));

  final SubmissionRepository _repository;

  Future<void> approve(String submissionId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.approve(submissionId));
  }

  Future<void> reject(String submissionId, String reason) async {
    if (reason.trim().isEmpty) {
      state = AsyncError(ArgumentError('반려 사유를 입력해주세요.'), StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.reject(submissionId, reason: reason.trim()),
    );
  }
}

final submissionReviewControllerProvider = StateNotifierProvider<
    SubmissionReviewController, AsyncValue<void>>((ref) {
  return SubmissionReviewController(ref.watch(submissionRepositoryProvider));
});
