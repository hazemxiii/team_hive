import 'package:flutter/material.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/service/app_colors.dart';

class FileWidget extends StatelessWidget {
  const FileWidget({super.key, required this.file});

  final HiveFile file;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Icon(
          Icons.file_open_outlined,
          color: Style.sec,
        ),
        Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
