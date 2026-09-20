import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/image_utils.dart';
import '../../auth/application/auth_providers.dart';
import '../../challenge/application/challenge_providers.dart';
import '../../challenge/domain/submission_method.dart';
import '../application/submission_controller.dart';
import '../domain/quiz_answer.dart';

/// 학생의 인증 제출 화면.
/// 사진 인증(필수) + 챌린지가 요구하는 독후감/퀴즈 중 1개 이상을 입력받는다.
class SubmissionFormScreen extends ConsumerStatefulWidget {
  const SubmissionFormScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  ConsumerState<SubmissionFormScreen> createState() =>
      _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends ConsumerState<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookTitleController = TextEditingController();
  final _reviewController = TextEditingController();
  final _quizQuestionController = TextEditingController();
  final _quizAnswerController = TextEditingController();
  File? _photoFile;

  @override
  void dispose() {
    _bookTitleController.dispose();
    _reviewController.dispose();
    _quizQuestionController.dispose();
    _quizAnswerController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (picked == null) return;
    setState(() => _photoFile = File(picked.path));
  }

  Future<void> _submit(List<SubmissionMethod> requiredMethods) async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('책 표지/페이지 사진을 첨부해주세요')));
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final photoBytes = await ImageUtils.compress(_photoFile!);

    final reviewText = requiredMethods.contains(SubmissionMethod.review)
        ? _reviewController.text
        : null;
    final quizAnswers = requiredMethods.contains(SubmissionMethod.quiz) &&
            _quizQuestionController.text.trim().isNotEmpty
        ? [
            QuizAnswer(
              question: _quizQuestionController.text.trim(),
              selectedOption: _quizAnswerController.text.trim(),
            ),
          ]
        : null;

    await ref.read(submissionControllerProvider.notifier).submit(
          userId: user.uid,
          challengeId: widget.challengeId,
          bookTitle: _bookTitleController.text.trim(),
          photoBytes: photoBytes,
          photoFileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
          reviewText: reviewText,
          quizAnswers: quizAnswers,
        );

    final state = ref.read(submissionControllerProvider);
    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('제출했어요! 선생님 승인을 기다려주세요.')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(challengeDetailProvider(widget.challengeId));
    final state = ref.watch(submissionControllerProvider);

    ref.listen(submissionControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error'))),
      );
    });

    final requiredMethods = challengeAsync.value?.requiredMethods ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('인증 제출')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      image: _photoFile != null
                          ? DecorationImage(
                              image: FileImage(_photoFile!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _photoFile == null
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt_rounded, size: 40),
                                SizedBox(height: 8),
                                Text('책 표지/페이지 사진 촬영 (필수)'),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _bookTitleController,
                  decoration: const InputDecoration(labelText: '책 제목'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '책 제목을 입력해주세요' : null,
                ),
                if (requiredMethods.contains(SubmissionMethod.review)) ...[
                  const SizedBox(height: 24),
                  Text('독후감 / 한줄평', style: Theme.of(context).textTheme.labelLarge),
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: '읽은 소감을 적어주세요'),
                  ),
                ],
                if (requiredMethods.contains(SubmissionMethod.quiz)) ...[
                  const SizedBox(height: 24),
                  Text('퀴즈 (OX 또는 객관식)',
                      style: Theme.of(context).textTheme.labelLarge),
                  TextFormField(
                    controller: _quizQuestionController,
                    decoration: const InputDecoration(labelText: '문제'),
                  ),
                  TextFormField(
                    controller: _quizAnswerController,
                    decoration: const InputDecoration(labelText: '내 답'),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      state.isLoading ? null : () => _submit(requiredMethods),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('제출하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
