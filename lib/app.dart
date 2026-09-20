import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notification/application/notification_providers.dart';

/// 앱의 루트 위젯. go_router 기반 라우팅과 전역 테마를 구성한다.
class ReadingChallengeApp extends ConsumerWidget {
  const ReadingChallengeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // 로그인 상태가 되면 자동으로 FCM 토큰을 등록한다.
    ref.watch(fcmRegistrationProvider);

    return MaterialApp.router(
      title: '독서 챌린지',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
      routerConfig: router,
    );
  }
}
