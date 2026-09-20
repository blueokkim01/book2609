import 'package:equatable/equatable.dart';

/// 학생이 제출한 퀴즈 응답 한 문항.
/// 정답 채점 로직은 없다 — 교사가 육안으로 검토해 승인/반려를 결정한다.
class QuizAnswer extends Equatable {
  const QuizAnswer({required this.question, required this.selectedOption});

  final String question;
  final String selectedOption;

  Map<String, dynamic> toMap() => {
        'question': question,
        'selectedOption': selectedOption,
      };

  factory QuizAnswer.fromMap(Map<String, dynamic> map) => QuizAnswer(
        question: map['question'] as String,
        selectedOption: map['selectedOption'] as String,
      );

  @override
  List<Object?> get props => [question, selectedOption];
}
