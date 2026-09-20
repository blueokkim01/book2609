import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/challenge.dart';
import '../domain/challenge_period.dart';
import '../domain/submission_method.dart';

class ChallengeDto {
  const ChallengeDto._();

  static Challenge fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('challenges/${doc.id} 문서가 존재하지 않습니다.');
    }

    final period = data['period'] as Map<String, dynamic>;

    return Challenge(
      id: doc.id,
      teacherId: data['teacherId'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      period: ChallengePeriod(
        start: (period['start'] as Timestamp).toDate(),
        end: (period['end'] as Timestamp).toDate(),
      ),
      schoolCode: data['schoolCode'] as String,
      classCode: data['classCode'] as String,
      targetBookCount: data['targetBookCount'] as int?,
      targetBooks: List<String>.from(data['targetBooks'] as List? ?? const []),
      requiredMethods: (data['requiredMethods'] as List? ?? const [])
          .map((m) => SubmissionMethod.fromFirestore(m as String))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toCreatePayload({
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
      {
        'teacherId': teacherId,
        'title': title,
        'description': description,
        'period': {
          'start': Timestamp.fromDate(start),
          'end': Timestamp.fromDate(end),
        },
        'schoolCode': schoolCode,
        'classCode': classCode,
        'targetBookCount': targetBookCount,
        'targetBooks': targetBooks,
        'requiredMethods': requiredMethods.map((m) => m.firestoreValue).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };
}
