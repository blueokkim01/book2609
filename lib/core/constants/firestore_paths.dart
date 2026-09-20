/// Firestore 컬렉션/문서 경로를 한 곳에서 관리한다.
///
/// 문자열 경로를 여기저기 하드코딩하지 않고 이 클래스를 통해서만 참조함으로써
/// 오타를 방지하고, 보안 규칙(firestore.rules)과 스키마를 항상 일치시킨다.
class FirestorePaths {
  const FirestorePaths._();

  static const String users = 'users';
  static const String challenges = 'challenges';
  static const String submissions = 'submissions';
  static const String badges = 'badges';
  static const String guardianLinks = 'guardianLinks';
  static const String reports = 'reports';

  static String userDoc(String uid) => '$users/$uid';

  /// 사용자의 FCM 토큰 서브컬렉션. 클라이언트는 본인 토큰만 read/write 가능.
  static String userFcmTokens(String uid) => '$users/$uid/fcmTokens';

  /// 사용자의 인앱 알림 이력 서브컬렉션. 생성은 Cloud Functions만 수행하며,
  /// 클라이언트는 read와 read 필드 갱신만 가능하다.
  static String userNotifications(String uid) => '$users/$uid/notifications';

  static String challengeDoc(String challengeId) => '$challenges/$challengeId';

  static String submissionDoc(String submissionId) =>
      '$submissions/$submissionId';

  static String badgeDoc(String badgeId) => '$badges/$badgeId';

  static String guardianLinkDoc(String linkId) => '$guardianLinks/$linkId';

  static String reportDoc(String reportId) => '$reports/$reportId';

  /// Cloud Storage 상의 인증 사진 경로.
  /// storage.rules와 반드시 동일한 패턴을 유지해야 한다.
  static String submissionPhotoStoragePath({
    required String uid,
    required String submissionId,
    required String fileName,
  }) =>
      'submission_photos/$uid/$submissionId/$fileName';
}
