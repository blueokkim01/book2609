import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/notification_providers.dart';
import '../domain/app_notification.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  IconData _iconFor(NotificationType type) => switch (type) {
        NotificationType.submissionApproved => Icons.celebration_rounded,
        NotificationType.submissionRejected => Icons.info_outline_rounded,
        NotificationType.challengeDeadline => Icons.alarm_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final dateFormat = DateFormat('MM.dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('알림')),
      body: AsyncValueView(
        value: notificationsAsync,
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('아직 알림이 없어요.'));
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                leading: Icon(_iconFor(n.type)),
                title: Text(n.title,
                    style: TextStyle(
                        fontWeight:
                            n.read ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.body),
                trailing: Text(dateFormat.format(n.createdAt)),
              );
            },
          );
        },
      ),
    );
  }
}
