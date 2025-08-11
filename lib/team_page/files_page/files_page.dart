// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/files_page/files_notifier.dart';
import 'package:team_hive/team_page/files_page/directory_widget.dart';
import 'package:team_hive/team_page/files_page/options_widget.dart';

class FilesPage extends StatefulWidget {
  final Team team;
  const FilesPage({super.key, required this.team});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Style.section),
      ),
      child: Column(
        spacing: 20,
        children: [
          OptionsWidget(team: widget.team),
          Expanded(
            child: Consumer<FilesNotifier>(
              builder: (context, value, child) {
                final files = value.cwdFiles;
                return ListView.builder(
                    itemCount: files.children.length,
                    itemBuilder: (context, index) {
                      return DirectoryWidget(directory: files.children[index]);
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
