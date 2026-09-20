import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/points_chip.dart';
import '../../auth/application/auth_providers.dart';
import '../application/challenge_providers.dart';
import 'widgets/challenge_card.dart';

/// 학생 홈: 소속 학급의 챌린지 목록을 보여준다.
class StudentChallengeListScreen extends ConsumerWidget {
  const StudentChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(classChallengesProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('우리 반 챌린지'),
        actions: [
          userAsync.maybeWhen(
            data: (user) => user == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(child: PointsChip(points: user.points)),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: AsyncValueView(
        value: challengesAsync,
        data: (challenges) {
          if (challenges.isEmpty) {
            return const Center(child: Text('아직 등록된 챌린지가 없어요.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return ChallengeCard(
                challenge: challenge,
                onTap: () => context.go('/challenges/${challenge.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
