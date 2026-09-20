import 'package:equatable/equatable.dart';

/// `badges/{badgeId}` 카탈로그 문서를 표현하는 도메인 엔티티.
///
/// 이 엔티티는 뱃지의 "정의"(이름, 설명, 아이콘, 표시용 달성 조건 설명)만
/// 담는다. 실제로 어떤 학생이 이 뱃지를 획득했는지는 `users/{uid}.badgeIds`
/// (서버 전용 쓰기 필드)로 판단하며, 이 feature는 그 목록을 표시만 한다.
class ReadingBadge extends Equatable {
  const ReadingBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.criteriaDescription,
  });

  final String id;
  final String name;
  final String description;

  /// Material 아이콘 이름 등 표시용 식별자.
  final String iconName;

  /// "책 5권 완독 시 획득" 처럼 UI에 보여줄 조건 설명.
  /// ⚠️ 실제 부여 조건 판정 로직이 아니라 표시용 문구다.
  final String criteriaDescription;

  @override
  List<Object?> get props => [id, name, description, iconName, criteriaDescription];
}
