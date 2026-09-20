import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/features/challenge/domain/challenge_period.dart';

void main() {
  group('ChallengePeriod', () {
    test('현재 시각이 기간 내부면 isOngoing은 true다', () {
      final period = ChallengePeriod(
        start: DateTime.now().subtract(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(days: 1)),
      );
      expect(period.isOngoing, isTrue);
    });

    test('종료일이 지나면 isOngoing은 false다', () {
      final period = ChallengePeriod(
        start: DateTime.now().subtract(const Duration(days: 10)),
        end: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(period.isOngoing, isFalse);
    });

    test('마감이 24시간 이내면 isDeadlineNear는 true다', () {
      final period = ChallengePeriod(
        start: DateTime.now().subtract(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(hours: 5)),
      );
      expect(period.isDeadlineNear, isTrue);
    });

    test('마감까지 24시간 넘게 남으면 isDeadlineNear는 false다', () {
      final period = ChallengePeriod(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 3)),
      );
      expect(period.isDeadlineNear, isFalse);
    });

    test('이미 마감이 지났으면 isDeadlineNear는 false다', () {
      final period = ChallengePeriod(
        start: DateTime.now().subtract(const Duration(days: 10)),
        end: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(period.isDeadlineNear, isFalse);
    });
  });
}
