import 'package:flutter/material.dart';

import '../../domain/badge.dart';

const _iconMap = <String, IconData>{
  'emoji_events': Icons.emoji_events_rounded,
  'menu_book': Icons.menu_book_rounded,
  'local_fire_department': Icons.local_fire_department_rounded,
  'star': Icons.star_rounded,
};

class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.badge, this.earned = true});

  final ReadingBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[badge.iconName] ?? Icons.emoji_events_rounded;
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: earned ? 1 : 0.35,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(icon, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(height: 8),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                badge.criteriaDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
