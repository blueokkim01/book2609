import 'challenge.dart';
import 'submission_method.dart';

abstract class ChallengeRepository {
  /// 학생/교사가 속한 학교·학급의 챌린지 목록을 실시간 구독.
  Stream<List<Challenge>> watchChallengesForClass({
    required String schoolCode,
    required String classCode,
  });

  /// 특정 교사가 개설한 챌린지 목록(교사 대시보드용).
  Stream<List<Challenge>> watchChallengesForTeacher(String teacherId);

  Stream<Challenge?> watchChallenge(String challengeId);

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
  });
}
