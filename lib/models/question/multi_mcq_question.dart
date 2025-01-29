import 'package:team_hive/models/question/mcq_question.dart';

class MultiMcqQuestion implements McqQuestion {
  @override
  List<String> choices = [];

  @override
  String text = "";

  List<String> correctChoices = [];

  @override
  double mark = 0;

  MultiMcqQuestion(
      {this.text = "",
      this.correctChoices = const [""],
      this.choices = const [""],
      this.mark = 1});
}
