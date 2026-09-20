import 'package:firebase_messaging/firebase_messaging.dart';

/// 앱이 백그라운드/종료 상태일 때 FCM 메시지를 받는 최상위 함수.
///
/// Flutter의 제약상 백그라운드 핸들러는 반드시 최상위(top-level) 또는
/// static 함수여야 하며, `main()`에서 등록되어야 한다.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 알림 내용 자체는 FCM 페이로드(notification)로 시스템 트레이가 자동 표시한다.
  // 여기서는 추가 로컬 처리가 필요할 때(예: 배지 카운트 갱신) 확장한다.
}

void registerFcmBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}
