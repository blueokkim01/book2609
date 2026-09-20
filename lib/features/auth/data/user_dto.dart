import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_user.dart';
import '../domain/guardian_consent.dart';
import '../domain/user_role.dart';

/// `users/{uid}` Firestore 문서 ↔ [AppUser] 변환을 담당하는 데이터 계층 객체.
class UserDto {
  const UserDto._();

  static AppUser fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('users/${doc.id} 문서가 존재하지 않습니다.');
    }
    return fromMap(doc.id, data);
  }

  static AppUser fromMap(String uid, Map<String, dynamic> data) => AppUser(
        uid: uid,
        role: UserRole.fromFirestore(data['role'] as String),
        nickname: data['nickname'] as String? ?? '',
        schoolCode: data['schoolCode'] as String? ?? '',
        classCode: data['classCode'] as String? ?? '',
        // points/badgeIds는 서버가 쓰는 필드이므로 여기서는 순수하게 읽기만 한다.
        points: data['points'] as int? ?? 0,
        badgeIds: List<String>.from(data['badgeIds'] as List? ?? const []),
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        guardianConsent: data['guardianConsent'] != null
            ? GuardianConsent.fromMap(
                Map<String, dynamic>.from(data['guardianConsent'] as Map))
            : null,
      );

  /// 신규 가입 시 생성할 문서 payload.
  ///
  /// ⚠️ points/badgeIds는 항상 서버 기본값(0, [])으로 고정하며, 이후 갱신은
  /// Cloud Functions만 수행한다(firestore.rules로 강제됨).
  static Map<String, dynamic> newUserPayload({
    required UserRole role,
    required String nickname,
    required String schoolCode,
    required String classCode,
  }) =>
      {
        'role': role.firestoreValue,
        'nickname': nickname,
        'schoolCode': schoolCode,
        'classCode': classCode,
        'points': 0,
        'badgeIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      };
}
