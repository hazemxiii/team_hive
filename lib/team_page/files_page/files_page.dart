import 'package:flutter/material.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/team_page/files_page/file_widget.dart';
import 'package:team_hive/team_page/files_page/directory_widget.dart';
import 'package:team_hive/service/backend.dart';

class FilesPage extends StatefulWidget {
  final Team team;
  const FilesPage({super.key, required this.team});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final _pathNotifier = ValueNotifier("root");

  void _loadFiles() async {
    final files = await BackendService().getTeamFiles(widget.team);
    if (files != null) {
      widget.team.updateFiles(files);
      setState(() {});
    }
  }

  HiveFileSystem _parseFiles() {
    if (_pathNotifier.value == "root") {
      return widget.team.files;
    }
    final path = _pathNotifier.value.split("/");
    path.remove("root");
    HiveFileSystem files = widget.team.files;
    for (var i = 0; i < path.length; i++) {
      files = files.children.firstWhere((element) => element.name == path[i]);
    }
    return files;
  }

  @override
  void initState() {
    _loadFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 1000),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Style.section),
      ),
      child: Column(
        children: [
          _optionsWidget(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _pathNotifier,
              builder: (context, value, child) {
                final files = _parseFiles();
                return ListView.builder(
                    itemCount: files.children.length,
                    itemBuilder: (context, index) {
                      if (files.children[index].isDirectory) {
                        return DirectoryWidget(
                            directory: files.children[index],
                            path: _pathNotifier);
                      } else {
                        return FileWidget(
                            file: files.children[index] as HiveFile);
                      }
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionsWidget() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _pathNotifier.value = "root";
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              spacing: 10,
              children: [
                Icon(Icons.home_outlined, color: Style.sec),
                ValueListenableBuilder(
                    valueListenable: _pathNotifier,
                    builder: (context, value, child) {
                      return Text(value.replaceAll('root', ''),
                          style: const TextStyle(fontWeight: FontWeight.bold));
                      // TODO: options
                    })
              ],
            ),
          ),
        ),
      ],
    );
  }
}
