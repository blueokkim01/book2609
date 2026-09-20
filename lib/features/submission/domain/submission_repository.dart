import 'dart:typed_data';

import 'quiz_answer.dart';
import 'submission.dart';

/// 제출물 생성/조회와 검토 상태 전이(대기→승인/반려)만 담당하는 저장소.
///
/// ⚠️ 포인트 적립·뱃지 부여는 여기서 절대 수행하지 않는다. 승인 상태로의
/// 전이(write)는 Cloud Functions의 onSubmissionApproved 트리거를 발동시킬
/// 뿐이며, 실제 게이미피케이션 결과는 서버가 별도 트랜잭션으로 기록한다.
abstract class SubmissionRepository {
  /// 사진 바이트를 업로드하고 제출 문서를 `pending` 상태로 생성한다.
  /// [reviewText] 또는 [quizAnswers] 중 최소 하나는 채워야 한다(화면단 검증).
  Future<String> createSubmission({
    required String userId,
    required String challengeId,
    required String bookTitle,
    required Uint8List photoBytes,
    required String photoFileName,
    String? reviewText,
    List<QuizAnswer>? quizAnswers,
  });

  Stream<List<Submission>> watchSubmissionsForStudent(String userId);

  Stream<List<Submission>> watchSubmissionsForChallenge(String challengeId);

  /// 특정 교사가 개설한 챌린지들의 검토 대기 제출물 목록.
  Stream<List<Submission>> watchPendingSubmissionsForChallenges(
    List<String> challengeIds,
  );

  Future<void> approve(String submissionId);

  Future<void> reject(String submissionId, {required String reason});
}
