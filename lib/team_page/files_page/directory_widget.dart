import 'package:flutter/material.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/service/files_page/files_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectoryWidget extends StatefulWidget {
  final HiveFileSystem directory;
  const DirectoryWidget({super.key, required this.directory});

  @override
  State<DirectoryWidget> createState() => _DirectoryWidgetState();
}

class _DirectoryWidgetState extends State<DirectoryWidget> {
  bool isFile = false;
  @override
  void initState() {
    super.initState();
  }

  void _onTap() {
    if (context.read<FilesNotifier>().selectedFiles.isNotEmpty) {
      context.read<FilesNotifier>().selectFile(widget.directory);
      return;
    }
    if (isFile) {
      _downloadFile(context);
    } else {
      context.read<FilesNotifier>().goToDirectory(widget.directory);
    }
  }

  void _onLongPress() {
    if (context.read<FilesNotifier>().selectedFiles.isNotEmpty) {
      return;
    }
    context.read<FilesNotifier>().selectFile(widget.directory);
  }

  void _downloadFile(BuildContext context) async {
    try {
      await launchUrl(Uri.parse((widget.directory as HiveFile).content),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      debugPrint("Error opening file: ${e.toString()}");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to open file")));
    }
  }

  Color _getBackgroundColor() {
    if (context.read<FilesNotifier>().isSelected(widget.directory)) {
      return Style.sec.withValues(alpha: 0.1);
    }
    if (context.read<FilesNotifier>().isFileMoving(widget.directory)) {
      return Style.section;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    isFile = widget.directory is HiveFile;

    return InkWell(
      onLongPress: () => _onLongPress(),
      onTap: () => _onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              isFile ? Icons.file_present_outlined : Icons.folder_open_outlined,
              color: Style.sec,
            ),
            Text(widget.directory.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
