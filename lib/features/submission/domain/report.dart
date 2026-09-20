import 'package:equatable/equatable.dart';

/// `reports/{reportId}` 문서를 표현하는 도메인 엔티티.
///
/// 독후감/한줄평 텍스트에 대한 신고 기능(요구사항)을 위한 최소 모델이다.
/// 자동 판정 없이 교사가 신고 내역을 확인해 후속 조치를 결정한다.
class Report extends Equatable {
  const Report({
    required this.id,
    required this.submissionId,
    required this.reporterUid,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String submissionId;
  final String reporterUid;
  final String reason;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, submissionId, reporterUid, reason, createdAt];
}
