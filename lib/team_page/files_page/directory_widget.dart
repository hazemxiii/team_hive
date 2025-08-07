import 'package:flutter/material.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/service/app_colors.dart';

class DirectoryWidget extends StatefulWidget {
  final ValueNotifier<String> path;
  final HiveFileSystem directory;
  const DirectoryWidget(
      {super.key, required this.directory, required this.path});

  @override
  State<DirectoryWidget> createState() => _DirectoryWidgetState();
}

class _DirectoryWidgetState extends State<DirectoryWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.path.value += "/${widget.directory.name}";
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              Icons.folder_open_outlined,
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
