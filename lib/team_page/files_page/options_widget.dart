import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';
import 'package:team_hive/service/files_page/files_notifier.dart';

class OptionsWidget extends StatelessWidget {
  final Team team;
  const OptionsWidget({super.key, required this.team});

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
      onTap: () => context.read<FilesNotifier>().goToHome(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          spacing: 10,
          children: [
            Icon(Icons.home_outlined, color: Style.sec),
            Consumer<FilesNotifier>(builder: (context, value, child) {
              final p = value.path.replaceAll('root', '');
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
      onPressed: () => context.read<FilesNotifier>().back(),
      icon: Icon(Icons.arrow_back_outlined, color: Style.sec),
    );
  }

  Widget _newFolderBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () => context.read<FilesNotifier>().newFolder(context),
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
      onPressed: () => context.read<FilesNotifier>().uploadFile(context),
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
