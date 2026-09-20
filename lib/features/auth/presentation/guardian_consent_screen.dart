import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_providers.dart';
import '../domain/auth_repository.dart';

/// 학생 가입 직후 노출되는 보호자 동의 화면.
///
/// 실제 서비스에서는 보호자 본인 확인 절차(예: 학부모 앱/문자 인증)가
/// 필요하지만, 그 법적 처리 로직은 이번 범위 밖이다. 이 화면은 "누가,
/// 언제 동의했는지"를 [GuardianConsent]로 정직하게 기록하는 최소 흐름만
/// 제공한다.
class GuardianConsentScreen extends ConsumerStatefulWidget {
  const GuardianConsentScreen({super.key});

  @override
  ConsumerState<GuardianConsentScreen> createState() =>
      _GuardianConsentScreenState();
}

class _GuardianConsentScreenState
    extends ConsumerState<GuardianConsentScreen> {
  final _guardianNameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _guardianNameController.dispose();
    super.dispose();
  }

  Future<void> _consent() async {
    final uid = ref.read(authStateProvider).value;
    if (uid == null) return;
    final guardianName = _guardianNameController.text.trim();
    if (guardianName.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final AuthRepository repo = ref.read(authRepositoryProvider);
      await repo.recordGuardianConsent(
        studentUid: uid,
        consentBy: guardianName,
      );
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보호자 동의')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '개인정보(닉네임, 학교/학급, 독서 인증 사진)를 챌린지 진행을 위해 '
                '수집·저장합니다. 보호자가 아래 내용을 확인하고 동의해주세요.',
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _guardianNameController,
                decoration: const InputDecoration(labelText: '보호자 이름(또는 식별명)'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitting ? null : _consent,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('동의하고 시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
