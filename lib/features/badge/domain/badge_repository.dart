import 'badge.dart';

/// 뱃지 "카탈로그" 조회 전용 저장소.
///
/// ⚠️ 이 인터페이스에는 뱃지를 부여(write)하는 메서드가 존재하지 않는다.
/// 뱃지 부여는 오직 Cloud Functions(`onSubmissionApproved.ts`)만 수행하며,
/// 클라이언트는 읽기 전용이다.
abstract class BadgeRepository {
  Stream<List<ReadingBadge>> watchAllBadges();
}
