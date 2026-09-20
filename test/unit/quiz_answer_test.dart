import 'package:flutter_test/flutter_test.dart';
import 'package:reading_challenge/features/submission/domain/quiz_answer.dart';

void main() {
  group('QuizAnswer', () {
    test('toMap/fromMap 라운드트립이 값을 보존한다', () {
      const answer = QuizAnswer(question: '주인공의 이름은?', selectedOption: '어린왕자');

      final map = answer.toMap();
      final restored = QuizAnswer.fromMap(map);

      expect(restored, answer);
    });
  });
}
