import 'package:flutter/material.dart';
import 'package:team_hive/service/app_colors.dart';

class RenameFileDialog extends StatelessWidget {
  final String oldNameWithExtension;
  const RenameFileDialog({super.key, required this.oldNameWithExtension});

  static Future<String?> show(
      BuildContext context, String oldNameWithExtension) {
    return showDialog(
        context: context,
        builder: (_) =>
            RenameFileDialog(oldNameWithExtension: oldNameWithExtension));
  }

  @override
  Widget build(BuildContext context) {
    final nameParts = oldNameWithExtension.split('.');
    String name = nameParts.first;
    final ext = nameParts.length > 1 ? '.${nameParts.last}' : '';
    return AlertDialog(
      title: const Text("Rename"),
      content: TextField(
        controller: TextEditingController(text: name),
        onChanged: (v) => name = v,
        decoration: InputDecoration(
            hintText: "File Name",
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Style.sec)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Style.sec, width: 2))),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, "$name$ext");
          },
          child: const Text("Rename"),
        ),
      ],
    );
  }
}
