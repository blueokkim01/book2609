import 'package:equatable/equatable.dart';

import 'quiz_answer.dart';
import 'submission_status.dart';

/// `submissions/{submissionId}` 문서를 표현하는 도메인 엔티티.
///
/// ⚠️ 이 feature에는 포인트 "계산" 로직이 없다. 여기서는 제출물 생성과
/// 상태 조회만 담당하며, 승인 시 포인트/뱃지를 실제로 부여하는 권위 있는
/// 로직은 `functions/src/onSubmissionApproved.ts`에만 존재한다.
class Submission extends Equatable {
  const Submission({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.bookTitle,
    required this.photoUrl,
    required this.status,
    required this.submittedAt,
    this.reviewText,
    this.quizAnswers,
    this.reviewedAt,
    this.reviewerNote,
  });

  final String id;
  final String userId;
  final String challengeId;
  final String bookTitle;
  final String photoUrl;
  final String? reviewText;
  final List<QuizAnswer>? quizAnswers;
  final SubmissionStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerNote;

  bool get hasReview => reviewText != null && reviewText!.trim().isNotEmpty;
  bool get hasQuiz => quizAnswers != null && quizAnswers!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        challengeId,
        bookTitle,
        photoUrl,
        reviewText,
        quizAnswers,
        status,
        submittedAt,
        reviewedAt,
        reviewerNote,
      ];
}
