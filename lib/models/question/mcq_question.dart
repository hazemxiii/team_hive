import 'package:team_hive/models/question/question.dart';

interface class McqQuestion implements Question {
  List<String> choices;
  McqQuestion({
    this.choices = const [""],
    this.text = "",
    this.totalMark = 1,
  });

  @override
  double totalMark;

  @override
  String text;

  @override
  bool isAnswered() {
    return true;
  }

  @override
  Map<String, dynamic> encode() => {};

  @override
  bool? isQuestionCorrect() => true;
  bool isChoiceCorrect(String choice) => true;
  bool hasCorrectAnswer() => true;

  @override
  double mark() => totalMark;
}
