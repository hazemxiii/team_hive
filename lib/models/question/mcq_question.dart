import 'package:team_hive/models/question/question.dart';

interface class McqQuestion extends Question {
  List<String> choices;
  McqQuestion({this.choices = const [""]});
}
