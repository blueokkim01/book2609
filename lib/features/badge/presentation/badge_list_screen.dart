import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/badge_providers.dart';
import 'widgets/badge_tile.dart';

/// 학생 마이페이지에서 사용하는 뱃지 목록 화면.
/// 전체 카탈로그를 보여주되, 획득한 뱃지는 강조하고 미획득은 흐리게 표시한다.
class BadgeListScreen extends ConsumerWidget {
  const BadgeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBadgesAsync = ref.watch(allBadgesProvider);
    final userBadgeIds =
        ref.watch(myEarnedBadgesProvider).value?.map((b) => b.id).toSet() ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('내 뱃지')),
      body: AsyncValueView(
        value: allBadgesAsync,
        data: (badges) {
          if (badges.isEmpty) {
            return const Center(child: Text('등록된 뱃지가 없어요.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return BadgeTile(
                badge: badge,
                earned: userBadgeIds.contains(badge.id),
              );
            },
          );
        },
      ),
    );
  }
}
