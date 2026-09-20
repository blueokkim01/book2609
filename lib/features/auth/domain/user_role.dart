/// 앱 내 사용자 역할. go_router의 역할 기반 redirect와 Firestore 보안 규칙의
/// `role` 필드가 이 값과 정확히 일치해야 한다.
enum UserRole {
  student,
  teacher,
  parent;

  String get firestoreValue => name;

  static UserRole fromFirestore(String value) => UserRole.values.firstWhere(
        (role) => role.firestoreValue == value,
        orElse: () => throw ArgumentError('알 수 없는 역할 값: $value'),
      );

  String get displayName => switch (this) {
        UserRole.student => '학생',
        UserRole.teacher => '교사',
        UserRole.parent => '학부모',
      };
}
