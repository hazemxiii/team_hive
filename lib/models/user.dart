import 'package:team_hive/models/team.dart';

class MyUser {
  MyUser(
      {required String email,
      required String fName,
      required String lName,
      required List<Team> teams,
      required bool isPremium,
      String uid = ""}) {
    _email = email;
    _fName = fName;
    _lName = lName;
    _teams = teams;
    _uid = uid;
    _isPremium = isPremium;
  }

  late String _email;
  late String _fName;
  late String _lName;
  late String _uid;
  late List<Team> _teams;
  late bool _isPremium;

  void setTeams(List<Team> teams) {
    _teams = teams;
  }

  void setName(String fName, String lName) {
    _fName = fName;
    _lName = lName;
  }

  String get email => _email;
  String get fName {
    if (_fName == "") {
      return ".";
    }
    return _fName;
  }

  String get lName {
    if (_lName == "") {
      return ".";
    }
    return _lName;
  }

  bool get isPremium => _isPremium;
  String get uid => _uid;
  List<Team> get teams => _teams;
}
