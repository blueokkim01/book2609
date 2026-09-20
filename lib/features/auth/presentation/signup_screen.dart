import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_controller.dart';
import '../domain/user_role.dart';
import 'widgets/role_selector.dart';

/// 역할 선택 + 학교/학급 코드 입력 회원가입 화면.
///
/// 학생으로 가입할 경우 가입 직후 보호자 동의 화면으로 안내한다
/// (`/guardian-consent`). 동의 자체의 법적 처리 로직은 범위 밖이며,
/// 이 화면은 동의 여부·시각·주체를 정직하게 기록하는 흐름만 제공한다.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _schoolCodeController = TextEditingController();
  final _classCodeController = TextEditingController();
  UserRole _role = UserRole.student;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _schoolCodeController.dispose();
    _classCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _role,
          nickname: _nicknameController.text.trim(),
          schoolCode: _schoolCodeController.text.trim(),
          classCode: _classCodeController.text.trim(),
        );

    final state = ref.read(authControllerProvider);
    if (!state.hasError && mounted) {
      if (_role == UserRole.student) {
        context.go('/guardian-consent');
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RoleSelector(
                      value: _role,
                      onChanged: (role) => setState(() => _role = role),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: '닉네임 (실명 대신 사용돼요)',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().length < 2)
                              ? '닉네임을 2자 이상 입력해주세요'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: '이메일'),
                      validator: (value) => (value == null || !value.contains('@'))
                          ? '올바른 이메일을 입력해주세요'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                      validator: (value) => (value == null || value.length < 6)
                          ? '비밀번호는 6자 이상이어야 해요'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _schoolCodeController,
                      decoration: const InputDecoration(labelText: '학교 코드'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? '학교에서 안내받은 코드를 입력해주세요'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _classCodeController,
                      decoration: const InputDecoration(labelText: '학급 코드'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? '학급 코드를 입력해주세요'
                              : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('가입하기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
