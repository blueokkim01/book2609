import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/challenge_repository.dart';
import '../domain/submission_method.dart';
import 'challenge_providers.dart';

/// 교사의 챌린지 생성 폼 제출 상태를 관리한다.
class ChallengeController extends StateNotifier<AsyncValue<void>> {
  ChallengeController(this._repository) : super(const AsyncData(null));

  final ChallengeRepository _repository;

  Future<void> createChallenge({
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
  }) async {
    if (requiredMethods.isEmpty) {
      state = AsyncError(
        ArgumentError('사진 인증 외 추가 인증 방식을 1개 이상 선택해야 합니다.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.createChallenge(
        teacherId: teacherId,
        title: title,
        description: description,
        start: start,
        end: end,
        schoolCode: schoolCode,
        classCode: classCode,
        targetBookCount: targetBookCount,
        targetBooks: targetBooks,
        requiredMethods: requiredMethods,
      ),
    );
  }
}

final challengeControllerProvider =
    StateNotifierProvider<ChallengeController, AsyncValue<void>>((ref) {
  return ChallengeController(ref.watch(challengeRepositoryProvider));
});
