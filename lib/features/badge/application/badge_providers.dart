import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/badge_repository_impl.dart';
import '../domain/badge.dart';
import '../domain/badge_repository.dart';

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return BadgeRepositoryImpl();
});

final allBadgesProvider = StreamProvider<List<ReadingBadge>>((ref) {
  return ref.watch(badgeRepositoryProvider).watchAllBadges();
});

/// 로그인한 사용자가 실제로 획득한 뱃지 목록.
/// `users/{uid}.badgeIds`(서버 권위 필드)를 카탈로그와 매칭해 표시만 한다.
final myEarnedBadgesProvider = Provider<AsyncValue<List<ReadingBadge>>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final allBadgesAsync = ref.watch(allBadgesProvider);

  if (userAsync.isLoading || allBadgesAsync.isLoading) {
    return const AsyncLoading();
  }
  if (userAsync.hasError) {
    return AsyncError(userAsync.error!, userAsync.stackTrace!);
  }
  if (allBadgesAsync.hasError) {
    return AsyncError(allBadgesAsync.error!, allBadgesAsync.stackTrace!);
  }

  final user = userAsync.value;
  final allBadges = allBadgesAsync.value ?? const [];
  if (user == null) return const AsyncData([]);

  final earned =
      allBadges.where((badge) => user.badgeIds.contains(badge.id)).toList();
  return AsyncData(earned);
});
