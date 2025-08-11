import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/loading_widget.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/backend.dart';
import 'package:team_hive/team_page/files_page/add_new_folder_dialog.dart';

class FilesNotifier extends ChangeNotifier {
  FilesNotifier({required this.team}) {
    _loadData();
  }

  final Team team;
  String _path = 'root';
  List<HiveFileSystem> _selectedFiles = [];

  String get path => _path;
  HiveFileSystem get files => team.files;
  HiveFileSystem get cwdFiles => files.parsePath(path);
  List<HiveFileSystem> get selectedFiles => _selectedFiles;
  bool isSelected(HiveFileSystem file) => _selectedFiles.contains(file);

  Future<void> _loadData() async {
    final files = await BackendService().getTeamFiles(team);
    if (files != null) {
      team.updateFiles(files);
      notifyListeners();
    }
  }

  void goToHome() {
    _path = 'root';
    _selectedFiles = [];
    notifyListeners();
  }

  void back() {
    final pathParts = path.split('/');
    if (pathParts.length == 1) return;
    pathParts.removeLast();
    _path = pathParts.join('/');
    _selectedFiles = [];
    notifyListeners();
  }

  void goToDirectory(HiveFileSystem directory) {
    _path = '$path/${directory.name}';
    _selectedFiles = [];
    notifyListeners();
  }

  Future<void> uploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    String subPath = path;
    subPath = subPath.replaceAll('root', '');
    if (subPath.startsWith('/')) subPath = subPath.substring(1);
    if (!context.mounted) return;
    LoadingWidget.show(context);
    final success = await context.read<BackendService>().uploadTeamFile(
        team: team,
        file: result.files.first.bytes!,
        fileName: result.files.first.name,
        subPath: subPath);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to upload file")));
    }
    Navigator.pop(context);
    _loadData();
  }

  Future<void> newFolder(BuildContext context) async {
    final name = await AddNewFolderDialog.show(context) ?? 'New Folder';
    final files = cwdFiles;
    for (final file in files.children) {
      if (file.name == name) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Folder with this name already exists")));
        return;
      }
    }
    files.children.add(HiveFileSystem(name: name, children: []));
    notifyListeners();
  }

  void selectFile(HiveFileSystem file) {
    if (_selectedFiles.contains(file)) {
      _selectedFiles.remove(file);
    } else {
      _selectedFiles.add(file);
    }
    notifyListeners();
  }

  void deselectAll() {
    _selectedFiles = [];
    notifyListeners();
  }

  Future<bool> deleteFile(BuildContext context) async {
    final paths = <String>[];
    final currentPath = path;
    final pathParts = currentPath.split('/');
    pathParts.remove('root');
    for (final file in _selectedFiles) {
      final path = pathParts.isNotEmpty ? '${pathParts.join('/')}/' : '';
      paths.add('$path${file.name}');
    }
    final success =
        await context.read<BackendService>().deleteTeamFile(team, paths);
    if (!success) return success;
    final files = cwdFiles;
    for (final file in _selectedFiles) {
      files.children.remove(file);
    }
    _selectedFiles = [];
    notifyListeners();
    return true;
  }

  // TODO move
}
