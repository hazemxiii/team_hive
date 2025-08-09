import 'package:flutter/material.dart';
import 'package:team_hive/service/app_colors.dart';

class AddNewFolderDialog extends StatelessWidget {
  const AddNewFolderDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog(
        context: context, builder: (_) => const AddNewFolderDialog());
  }

  @override
  Widget build(BuildContext context) {
    String name = 'New Folder';
    return AlertDialog(
      title: const Text("Add New Folder"),
      content: TextField(
        onChanged: (v) => name = v,
        decoration: InputDecoration(
            hintText: "Folder Name",
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
            Navigator.pop(context, name);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
