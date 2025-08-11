import 'package:flutter/material.dart';

class ConfirmDeleteFilesDialog extends StatelessWidget {
  const ConfirmDeleteFilesDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => const ConfirmDeleteFilesDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete files"),
      content: const Text("Are you sure you want to delete these files?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context, true);
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
