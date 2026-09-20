import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/challenge.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key, required this.challenge, this.onTap});

  final Challenge challenge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final deadlineNear = challenge.period.isDeadlineNear;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(challenge.title),
        subtitle: Text(
          '${dateFormat.format(challenge.period.start)} ~ '
          '${dateFormat.format(challenge.period.end)}',
        ),
        trailing: deadlineNear
            ? const Chip(
                label: Text('마감임박'),
                backgroundColor: Color(0xFFFFE0B2),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
