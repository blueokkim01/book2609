import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../challenge/application/challenge_providers.dart';
import '../data/submission_repository_impl.dart';
import '../domain/submission.dart';
import '../domain/submission_repository.dart';

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  return SubmissionRepositoryImpl();
});

/// 로그인한 학생 본인의 제출 이력(마이페이지에서 사용).
final mySubmissionsProvider = StreamProvider<List<Submission>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(submissionRepositoryProvider)
      .watchSubmissionsForStudent(user.uid);
});

final submissionsForChallengeProvider =
    StreamProvider.family<List<Submission>, String>((ref, challengeId) {
  return ref
      .watch(submissionRepositoryProvider)
      .watchSubmissionsForChallenge(challengeId);
});

/// 교사 검토 대시보드: 본인이 만든 모든 챌린지의 검토 대기 제출물.
final teacherPendingSubmissionsProvider =
    StreamProvider<List<Submission>>((ref) {
  final challengesAsync = ref.watch(teacherChallengesProvider);
  final challengeIds =
      challengesAsync.value?.map((c) => c.id).toList() ?? const [];
  return ref
      .watch(submissionRepositoryProvider)
      .watchPendingSubmissionsForChallenges(challengeIds);
});
