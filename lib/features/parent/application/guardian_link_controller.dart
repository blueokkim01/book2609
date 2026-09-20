import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/guardian_link_repository.dart';
import 'guardian_link_providers.dart';

class GuardianLinkController extends StateNotifier<AsyncValue<void>> {
  GuardianLinkController(this._repository) : super(const AsyncData(null));

  final GuardianLinkRepository _repository;

  Future<void> linkChild({
    required String parentUid,
    required String studentUid,
    required String consentBy,
  }) async {
    if (studentUid.trim().isEmpty || consentBy.trim().isEmpty) {
      state = AsyncError(
        ArgumentError('학생 코드와 보호자 이름을 모두 입력해주세요.'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.createLink(
        parentUid: parentUid,
        studentUid: studentUid.trim(),
        consentBy: consentBy.trim(),
      ),
    );
  }
}

final guardianLinkControllerProvider =
    StateNotifierProvider<GuardianLinkController, AsyncValue<void>>((ref) {
  return GuardianLinkController(ref.watch(guardianLinkRepositoryProvider));
});
