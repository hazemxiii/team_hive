import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';
import 'package:team_hive/models/question/written_question.dart';

interface class Question {
  double mark;
  String text;

  Question({this.text = "", this.mark = 1});

  bool isAnswered() => true;

  Map<String, dynamic> encode() => {};

  static Question decode(Map<String, dynamic> encoded) {
    String txt = encoded['text'];
    double mark = encoded['mark'];
    switch (encoded['type']) {
      case 0:
        return WrittenQuestion(
            text: txt, mark: mark, answer: encoded['answer'] ?? "");
      case 1:
        return SingleMcqQuestion(
            text: txt,
            mark: mark,
            choices: List<String>.from(encoded['choices'] ?? []),
            answer: encoded['answer'],
            correctAnswer: encoded['correct']);
      case 2:
        return MultiMcqQuestion(
            text: txt,
            mark: mark,
            choices: List<String>.from(encoded['choices'] ?? []),
            correctChoices: List<String>.from(encoded['correct'] ?? []));
    }
    throw "Unkown Question Type";
  }
}
