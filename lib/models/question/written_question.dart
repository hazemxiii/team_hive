import 'package:team_hive/models/question/question.dart';

class WrittenQuestion implements Question {
  @override
  double totalMark;

  @override
  String text;

  String answer;

  WrittenQuestion({this.totalMark = 1, this.text = "", this.answer = ""});

  @override
  bool isAnswered() => answer.trim() != "";

  @override
  Map<String, dynamic> encode() =>
      {"text": text, "answer": answer, "mark": totalMark, "type": 0};

  @override
  bool isQuestionCorrect() => true;

  @override
  double mark() {
    // TODO: implement mark
    return 0;
  }
}
