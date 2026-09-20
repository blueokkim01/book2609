import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/features/auth/application/auth_providers.dart';
import 'package:reading_challenge/features/auth/domain/app_user.dart';
import 'package:reading_challenge/features/auth/domain/auth_repository.dart';
import 'package:reading_challenge/features/auth/domain/user_role.dart';
import 'package:reading_challenge/features/auth/presentation/login_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<String?> authStateChanges() => throw UnimplementedError();

  @override
  Stream<AppUser?> watchCurrentUserProfile(String uid) =>
      throw UnimplementedError();

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      throw UnimplementedError('이 테스트에서는 유효성 검증 실패로 호출되지 않아야 한다');

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String nickname,
    required String schoolCode,
    required String classCode,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<void> recordGuardianConsent({
    required String studentUid,
    required String consentBy,
  }) =>
      throw UnimplementedError();
}

void main() {
  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('이메일/비밀번호 입력 필드와 로그인 버튼이 보인다', (tester) async {
    await pumpLoginScreen(tester);

    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
  });

  testWidgets('올바르지 않은 이메일로 제출하면 검증 에러가 표시된다', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'not-an-email',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('올바른 이메일을 입력해주세요'), findsOneWidget);
  });

  testWidgets('비밀번호가 너무 짧으면 검증 에러가 표시된다', (tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'student@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      '123',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('비밀번호는 6자 이상이어야 해요'), findsOneWidget);
  });
}
