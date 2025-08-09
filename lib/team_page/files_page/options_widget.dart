import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/loading_widget.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';
import 'package:team_hive/service/files_page/files_notifier.dart';
import 'package:team_hive/team_page/files_page/add_new_folder_dialog.dart';
import 'package:provider/provider.dart';

class OptionsWidget extends StatelessWidget {
  final Team team;
  final ValueNotifier<String> path;
  const OptionsWidget({super.key, required this.path, required this.team});

  void _uploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    if (!context.mounted) return;
    String subPath = path.value;
    subPath = subPath.replaceAll('root', '');
    if (subPath.startsWith('/')) subPath = subPath.substring(1);
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _backBtn(context),
            _homeBtn(context),
          ],
        ),
        if (team.isOwner(context.read<BackendService>().user))
          Row(
            children: [
              _newFolderBtn(context),
              _uploadBtn(context),
            ],
          ),
      ],
    );
  }

  Widget _homeBtn(BuildContext context) {
    return InkWell(
      onTap: () {
        // path.value = "root";
        context.read<FilesNotifier>().goToHome();
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          spacing: 10,
          children: [
            Icon(Icons.home_outlined, color: Style.sec),
            ValueListenableBuilder(
                valueListenable: path,
                builder: (context, value, child) {
                  final p = value.replaceAll('root', '');
                  if (p.isEmpty) return const SizedBox.shrink();
                  return Text(p,
                      style: const TextStyle(fontWeight: FontWeight.bold));
                })
          ],
        ),
      ),
    );
  }

  Widget _backBtn(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<FilesNotifier>().back();
      },
      icon: Icon(Icons.arrow_back_outlined, color: Style.sec),
    );
  }

  Widget _newFolderBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        final name = await AddNewFolderDialog.show(context) ?? 'New Folder';
        final files = team.files.parsePath(path.value);
        for (final file in files.children) {
          if (file.name == name) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Folder with this name already exists")));
            return;
          }
        }
        files.children.add(HiveFileSystem(name: name, children: []));
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

  Widget _uploadBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () => _uploadFile(context),
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
