import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/points_chip.dart';
import '../../submission/presentation/widgets/submission_status_badge.dart';
import '../application/guardian_link_providers.dart';

/// 학부모가 특정 자녀의 진행 현황을 읽기 전용으로 조회하는 화면.
class ChildProgressScreen extends ConsumerWidget {
  const ChildProgressScreen({super.key, required this.studentUid});

  final String studentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childProfileProvider(studentUid));
    final submissionsAsync = ref.watch(childSubmissionsProvider(studentUid));

    return Scaffold(
      appBar: AppBar(title: const Text('자녀 진행 현황')),
      body: AsyncValueView(
        value: childAsync,
        data: (child) {
          if (child == null) return const Center(child: Text('정보를 찾을 수 없어요.'));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.nickname,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text('뱃지 ${child.badgeIds.length}개 보유'),
                      ],
                    ),
                    PointsChip(points: child.points),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: AsyncValueView(
                  value: submissionsAsync,
                  data: (submissions) {
                    if (submissions.isEmpty) {
                      return const Center(child: Text('아직 제출 기록이 없어요.'));
                    }
                    return ListView.builder(
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final s = submissions[index];
                        return ListTile(
                          title: Text(s.bookTitle),
                          subtitle: Text(
                            '${s.submittedAt.year}.${s.submittedAt.month}.${s.submittedAt.day}',
                          ),
                          trailing: SubmissionStatusBadge(status: s.status),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
