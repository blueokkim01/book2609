import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../application/guardian_link_controller.dart';

/// 학부모가 자녀를 연결하고 동의를 기록하는 화면.
///
/// [studentCode]는 학교/담임 교사가 보호자에게 안내하는 학생 식별 코드를
/// 입력받는다고 가정한다(본인확인 절차 자체는 이번 범위 밖).
class LinkChildScreen extends ConsumerStatefulWidget {
  const LinkChildScreen({super.key});

  @override
  ConsumerState<LinkChildScreen> createState() => _LinkChildScreenState();
}

class _LinkChildScreenState extends ConsumerState<LinkChildScreen> {
  final _studentCodeController = TextEditingController();
  final _guardianNameController = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _studentCodeController.dispose();
    _guardianNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('개인정보 수집·이용에 동의해주세요')));
      return;
    }
    final parentUid = ref.read(authStateProvider).value;
    if (parentUid == null) return;

    await ref.read(guardianLinkControllerProvider.notifier).linkChild(
          parentUid: parentUid,
          studentUid: _studentCodeController.text,
          consentBy: _guardianNameController.text,
        );

    final state = ref.read(guardianLinkControllerProvider);
    if (!state.hasError && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guardianLinkControllerProvider);

    ref.listen(guardianLinkControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error'))),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('자녀 연결')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _studentCodeController,
                decoration: const InputDecoration(labelText: '학생 식별 코드(uid)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _guardianNameController,
                decoration: const InputDecoration(labelText: '보호자 이름(또는 식별명)'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                title: const Text('자녀의 독서 활동(사진 인증, 포인트, 뱃지) 조회에 동의합니다.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('연결하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
