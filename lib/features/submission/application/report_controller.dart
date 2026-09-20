import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/report_repository_impl.dart';
import '../domain/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl();
});

class ReportController extends StateNotifier<AsyncValue<void>> {
  ReportController(this._repository) : super(const AsyncData(null));

  final ReportRepository _repository;

  Future<void> report({
    required String submissionId,
    required String reporterUid,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      state = AsyncError(ArgumentError('신고 사유를 입력해주세요.'), StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.createReport(
        submissionId: submissionId,
        reporterUid: reporterUid,
        reason: reason.trim(),
      ),
    );
  }
}

final reportControllerProvider =
    StateNotifierProvider<ReportController, AsyncValue<void>>((ref) {
  return ReportController(ref.watch(reportRepositoryProvider));
});
