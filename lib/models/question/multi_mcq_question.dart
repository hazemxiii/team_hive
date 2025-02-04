import 'package:team_hive/models/question/mcq_question.dart';

class MultiMcqQuestion implements McqQuestion {
  @override
  List<String> choices = [];

  @override
  String text = "";

  List<String> correctChoices = [];

  List<String> answer = [];
  @override
  double mark = 0;

  MultiMcqQuestion({
    this.text = "",
    List<String> correctChoices = const [],
    List<String> choices = const [],
    List<String> answer = const [],
    this.mark = 1,
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
        "mark": mark,
        "correct": correctChoices,
        "type": 2
      };
}
