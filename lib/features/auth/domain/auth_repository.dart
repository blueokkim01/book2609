import 'app_user.dart';
import 'user_role.dart';

/// 인증 및 사용자 프로필(가입 시 생성되는 users 문서)에 대한 추상 저장소.
///
/// 구현체는 data 계층(`AuthRepositoryImpl`)에 있으며, 프레젠테이션/애플리케이션
/// 계층은 이 인터페이스에만 의존해 Firebase에 직접 결합되지 않도록 한다.
abstract class AuthRepository {
  /// 현재 로그인된 사용자의 uid 스트림. 로그아웃 상태면 null.
  Stream<String?> authStateChanges();

  /// 로그인된 사용자의 Firestore 프로필 스트림. 프로필이 없으면 null.
  Stream<AppUser?> watchCurrentUserProfile(String uid);

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// 회원가입 + 학교/학급 코드로 그룹 가입 + users 문서 생성.
  ///
  /// [points], [badgeIds]는 서버 기본값(0, [])으로만 생성되며 클라이언트는
  /// 이 필드에 대한 임의 값을 절대 전달하지 않는다.
  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String nickname,
    required String schoolCode,
    required String classCode,
  });

  Future<void> signOut();

  /// 학생 계정에 대해 보호자 동의를 기록한다(guardianLinks 동의와는 별개로
  /// users 문서 자체에도 동의 요약을 남길 수 있다).
  Future<void> recordGuardianConsent({
    required String studentUid,
    required String consentBy,
  });
}
