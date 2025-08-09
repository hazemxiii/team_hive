import 'package:flutter/material.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/backend.dart';

class FilesNotifier extends ChangeNotifier {
  FilesNotifier({required this.team}) {
    _loadData();
  }

  final Team team;
  String _path = 'root';
  // List<HiveFileSystem> _selectedFiles = [];

  String get path => _path;
  HiveFileSystem get files => team.files;
  HiveFileSystem get cwdFiles => files.parsePath(path);

  Future<void> _loadData() async {
    final files = await BackendService().getTeamFiles(team);
    if (files != null) {
      team.updateFiles(files);
      notifyListeners();
    }
  }

  void goToHome() {
    _path = 'root';
    notifyListeners();
  }

  void back() {
    final pathParts = path.split('/');
    if (pathParts.length == 1) return;
    pathParts.removeLast();
    _path = pathParts.join('/');
    notifyListeners();
  }

  void goToDirectory(HiveFileSystem directory) {
    _path = '$path/${directory.name}';
    notifyListeners();
  }
}
