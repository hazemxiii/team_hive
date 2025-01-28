import 'package:flutter/material.dart';
import 'package:team_hive/models/user.dart';

class Team {
  late String _name;
  late MyUser _owner;
  late String _id;
  List<MyUser> _members = [];
  late Color _color;
  Team(
      {required String name,
      required Color color,
      required MyUser owner,
      required String id}) {
    _name = name;
    _owner = owner;
    _color = color;
    _id = id;
  }

  List<MyUser> getMembers(BuildContext context) {
    return _members;
  }

  String get name => _name;
  String get id => _id;
  Color get color => _color;
  MyUser get owner => _owner;
}
