import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/user_role.dart';

class _TabDestination {
  const _TabDestination(this.path, this.icon, this.label);
  final String path;
  final IconData icon;
  final String label;
}

/// 역할별 하단 탭 내비게이션을 제공하는 공통 쉘.
///
/// go_router의 `ShellRoute` builder에서 사용되며, 현재 위치를 기반으로
/// 선택된 탭을 계산한다.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.role, required this.child});

  final UserRole role;
  final Widget child;

  List<_TabDestination> get _destinations => switch (role) {
        UserRole.student => const [
            _TabDestination('/', Icons.menu_book_rounded, '챌린지'),
            _TabDestination('/badges', Icons.emoji_events_rounded, '뱃지'),
            _TabDestination(
                '/notifications', Icons.notifications_rounded, '알림'),
            _TabDestination('/my-page', Icons.person_rounded, '마이페이지'),
          ],
        UserRole.teacher => const [
            _TabDestination('/', Icons.menu_book_rounded, '챌린지 관리'),
            _TabDestination('/review', Icons.fact_check_rounded, '인증 검토'),
            _TabDestination(
                '/notifications', Icons.notifications_rounded, '알림'),
            _TabDestination('/my-page', Icons.person_rounded, '마이페이지'),
          ],
        UserRole.parent => const [
            _TabDestination('/', Icons.family_restroom_rounded, '자녀 현황'),
            _TabDestination(
                '/notifications', Icons.notifications_rounded, '알림'),
            _TabDestination('/my-page', Icons.person_rounded, '마이페이지'),
          ],
      };

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final destinations = _destinations;
    final index = destinations.indexWhere((d) => location.startsWith(d.path) && d.path != '/');
    if (index != -1) return index;
    return location == '/' ? 0 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(destinations[index].path),
        destinations: destinations
            .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
            .toList(),
      ),
    );
  }
}
