import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';
import 'package:team_hive/service/files_page/files_notifier.dart';
import 'package:team_hive/team_page/files_page/confirm_delete_files_dialog.dart';
import 'package:team_hive/team_page/files_page/rename_file_dialog.dart';

class OptionsWidget extends StatelessWidget {
  final Team team;
  const OptionsWidget({super.key, required this.team});

  void _deleteFiles(BuildContext context) async {
    final confirm = await ConfirmDeleteFilesDialog.show(context);
    if (!confirm) return;
    if (!context.mounted) return;
    final success = await context.read<FilesNotifier>().deleteFile();
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to delete file")));
    }
  }

  void _renameFile(BuildContext context) async {
    HiveFileSystem file = context.read<FilesNotifier>().selectedFiles.first;
    final name = await RenameFileDialog.show(context, file.name);
    if (name?.isEmpty ?? true) return;
    if (!context.mounted) return;
    final error = await context.read<FilesNotifier>().renameFile(file, name!);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
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
        if (team.isOwner(BackendService().user))
          Row(
            children: [
              _newFolderBtn(context),
              _uploadBtn(context),
              if (context.watch<FilesNotifier>().selectedFiles.isNotEmpty) ...[
                _deleteBtn(context),
                _deselectAllBtn(context),
                _markFilesAsMovingBtn(context),
              ],
              if (context.watch<FilesNotifier>().isPendingMove)
                _moveFilesBtn(context),
              if (context.watch<FilesNotifier>().selectedFiles.length == 1)
                _renameBtn(context),
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

  Widget _deleteBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () => _deleteFiles(context),
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.delete_outlined, color: Style.sec),
          const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _deselectAllBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () => context.read<FilesNotifier>().deselectAll(),
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.remove_outlined, color: Style.sec),
          const Text("Deselect All",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _markFilesAsMovingBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () => context.read<FilesNotifier>().markFilesAsMoving(),
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.cut_outlined, color: Style.sec),
          const Text("Move", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _moveFilesBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () => context.read<FilesNotifier>().moveFiles(),
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.paste_outlined, color: Style.sec),
          const Text("Move Here",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _renameBtn(BuildContext context) {
    return MaterialButton(
      onPressed: () => _renameFile(context),
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.edit_outlined, color: Style.sec),
          const Text("Rename", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
