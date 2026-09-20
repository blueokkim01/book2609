import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/user_role.dart';
import '../application/challenge_providers.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeDetailProvider(challengeId));
    final user = ref.watch(currentUserProvider).value;
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(title: const Text('챌린지 상세')),
      body: AsyncValueView(
        value: challengeAsync,
        data: (challenge) {
          if (challenge == null) {
            return const Center(child: Text('챌린지를 찾을 수 없어요.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '${dateFormat.format(challenge.period.start)} ~ '
                  '${dateFormat.format(challenge.period.end)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(challenge.description),
                const SizedBox(height: 16),
                if (challenge.usesTargetBookList) ...[
                  Text('지정 도서', style: Theme.of(context).textTheme.labelLarge),
                  Wrap(
                    spacing: 8,
                    children: challenge.targetBooks
                        .map((b) => Chip(label: Text(b)))
                        .toList(),
                  ),
                ] else if (challenge.targetBookCount != null)
                  Text('목표 권수: ${challenge.targetBookCount}권'),
                const SizedBox(height: 16),
                Text('요구 인증: 사진 + '
                    '${challenge.requiredMethods.map((m) => m.displayName).join(', ')}'),
                const Spacer(),
                if (user?.role == UserRole.student)
                  ElevatedButton(
                    onPressed: () =>
                        context.go('/challenges/$challengeId/submit'),
                    child: const Text('인증 제출하기'),
                  ),
                if (user?.role == UserRole.teacher)
                  OutlinedButton(
                    onPressed: () => context.go('/review?challengeId=$challengeId'),
                    child: const Text('이 챌린지 제출물 검토'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
