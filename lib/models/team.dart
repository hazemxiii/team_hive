import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/user.dart';
import 'package:team_hive/models/file_system.dart';

class Team {
  late String _name;
  late MyUser _owner;
  late String _id;
  late List<Quiz> _quizzes;
  late HiveFileSystem _files;
  // late Color _color;
  Team(
      {required String name,
      // Color? color,
      required MyUser owner,
      required String id,
      List<Quiz> quizzes = const [],
      HiveFileSystem? files}) {
    _name = name;
    _owner = owner;
    // _color = color;
    _id = id;
    _quizzes = quizzes;
    _files = files ?? HiveFileSystem(name: "root", children: []);
  }

  void updateFiles(HiveFileSystem files) {
    _files = files;
  }

  void updateQuizzes(List<Quiz> quizzes, bool append) {
    _quizzes = [if (append) ..._quizzes, ...quizzes];
  }

  bool isOwner(MyUser user) {
    return user.email == _owner.email;
  }

  String get name => _name;
  String get id => _id;
  // Color get color => _color;
  MyUser get owner => _owner;
  List<Quiz> get quizzes => _quizzes;
  HiveFileSystem get files => _files;
}
