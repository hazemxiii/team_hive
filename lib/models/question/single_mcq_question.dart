import 'package:team_hive/models/question/mcq_question.dart';

class SingleMcqQuestion implements McqQuestion {
  @override
  List<String> choices = [];

  @override
  String text;

  String? correctAnswer;

  String? answer;

  @override
  double totalMark;

  SingleMcqQuestion(
      {this.text = "",
      this.answer,
      List<String> choices = const [],
      this.totalMark = 1,
      this.correctAnswer}) {
    this.choices.addAll(choices);
  }

  @override
  bool isAnswered() => answer != null;

  @override
  Map<String, dynamic> encode() {
    return {
      "choices": choices,
      "text": text,
      "answer": answer,
      "mark": totalMark,
      "correct": correctAnswer,
      "type": 1
    };
  }

  @override
  bool isChoiceCorrect(String choice) => choice == correctAnswer;

  @override
  bool? isQuestionCorrect() {
    if (!hasCorrectAnswer()) {
      return null;
    }
    if (answer == correctAnswer) {
      return true;
    }
    return false;
  }

  @override
  bool hasCorrectAnswer() => correctAnswer != null;

  @override
  double mark() {
    if (isQuestionCorrect() ?? false) {
      return totalMark;
    }
    return 0;
  }
}
