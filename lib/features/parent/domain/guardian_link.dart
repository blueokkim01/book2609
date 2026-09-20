import 'package:equatable/equatable.dart';

/// `guardianLinks/{linkId}` 문서를 표현하는 도메인 엔티티.
/// 학부모-학생 연결 및 동의 시각·주체를 기록한다.
class GuardianLink extends Equatable {
  const GuardianLink({
    required this.id,
    required this.parentUid,
    required this.studentUid,
    required this.consentAt,
    required this.consentBy,
  });

  final String id;
  final String parentUid;
  final String studentUid;
  final DateTime consentAt;

  /// 동의 주체(예: 보호자 식별명).
  final String consentBy;

  @override
  List<Object?> get props => [id, parentUid, studentUid, consentAt, consentBy];
}
