import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/core/utils/profanity_filter.dart';

void main() {
  group('ProfanityFilter', () {
    test('금칙어가 포함되면 true를 반환한다', () {
      expect(ProfanityFilter.containsProfanity('너 진짜 바보야'), isTrue);
    });

    test('공백을 섞어도 정상적으로 감지한다', () {
      expect(ProfanityFilter.containsProfanity('너 진 짜 바 보 야'), isTrue);
    });

    test('일반 텍스트는 false를 반환한다', () {
      expect(
        ProfanityFilter.containsProfanity('이 책은 정말 감동적이었어요'),
        isFalse,
      );
    });

    test('mask는 금칙어를 동일한 길이의 *로 치환한다', () {
      final masked = ProfanityFilter.mask('바보 같은 소리');
      expect(masked, '** 같은 소리');
    });
  });
}
