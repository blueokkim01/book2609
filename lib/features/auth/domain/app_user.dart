import 'package:equatable/equatable.dart';

import 'guardian_consent.dart';
import 'user_role.dart';

/// `users/{uid}` 문서를 표현하는 도메인 엔티티.
///
/// ⚠️ [points], [badgeIds]는 Cloud Functions만 갱신할 수 있는 서버 권위
/// 필드다. 클라이언트 코드는 이 필드들을 절대 write하지 않는다(읽기 전용).
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.role,
    required this.nickname,
    required this.schoolCode,
    required this.classCode,
    required this.points,
    required this.badgeIds,
    required this.createdAt,
    this.guardianConsent,
  });

  final String uid;
  final UserRole role;

  /// 실명 대신 사용하는 닉네임. 미성년자 개인정보 최소수집 원칙.
  final String nickname;
  final String schoolCode;
  final String classCode;

  /// ⚠️ 서버(Cloud Functions) 전용 write 필드. 읽기 전용으로만 사용할 것.
  final int points;

  /// ⚠️ 서버(Cloud Functions) 전용 write 필드. 읽기 전용으로만 사용할 것.
  final List<String> badgeIds;

  final DateTime createdAt;

  /// 학생 계정에만 해당하는 보호자 동의 기록. 교사/학부모 계정은 null.
  final GuardianConsent? guardianConsent;

  AppUser copyWith({
    String? nickname,
    GuardianConsent? guardianConsent,
  }) =>
      AppUser(
        uid: uid,
        role: role,
        nickname: nickname ?? this.nickname,
        schoolCode: schoolCode,
        classCode: classCode,
        points: points,
        badgeIds: badgeIds,
        createdAt: createdAt,
        guardianConsent: guardianConsent ?? this.guardianConsent,
      );

  @override
  List<Object?> get props => [
        uid,
        role,
        nickname,
        schoolCode,
        classCode,
        points,
        badgeIds,
        createdAt,
        guardianConsent,
      ];
}
