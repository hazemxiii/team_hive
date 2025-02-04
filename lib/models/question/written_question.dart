import 'package:team_hive/models/question/question.dart';

class WrittenQuestion implements Question {
  @override
  double mark;

  @override
  String text;

  String answer;

  WrittenQuestion({this.mark = 1, this.text = "", this.answer = ""});

  @override
  bool isAnswered() => answer.trim() != "";

  @override
  Map<String, dynamic> encode() =>
      {"text": text, "answer": answer, "mark": mark, "type": 0};
}
