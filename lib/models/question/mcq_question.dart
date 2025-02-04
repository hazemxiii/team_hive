import 'package:team_hive/models/question/question.dart';

interface class McqQuestion implements Question {
  List<String> choices;
  McqQuestion({
    this.choices = const [""],
    this.text = "",
    this.mark = 1,
  });

  @override
  double mark;

  @override
  String text;

  @override
  bool isAnswered() {
    return true;
  }

  @override
  Map<String, dynamic> encode() => {};
}
