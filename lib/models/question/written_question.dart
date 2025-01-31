import 'package:team_hive/models/question/question.dart';

class WrittenQuestion implements Question {
  @override
  double mark;

  @override
  String text;

  String answer;

  WrittenQuestion({this.mark = 0, this.text = "", this.answer = ""});
}
