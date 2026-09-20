import 'package:flutter/material.dart';

import '../../domain/user_role.dart';

/// 회원가입 시 학생/교사/학부모 역할을 선택하는 세그먼트 위젯.
class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      segments: UserRole.values
          .map((role) => ButtonSegment(
                value: role,
                label: Text(role.displayName),
              ))
          .toList(),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
