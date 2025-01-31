import 'package:team_hive/models/question/mcq_question.dart';

class SingleMcqQuestion implements McqQuestion {
  @override
  List<String> choices = [];

  @override
  String text;

  String? correctAnswer;

  String? answer;

  @override
  double mark;

  SingleMcqQuestion(
      {this.text = "",
      this.answer,
      List<String> choices = const [""],
      this.mark = 1,
      this.correctAnswer}) {
    this.choices.addAll(choices);
  }
}
