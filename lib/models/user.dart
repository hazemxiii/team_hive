import 'package:team_hive/models/team.dart';

class MyUser {
  MyUser(
      {required String email,
      required String fName,
      required String lName,
      required List<Team> teams,
      String uid = ""}) {
    _email = email;
    _fName = fName;
    _lName = lName;
    _teams = teams;
    _uid = uid;
  }

  late String _email;
  late String _fName;
  late String _lName;
  late String _uid;
  late List<Team> _teams;

  void setTeams(List<Team> teams) {
    _teams = teams;
  }

  String get email => _email;
  String get fName => _fName;
  String get lName => _lName;
  String get uid => _uid;
  List<Team> get teams => _teams;
}
