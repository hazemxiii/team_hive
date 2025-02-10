import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';
import 'package:team_hive/models/question/written_question.dart';

interface class Question {
  double totalMark;
  String text;

  Question({this.text = "", this.totalMark = 1});

  bool isAnswered() => true;
  bool? isQuestionCorrect() => true;
  double mark() => totalMark;

  Map<String, dynamic> encode() => {};

  static Question decode(Map<String, dynamic> encoded) {
    String txt = encoded['text'];
    double mark = encoded['mark'];
    switch (encoded['type']) {
      case 0:
        return WrittenQuestion(
            text: txt, totalMark: mark, answer: encoded['answer'] ?? "");
      case 1:
        return SingleMcqQuestion(
            text: txt,
            totalMark: mark,
            choices: List<String>.from(encoded['choices'] ?? []),
            answer: encoded['answer'],
            correctAnswer: encoded['correct']);
      case 2:
        return MultiMcqQuestion(
            text: txt,
            totalMark: mark,
            choices: List<String>.from(encoded['choices'] ?? []),
            correctChoices: List<String>.from(encoded['correct'] ?? []),
            answer: List<String>.from(encoded['answer'] ?? []));
    }
    throw "Unkown Question Type";
  }
}
