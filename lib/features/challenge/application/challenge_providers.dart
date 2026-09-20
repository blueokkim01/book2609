import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/challenge_repository_impl.dart';
import '../domain/challenge.dart';
import '../domain/challenge_repository.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepositoryImpl();
});

/// 로그인한 사용자의 학교/학급 챌린지 목록(학생·학부모 화면에서 사용).
final classChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(challengeRepositoryProvider).watchChallengesForClass(
        schoolCode: user.schoolCode,
        classCode: user.classCode,
      );
});

/// 로그인한 교사가 개설한 챌린지 목록(교사 대시보드용).
final teacherChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(challengeRepositoryProvider)
      .watchChallengesForTeacher(user.uid);
});

final challengeDetailProvider =
    StreamProvider.family<Challenge?, String>((ref, challengeId) {
  return ref.watch(challengeRepositoryProvider).watchChallenge(challengeId);
});
