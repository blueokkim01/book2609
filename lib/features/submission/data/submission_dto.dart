import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/quiz_answer.dart';
import '../domain/submission.dart';
import '../domain/submission_status.dart';

class SubmissionDto {
  const SubmissionDto._();

  static Submission fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('submissions/${doc.id} 문서가 존재하지 않습니다.');
    }

    final quizList = data['quizAnswers'] as List?;

    return Submission(
      id: doc.id,
      userId: data['userId'] as String,
      challengeId: data['challengeId'] as String,
      bookTitle: data['bookTitle'] as String,
      photoUrl: data['photoUrl'] as String,
      reviewText: data['reviewText'] as String?,
      quizAnswers: quizList
          ?.map((e) => QuizAnswer.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      status: SubmissionStatus.fromFirestore(data['status'] as String),
      submittedAt:
          (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewerNote: data['reviewerNote'] as String?,
    );
  }

  static Map<String, dynamic> toCreatePayload({
    required String userId,
    required String challengeId,
    required String bookTitle,
    required String photoUrl,
    String? reviewText,
    List<QuizAnswer>? quizAnswers,
  }) =>
      {
        'userId': userId,
        'challengeId': challengeId,
        'bookTitle': bookTitle,
        'photoUrl': photoUrl,
        if (reviewText != null) 'reviewText': reviewText,
        if (quizAnswers != null)
          'quizAnswers': quizAnswers.map((q) => q.toMap()).toList(),
        // 신규 제출은 항상 pending. 클라이언트는 approved/rejected로 직접
        // 생성할 수 없다(firestore.rules로 강제됨).
        'status': SubmissionStatus.pending.firestoreValue,
        'submittedAt': FieldValue.serverTimestamp(),
      };
}
