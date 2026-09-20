import 'package:equatable/equatable.dart';

/// 보호자 동의 기록. 미성년자 개인정보 처리를 위해 "언제, 누가" 동의했는지를
/// 남긴다. 동의의 법적 효력 판단 로직 자체는 이번 범위 밖이며, 이 엔티티는
/// 동의 이력을 정직하게 저장·표시하는 역할만 한다.
class GuardianConsent extends Equatable {
  const GuardianConsent({
    required this.consented,
    required this.consentAt,
    required this.consentBy,
  });

  /// 동의 여부.
  final bool consented;

  /// 동의가 이루어진 시각(UTC).
  final DateTime? consentAt;

  /// 동의 주체(예: 보호자 이름 또는 학부모 계정 uid). 실명 대신 식별 가능한
  /// 최소 정보만 저장한다.
  final String? consentBy;

  factory GuardianConsent.notConsented() => const GuardianConsent(
        consented: false,
        consentAt: null,
        consentBy: null,
      );

  GuardianConsent withConsent({
    required DateTime at,
    required String by,
  }) =>
      GuardianConsent(consented: true, consentAt: at, consentBy: by);

  Map<String, dynamic> toMap() => {
        'consented': consented,
        'consentAt': consentAt?.toIso8601String(),
        'consentBy': consentBy,
      };

  factory GuardianConsent.fromMap(Map<String, dynamic> map) => GuardianConsent(
        consented: map['consented'] as bool? ?? false,
        consentAt: map['consentAt'] != null
            ? DateTime.tryParse(map['consentAt'] as String)
            : null,
        consentBy: map['consentBy'] as String?,
      );

  @override
  List<Object?> get props => [consented, consentAt, consentBy];
}
