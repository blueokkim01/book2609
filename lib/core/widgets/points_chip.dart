import 'package:flutter/material.dart';

/// 사용자의 누적 포인트를 표시하는 칩.
///
/// ⚠️ 표시 전용 위젯이다. 이 위젯은 포인트 값을 절대 계산하거나 수정하지
/// 않으며, `users/{uid}.points`(서버 권위 필드)를 읽어 보여주기만 한다.
class PointsChip extends StatelessWidget {
  const PointsChip({super.key, required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: const Icon(Icons.stars_rounded, size: 18),
      label: Text('$points P'),
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
    );
  }
}
