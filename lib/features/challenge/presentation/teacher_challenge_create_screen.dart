import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../application/challenge_controller.dart';
import '../domain/submission_method.dart';

/// 교사가 챌린지를 생성하는 화면.
/// 기간, 목표 권수 또는 지정 도서 목록, 요구 인증방식을 설정한다.
class TeacherChallengeCreateScreen extends ConsumerStatefulWidget {
  const TeacherChallengeCreateScreen({super.key});

  @override
  ConsumerState<TeacherChallengeCreateScreen> createState() =>
      _TeacherChallengeCreateScreenState();
}

class _TeacherChallengeCreateScreenState
    extends ConsumerState<TeacherChallengeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetBookCountController = TextEditingController();
  final _targetBooksController = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  final Set<SubmissionMethod> _selectedMethods = {SubmissionMethod.review};

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('시작일과 종료일을 선택해주세요')));
      return;
    }
    if (_selectedMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 인증 외 추가 인증 방식을 1개 이상 선택해주세요')));
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final targetBooks = _targetBooksController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final targetBookCount = int.tryParse(_targetBookCountController.text.trim());

    await ref.read(challengeControllerProvider.notifier).createChallenge(
          teacherId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          start: _start!,
          end: _end!,
          schoolCode: user.schoolCode,
          classCode: user.classCode,
          targetBookCount: targetBooks.isEmpty ? targetBookCount : null,
          targetBooks: targetBooks,
          requiredMethods: _selectedMethods.toList(),
        );

    final state = ref.read(challengeControllerProvider);
    if (!state.hasError && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeControllerProvider);

    ref.listen(challengeControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error'))),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('챌린지 만들기')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '챌린지 제목'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '제목을 입력해주세요' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '설명'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: true),
                        child: Text(_start == null
                            ? '시작일 선택'
                            : '시작 ${_start!.toLocal()}'.split(' ').first),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: false),
                        child: Text(_end == null
                            ? '종료일 선택'
                            : '종료 ${_end!.toLocal()}'.split(' ').first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('목표 권수 (지정 도서 목록을 쓰면 비워두세요)',
                    style: Theme.of(context).textTheme.labelLarge),
                TextFormField(
                  controller: _targetBookCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '목표 권수'),
                ),
                const SizedBox(height: 16),
                Text('지정 도서 목록 (쉼표로 구분, 선택사항)',
                    style: Theme.of(context).textTheme.labelLarge),
                TextFormField(
                  controller: _targetBooksController,
                  decoration: const InputDecoration(labelText: '예: 어린왕자, 데미안'),
                ),
                const SizedBox(height: 24),
                Text('요구 인증 방식 (사진은 항상 필수, 아래에서 1개 이상 추가 선택)',
                    style: Theme.of(context).textTheme.labelLarge),
                ...SubmissionMethod.values.map(
                  (method) => CheckboxListTile(
                    value: _selectedMethods.contains(method),
                    title: Text(method.displayName),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selectedMethods.add(method);
                      } else {
                        _selectedMethods.remove(method);
                      }
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('챌린지 생성'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetBookCountController.dispose();
    _targetBooksController.dispose();
    super.dispose();
  }
}
