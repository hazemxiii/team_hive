import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';

class OptionsWidget extends StatelessWidget {
  final Team team;
  final ValueNotifier<String> path;
  const OptionsWidget({super.key, required this.path, required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _backBtn(),
            _homeBtn(),
          ],
        ),
        if (team.isOwner(context.read<BackendService>().user))
          Row(
            children: [
              _newFolderBtn(),
              _uploadBtn(),
            ],
          ),
      ],
    );
  }

  Widget _homeBtn() {
    return InkWell(
      onTap: () {
        path.value = "root";
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          spacing: 10,
          children: [
            Icon(Icons.home_outlined, color: Style.sec),
            ValueListenableBuilder(
                valueListenable: path,
                builder: (context, value, child) {
                  return Text(value.replaceAll('root', ''),
                      style: const TextStyle(fontWeight: FontWeight.bold));
                })
          ],
        ),
      ),
    );
  }

  Widget _backBtn() {
    return IconButton(
      onPressed: () {
        path.value = path.value.substring(0, path.value.lastIndexOf('/'));
      },
      icon: Icon(Icons.arrow_back_outlined, color: Style.sec),
    );
  }

  Widget _newFolderBtn() {
    return MaterialButton(
      onPressed: () {
        final files = team.files.parsePath(path.value);
        files.children.add(HiveFileSystem(name: "New Folder", children: []));
        path.value = "${path.value}/";
        path.value = path.value.substring(0, path.value.length - 1);
      },
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.create_new_folder_outlined, color: Style.sec),
          const Text("New Folder",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _uploadBtn() {
    return MaterialButton(
      onPressed: () {},
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.upload_file_outlined, color: Style.sec),
          const Text("Upload", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
