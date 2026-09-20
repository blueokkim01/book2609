import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/challenge_providers.dart';
import 'widgets/challenge_card.dart';

/// 교사 홈: 본인이 개설한 챌린지 목록 + 새 챌린지 생성 버튼.
class TeacherChallengeListScreen extends ConsumerWidget {
  const TeacherChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(teacherChallengesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('내가 만든 챌린지')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/challenges/new'),
        icon: const Icon(Icons.add),
        label: const Text('챌린지 만들기'),
      ),
      body: AsyncValueView(
        value: challengesAsync,
        data: (challenges) {
          if (challenges.isEmpty) {
            return const Center(child: Text('아직 개설한 챌린지가 없어요.'));
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
