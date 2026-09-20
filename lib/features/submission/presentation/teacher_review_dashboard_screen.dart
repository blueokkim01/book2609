import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_providers.dart';
import '../application/report_controller.dart';
import '../application/submission_controller.dart';
import '../application/submission_providers.dart';
import '../domain/submission.dart';

/// 교사가 검토 대기 중인 제출물을 승인/반려하는 대시보드.
class TeacherReviewDashboardScreen extends ConsumerWidget {
  const TeacherReviewDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(teacherPendingSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('인증 검토')),
      body: AsyncValueView(
        value: pendingAsync,
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(child: Text('검토할 제출물이 없어요.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            itemBuilder: (context, index) =>
                _SubmissionReviewCard(submission: submissions[index]),
          );
        },
      ),
    );
  }
}

class _SubmissionReviewCard extends ConsumerWidget {
  const _SubmissionReviewCard({required this.submission});

  final Submission submission;

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('반려 사유'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: '반려 사유를 입력해주세요'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(reasonController.text),
            child: const Text('반려'),
          ),
        ],
      ),
    );
    if (reason == null || reason.trim().isEmpty) return;
    await ref
        .read(submissionReviewControllerProvider.notifier)
        .reject(submission.id, reason);
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('부적절한 내용 신고'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: '신고 사유를 입력해주세요'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(reasonController.text),
            child: const Text('신고'),
          ),
        ],
      ),
    );
    if (reason == null || reason.trim().isEmpty) return;

    final reporterUid = ref.read(authStateProvider).value;
    if (reporterUid == null) return;

    await ref.read(reportControllerProvider.notifier).report(
          submissionId: submission.id,
          reporterUid: reporterUid,
          reason: reason,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('신고가 접수됐어요.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(submissionReviewControllerProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: submission.photoUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(submission.bookTitle,
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  tooltip: '독후감 신고',
                  icon: const Icon(Icons.flag_outlined, size: 20),
                  onPressed: () => _report(context, ref),
                ),
              ],
            ),
            if (submission.hasReview) ...[
              const SizedBox(height: 8),
              Text(submission.reviewText!),
            ],
            if (submission.hasQuiz) ...[
              const SizedBox(height: 8),
              ...submission.quizAnswers!.map(
                (q) => Text('Q. ${q.question} → A. ${q.selectedOption}'),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        reviewState.isLoading ? null : () => _reject(context, ref),
                    child: const Text('반려'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: reviewState.isLoading
                        ? null
                        : () => ref
                            .read(submissionReviewControllerProvider.notifier)
                            .approve(submission.id),
                    child: const Text('승인'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
