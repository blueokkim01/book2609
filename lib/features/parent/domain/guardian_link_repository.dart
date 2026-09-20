import 'guardian_link.dart';

abstract class GuardianLinkRepository {
  Stream<List<GuardianLink>> watchLinksForParent(String parentUid);

  /// 자녀 연결 + 동의 기록을 함께 생성한다.
  ///
  /// [studentUid]는 학교에서 별도로 안내받은 학생 식별 코드를 통해
  /// 확인한다고 가정한다(실제 서비스에서는 본인확인 절차가 추가로 필요하며
  /// 그 처리 로직은 이번 범위 밖이다).
  Future<void> createLink({
    required String parentUid,
    required String studentUid,
    required String consentBy,
  });
}
