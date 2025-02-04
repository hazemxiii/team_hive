import 'package:flutter/material.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/user.dart';

class Team {
  late String _name;
  late MyUser _owner;
  late String _id;
  late List<Quiz> _quizzes;
  late Color _color;
  Team(
      {required String name,
      required Color color,
      required MyUser owner,
      required String id,
      List<Quiz> quizzes = const []}) {
    _name = name;
    _owner = owner;
    _color = color;
    _id = id;
    _quizzes = quizzes;
  }

  void updateQuizzes(List<Quiz> quizzes, bool append) {
    _quizzes = [if (append) ..._quizzes, ...quizzes];
  }

  bool isOwner(MyUser user) {
    return user.email == _owner.email;
  }

  String get name => _name;
  String get id => _id;
  Color get color => _color;
  MyUser get owner => _owner;
  List<Quiz> get quizzes => _quizzes;
}
