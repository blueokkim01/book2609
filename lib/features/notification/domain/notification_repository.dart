import 'app_notification.dart';

/// FCM 토큰 등록과 인앱 알림 이력 조회/읽음 처리를 담당하는 저장소.
///
/// ⚠️ 알림 "생성"은 Cloud Functions만 수행한다(승인/반려/마감임박 트리거).
/// 클라이언트는 토큰 등록과 읽음 처리만 write할 수 있다.
abstract class NotificationRepository {
  /// 현재 기기의 FCM 토큰을 `users/{uid}/fcmTokens/{token}`에 등록한다.
  Future<void> registerFcmToken(String uid);

  Future<void> unregisterFcmToken(String uid);

  Stream<List<AppNotification>> watchMyNotifications(String uid);

  Future<void> markRead(String uid, String notificationId);
}
