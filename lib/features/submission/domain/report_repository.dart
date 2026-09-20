abstract class ReportRepository {
  Future<void> createReport({
    required String submissionId,
    required String reporterUid,
    required String reason,
  });
}
