import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_notification.dart';

class NotificationDto {
  const NotificationDto._();

  static AppNotification fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('notifications/${doc.id} 문서가 존재하지 않습니다.');
    }
    return AppNotification(
      id: doc.id,
      type: NotificationType.fromFirestore(data['type'] as String),
      title: data['title'] as String,
      body: data['body'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }
}
