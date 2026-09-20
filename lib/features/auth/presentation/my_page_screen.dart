import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/points_chip.dart';
import '../../submission/application/submission_providers.dart';
import '../application/auth_controller.dart';
import '../application/auth_providers.dart';
import '../domain/user_role.dart';

/// 마이페이지. 학생은 참여 챌린지 수·누적 독서 기록·뱃지 개수를 요약해
/// 보여준다(뱃지 상세 목록은 `/badges`). 교사·학부모는 간단한 프로필과
/// 로그아웃만 제공한다.
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: AsyncValueView(
        value: userAsync,
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nickname,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text('${user.role.displayName} · ${user.schoolCode}/${user.classCode}'),
                    ],
                  ),
                  if (user.role == UserRole.student) PointsChip(points: user.points),
                ],
              ),
              const SizedBox(height: 24),
              if (user.role == UserRole.student) ...[
                _StudentSummary(badgeCount: user.badgeIds.length),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.emoji_events_rounded),
                  title: const Text('획득한 뱃지 보기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/badges'),
                ),
              ],
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('로그아웃'),
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentSummary extends ConsumerWidget {
  const _StudentSummary({required this.badgeCount});

  final int badgeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(mySubmissionsProvider);

    return submissionsAsync.when(
      data: (submissions) {
        final approvedCount =
            submissions.where((s) => s.status.name == 'approved').length;
        return Row(
          children: [
            Expanded(
              child: _StatTile(label: '완독 인증', value: '$approvedCount권'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(label: '획득 뱃지', value: '$badgeCount개'),
            ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, __) => Text('$e'),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
