import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';
import 'notification_dto.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  @override
  Future<void> registerFcmToken(String uid) async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _firestore
        .collection(FirestorePaths.userFcmTokens(uid))
        .doc(token)
        .set({'createdAt': FieldValue.serverTimestamp()});

    _messaging.onTokenRefresh.listen((newToken) {
      _firestore
          .collection(FirestorePaths.userFcmTokens(uid))
          .doc(newToken)
          .set({'createdAt': FieldValue.serverTimestamp()});
    });
  }

  @override
  Future<void> unregisterFcmToken(String uid) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _firestore
        .collection(FirestorePaths.userFcmTokens(uid))
        .doc(token)
        .delete();
  }

  @override
  Stream<List<AppNotification>> watchMyNotifications(String uid) {
    return _firestore
        .collection(FirestorePaths.userNotifications(uid))
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationDto.fromSnapshot).toList());
  }

  @override
  Future<void> markRead(String uid, String notificationId) {
    return _firestore
        .collection(FirestorePaths.userNotifications(uid))
        .doc(notificationId)
        .update({'read': true});
  }
}
