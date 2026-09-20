import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/features/submission/domain/submission_status.dart';

void main() {
  group('SubmissionStatus', () {
    test('pending -> approved -> rejected 상태 전이 값이 Firestore와 일치한다', () {
      expect(SubmissionStatus.pending.firestoreValue, 'pending');
      expect(SubmissionStatus.approved.firestoreValue, 'approved');
      expect(SubmissionStatus.rejected.firestoreValue, 'rejected');
    });

    test('fromFirestore는 문자열을 올바른 enum으로 변환한다', () {
      expect(SubmissionStatus.fromFirestore('approved'), SubmissionStatus.approved);
      expect(SubmissionStatus.fromFirestore('rejected'), SubmissionStatus.rejected);
      expect(SubmissionStatus.fromFirestore('pending'), SubmissionStatus.pending);
    });

    test('알 수 없는 상태 문자열은 예외를 던진다', () {
      expect(
        () => SubmissionStatus.fromFirestore('unknown-status'),
        throwsArgumentError,
      );
    });
  });
}
