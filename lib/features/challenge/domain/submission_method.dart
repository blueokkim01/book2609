/// 인증 제출 시 사진 외에 추가로 요구되는 방식.
///
/// 사진 인증은 항상 필수이며(요구사항 3), 이 enum은 그 외에 챌린지가
/// 요구하는 "1개 이상"의 추가 인증 방식을 나타낸다.
enum SubmissionMethod {
  review,
  quiz;

  String get firestoreValue => name;

  static SubmissionMethod fromFirestore(String value) =>
      SubmissionMethod.values.firstWhere(
        (method) => method.firestoreValue == value,
        orElse: () => throw ArgumentError('알 수 없는 인증 방식: $value'),
      );

  String get displayName => switch (this) {
        SubmissionMethod.review => '독후감/한줄평',
        SubmissionMethod.quiz => '퀴즈(OX/객관식)',
      };
}
