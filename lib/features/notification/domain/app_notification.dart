import 'package:equatable/equatable.dart';

/// 알림 종류. Cloud Functions가 어떤 이벤트로 이 알림을 생성했는지 나타낸다.
enum NotificationType {
  submissionApproved,
  submissionRejected,
  challengeDeadline;

  String get firestoreValue => name;

  static NotificationType fromFirestore(String value) =>
      NotificationType.values.firstWhere(
        (t) => t.firestoreValue == value,
        orElse: () => throw ArgumentError('알 수 없는 알림 유형: $value'),
      );
}

/// `users/{uid}/notifications/{id}` 문서를 표현하는 도메인 엔티티.
///
/// 이 문서는 Cloud Functions가 FCM 발송과 함께 기록하는 인앱 알림 이력이다.
/// 클라이언트는 읽음 처리(read)만 write할 수 있고, 알림 생성은 서버만 한다.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  @override
  List<Object?> get props => [id, type, title, body, createdAt, read];
}
