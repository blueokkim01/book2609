import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/points_chip.dart';
import '../application/guardian_link_providers.dart';

/// 학부모 홈: 연결된 자녀 목록과 각 자녀의 진행 현황 요약(읽기 전용).
class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(myGuardianLinksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('자녀 현황')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/link-child'),
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('자녀 연결'),
      ),
      body: AsyncValueView(
        value: linksAsync,
        data: (links) {
          if (links.isEmpty) {
            return const Center(child: Text('연결된 자녀가 없어요. 자녀를 연결해보세요.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              final childAsync = ref.watch(childProfileProvider(link.studentUid));

              return Card(
                child: ListTile(
                  title: Text(childAsync.value?.nickname ?? '불러오는 중...'),
                  subtitle: Text(
                    '${childAsync.value?.schoolCode ?? ''} / '
                    '${childAsync.value?.classCode ?? ''}',
                  ),
                  trailing: childAsync.value != null
                      ? PointsChip(points: childAsync.value!.points)
                      : null,
                  onTap: () => context.go('/children/${link.studentUid}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
