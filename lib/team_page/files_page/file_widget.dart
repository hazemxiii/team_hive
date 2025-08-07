import 'package:flutter/material.dart';
import 'package:team_hive/models/file_system.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FileWidget extends StatelessWidget {
  const FileWidget({super.key, required this.file});

  final HiveFile file;

  void _downloadFile(BuildContext context) async {
    try {
      await launchUrl(Uri.parse(file.content),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      debugPrint("Error opening file: ${e.toString()}");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to open file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _downloadFile(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              Icons.file_present_outlined,
              color: Style.sec,
            ),
            Text(file.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
