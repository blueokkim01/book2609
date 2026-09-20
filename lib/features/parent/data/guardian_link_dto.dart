import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/guardian_link.dart';

class GuardianLinkDto {
  const GuardianLinkDto._();

  static GuardianLink fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('guardianLinks/${doc.id} 문서가 존재하지 않습니다.');
    }
    return GuardianLink(
      id: doc.id,
      parentUid: data['parentUid'] as String,
      studentUid: data['studentUid'] as String,
      consentAt: (data['consentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      consentBy: data['consentBy'] as String,
    );
  }

  static Map<String, dynamic> toCreatePayload({
    required String parentUid,
    required String studentUid,
    required String consentBy,
  }) =>
      {
        'parentUid': parentUid,
        'studentUid': studentUid,
        'consentAt': FieldValue.serverTimestamp(),
        'consentBy': consentBy,
      };
}
