import 'package:team_hive/models/question/mcq_question.dart';

class SingleMcqQuestion implements McqQuestion {
  @override
  List<String> choices;

  @override
  String text;

  String choice;

  @override
  double mark;

  SingleMcqQuestion(
      {this.text = "",
      this.choice = "",
      this.choices = const [""],
      this.mark = 1});
}
