import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../submission/application/submission_providers.dart';
import '../../submission/domain/submission.dart';
import '../data/guardian_link_repository_impl.dart';
import '../domain/guardian_link.dart';
import '../domain/guardian_link_repository.dart';

final guardianLinkRepositoryProvider = Provider<GuardianLinkRepository>((ref) {
  return GuardianLinkRepositoryImpl();
});

/// 로그인한 학부모가 연결한 자녀 목록.
final myGuardianLinksProvider = StreamProvider<List<GuardianLink>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value(const []);
  return ref.watch(guardianLinkRepositoryProvider).watchLinksForParent(uid);
});

/// 특정 자녀의 프로필(포인트/뱃지 등)을 읽기 전용으로 구독한다.
/// firestore.rules가 guardianLinks 존재 여부로 접근을 제어한다.
final childProfileProvider =
    StreamProvider.family<AppUser?, String>((ref, studentUid) {
  return ref
      .watch(authRepositoryProvider)
      .watchCurrentUserProfile(studentUid);
});

final childSubmissionsProvider =
    StreamProvider.family<List<Submission>, String>((ref, studentUid) {
  return ref
      .watch(submissionRepositoryProvider)
      .watchSubmissionsForStudent(studentUid);
});
