import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/features/auth/domain/guardian_consent.dart';

void main() {
  group('GuardianConsent', () {
    test('notConsented는 동의하지 않은 초기 상태를 만든다', () {
      final consent = GuardianConsent.notConsented();
      expect(consent.consented, isFalse);
      expect(consent.consentAt, isNull);
      expect(consent.consentBy, isNull);
    });

    test('withConsent는 동의 시각/주체를 기록한 새 인스턴스를 만든다', () {
      final before = GuardianConsent.notConsented();
      final at = DateTime(2026, 1, 1, 9);
      final after = before.withConsent(at: at, by: '보호자1');

      expect(after.consented, isTrue);
      expect(after.consentAt, at);
      expect(after.consentBy, '보호자1');
      // 원본은 변경되지 않는다(불변 객체).
      expect(before.consented, isFalse);
    });

    test('toMap/fromMap 라운드트립이 값을 보존한다', () {
      final original = GuardianConsent(
        consented: true,
        consentAt: DateTime(2026, 3, 5, 10, 30),
        consentBy: '보호자',
      );

      final restored = GuardianConsent.fromMap(original.toMap());

      expect(restored, original);
    });
  });
}
