import 'package:equatable/equatable.dart';

import 'challenge_period.dart';
import 'submission_method.dart';

/// `challenges/{challengeId}` 문서를 표현하는 도메인 엔티티.
class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.period,
    required this.schoolCode,
    required this.classCode,
    required this.targetBookCount,
    required this.targetBooks,
    required this.requiredMethods,
    required this.createdAt,
  });

  final String id;
  final String teacherId;
  final String title;
  final String description;
  final ChallengePeriod period;
  final String schoolCode;
  final String classCode;

  /// 목표 권수. 지정 도서 목록 방식이면 null일 수 있다.
  final int? targetBookCount;

  /// 지정 도서 목록. 자유 도서 선택 방식이면 비어 있을 수 있다.
  final List<String> targetBooks;

  /// 사진 인증 외 추가로 요구하는 인증 방식(1개 이상).
  final List<SubmissionMethod> requiredMethods;

  final DateTime createdAt;

  bool get usesTargetBookList => targetBooks.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        teacherId,
        title,
        description,
        period,
        schoolCode,
        classCode,
        targetBookCount,
        targetBooks,
        requiredMethods,
        createdAt,
      ];
}
