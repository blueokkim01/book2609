/// 앱 전역에서 사용하는 상수 모음.
///
/// ⚠️ 포인트 적립량·뱃지 부여 기준 등 게이미피케이션 "계산" 규칙은 여기에
/// 두지 않는다. 그 값들은 서버(Cloud Functions, `functions/src/badgeRules.ts`)
/// 에만 존재하는 권위 있는(authoritative) 값이며, 클라이언트는 결과를
/// 표시만 한다. 아래 상수는 UI 검증·표시용 비-권위(non-authoritative) 값이다.
class AppConstants {
  const AppConstants._();

  static const String appName = '독서 챌린지';

  // --- 사진 업로드 제약 (UI 사전 검증용. 최종 강제는 storage.rules) ---
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int imageCompressQuality = 80;
  static const int imageMaxDimension = 1600;

  // --- 독후감/한줄평 텍스트 ---
  static const int reviewMinLength = 5;
  static const int reviewMaxLength = 2000;

  // --- 퀴즈 ---
  static const int quizMinOptions = 2;
  static const int quizMaxOptions = 4;

  // --- 가입 코드 ---
  static const int schoolCodeLength = 6;
  static const int classCodeLength = 4;

  // --- 닉네임 (실명 대신 사용, 미성년자 개인정보 최소수집 원칙) ---
  static const int nicknameMinLength = 2;
  static const int nicknameMaxLength = 12;

  // --- 마감 임박 알림 기준 ---
  static const Duration deadlineReminderWindow = Duration(days: 1);
}
