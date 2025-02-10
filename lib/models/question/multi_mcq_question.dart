import 'package:team_hive/models/question/mcq_question.dart';

class MultiMcqQuestion implements McqQuestion {
  @override
  List<String> choices = [];

  @override
  String text = "";

  List<String> correctChoices = [];

  List<String> answer = [];
  @override
  double totalMark = 0;

  MultiMcqQuestion({
    this.text = "",
    List<String> correctChoices = const [],
    List<String> choices = const [],
    List<String> answer = const [],
    this.totalMark = 1,
  }) {
    this.correctChoices.addAll(correctChoices);
    this.choices.addAll(choices);
    this.answer.addAll(answer);
  }

  @override
  bool isAnswered() => answer.isNotEmpty;

  @override
  Map<String, dynamic> encode() => {
        "choices": choices,
        "text": text,
        "answer": answer,
        "mark": totalMark,
        "correct": correctChoices,
        "type": 2
      };

  @override
  bool isChoiceCorrect(String choice) => correctChoices.contains(choice);

  @override
  bool? isQuestionCorrect() {
    if (correctChoices.isEmpty) {
      return null;
    }
    List s = {...answer, ...correctChoices}.toList();
    if (s.length == answer.length && s.length == correctChoices.length) {
      return true;
    }
    return false;
  }

  @override
  bool hasCorrectAnswer() => choices.isNotEmpty;

  @override
  double mark() {
    if (correctChoices.isEmpty) {
      return 0;
    }
    if (answer.length > correctChoices.length) {
      return 0;
    }
    double mark = 0;
    for (String c in answer) {
      if (correctChoices.contains(c)) {
        mark++;
      }
    }
    return mark;
  }
}
