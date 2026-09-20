import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/notification_repository_impl.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

final myNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value(const []);
  return ref.watch(notificationRepositoryProvider).watchMyNotifications(uid);
});

/// 로그인 상태가 되면 자동으로 FCM 토큰을 등록하는 사이드 이펙트 provider.
/// `app.dart`나 최초 인증 화면에서 `ref.watch`하여 활성화한다.
final fcmRegistrationProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return;
  await ref.watch(notificationRepositoryProvider).registerFcmToken(uid);
});
