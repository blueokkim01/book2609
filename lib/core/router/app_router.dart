import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/guardian_consent_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/my_page_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/badge/presentation/badge_list_screen.dart';
import '../../features/challenge/presentation/challenge_detail_screen.dart';
import '../../features/challenge/presentation/student_challenge_list_screen.dart';
import '../../features/challenge/presentation/teacher_challenge_create_screen.dart';
import '../../features/challenge/presentation/teacher_challenge_list_screen.dart';
import '../../features/notification/presentation/notification_list_screen.dart';
import '../../features/parent/presentation/child_progress_screen.dart';
import '../../features/parent/presentation/link_child_screen.dart';
import '../../features/parent/presentation/parent_dashboard_screen.dart';
import '../../features/submission/presentation/submission_form_screen.dart';
import '../../features/submission/presentation/teacher_review_dashboard_screen.dart';
import '../widgets/home_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// go_router 인스턴스를 제공하는 Provider.
///
/// 역할 기반 redirect: 로그인 여부와 [UserRole]에 따라 접근 가능한 경로를
/// 제한한다(예: 학생은 `/review`, `/challenges/new`에 접근 불가).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(
        path: '/guardian-consent',
        builder: (context, state) => const GuardianConsentScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => Consumer(
          builder: (context, ref, _) {
            final role = ref.watch(currentUserProvider).value?.role;
            if (role == null) return child;
            return HomeShell(role: role, child: child);
          },
        ),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const _HomeRoot(),
          ),
          GoRoute(
            path: '/badges',
            builder: (context, state) => const BadgeListScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationListScreen(),
          ),
          GoRoute(
            path: '/my-page',
            builder: (context, state) => const MyPageScreen(),
          ),
          GoRoute(
            path: '/review',
            builder: (context, state) => const TeacherReviewDashboardScreen(),
          ),
          GoRoute(
            path: '/challenges/new',
            builder: (context, state) => const TeacherChallengeCreateScreen(),
          ),
          GoRoute(
            path: '/challenges/:id',
            builder: (context, state) => ChallengeDetailScreen(
              challengeId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/challenges/:id/submit',
            builder: (context, state) => SubmissionFormScreen(
              challengeId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/link-child',
            builder: (context, state) => const LinkChildScreen(),
          ),
          GoRoute(
            path: '/children/:uid',
            builder: (context, state) => ChildProgressScreen(
              studentUid: state.pathParameters['uid']!,
            ),
          ),
        ],
      ),
    ],
  );
});

/// 역할에 따라 홈('/') 화면을 분기한다.
class _HomeRoot extends ConsumerWidget {
  const _HomeRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserProvider).value?.role;
    return switch (role) {
      UserRole.student => const StudentChallengeListScreen(),
      UserRole.teacher => const TeacherChallengeListScreen(),
      UserRole.parent => const ParentDashboardScreen(),
      null => const SizedBox.shrink(),
    };
  }
}

String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  if (authState.isLoading) return null;

  final uid = authState.value;
  final path = state.matchedLocation;
  final isAuthRoute = path == '/login' || path == '/signup';

  if (uid == null) {
    return isAuthRoute ? null : '/login';
  }

  final userAsync = ref.read(currentUserProvider);
  if (userAsync.isLoading) return null;
  final user = userAsync.value;

  // 로그인은 됐지만 users 문서가 아직 없는(가입 진행 중) 상태.
  if (user == null) return null;

  if (isAuthRoute) return '/';
  if (path == '/guardian-consent' && user.role != UserRole.student) return '/';

  const teacherOnlyPrefixes = ['/challenges/new', '/review'];
  const parentOnlyPrefixes = ['/link-child', '/children'];
  const studentOnlyExactOrSuffix = ['/badges'];

  if (user.role != UserRole.teacher &&
      teacherOnlyPrefixes.any((p) => path.startsWith(p))) {
    return '/';
  }
  if (user.role != UserRole.parent &&
      parentOnlyPrefixes.any((p) => path.startsWith(p))) {
    return '/';
  }
  if (user.role != UserRole.student &&
      (studentOnlyExactOrSuffix.any((p) => path.startsWith(p)) ||
          path.endsWith('/submit'))) {
    return '/';
  }

  return null;
}

/// authState/currentUser 스트림이 갱신될 때마다 go_router가 redirect를
/// 재평가하도록 알려주는 Listenable.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _authSub = ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
    _userSub = ref.listen(currentUserProvider, (previous, next) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AsyncValue<String?>> _authSub;
  late final ProviderSubscription<AsyncValue<AppUser?>> _userSub;

  @override
  void dispose() {
    _authSub.close();
    _userSub.close();
    super.dispose();
  }
}
