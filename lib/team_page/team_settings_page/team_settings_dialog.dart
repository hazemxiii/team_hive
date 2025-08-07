import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/home_page.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/backend.dart';

class ConfirmTeamDeleteDialog extends StatelessWidget {
  static Future<void> show(BuildContext context, Team team) async {
    return showDialog(
        context: context, builder: (_) => ConfirmTeamDeleteDialog(team: team));
  }

  final Team team;
  const ConfirmTeamDeleteDialog({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Team"),
      content: const Text("Are you sure you want to delete this team?"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              context.read<BackendService>().deleteTeam(team.id);
              Navigator.of(context).pop();
              context.read<BackendService>().user.teams.remove(team);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (_) => false);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ))
      ],
    );
  }
}
