import 'package:flutter/material.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/team_page/team_settings_page/team_settings_dialog.dart';

class TeamSettingsPage extends StatelessWidget {
  const TeamSettingsPage({super.key, required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Team Settings',
                    style: Style.headingStyle,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Settings for team ${team.name}',
                    style: Style.miniTextStyle,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _deleteBtn(context),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _deleteBtn(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.all(20),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      onPressed: () => ConfirmTeamDeleteDialog.show(context, team),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
          Text(
            "Delete Team",
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    );
  }
}
