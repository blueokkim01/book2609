/// 인증 제출물의 검토 상태. `submissions/{id}.status`와 정확히 일치해야 한다.
enum SubmissionStatus {
  pending,
  approved,
  rejected;

  String get firestoreValue => name;

  static SubmissionStatus fromFirestore(String value) =>
      SubmissionStatus.values.firstWhere(
        (status) => status.firestoreValue == value,
        orElse: () => throw ArgumentError('알 수 없는 제출 상태: $value'),
      );

  String get displayName => switch (this) {
        SubmissionStatus.pending => '검토 대기',
        SubmissionStatus.approved => '승인됨',
        SubmissionStatus.rejected => '반려됨',
      };
}
