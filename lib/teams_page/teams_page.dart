import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';
import 'package:team_hive/team_page/team_page.dart';
import 'package:team_hive/teams_page/grid_row_view.dart';
import 'package:team_hive/teams_page/join_create_team_dialog.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  late final FirebaseService _firebase;
  List<Team> teams = [];
  final _teamsLoadingNotifier = ValueNotifier(false);

  @override
  initState() {
    _firebase = context.read();
    super.initState();
  }

  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Teams",
                  style: Style.headingStyle,
                ),
                _toggleGridBtn()
              ],
            ),
            ValueListenableBuilder(
                valueListenable: _teamsLoadingNotifier,
                builder: (_, v, child) {
                  teams = _firebase.user.teams;
                  return _isGrid
                      ? TeamsGridContainerWidget(
                          teams: teams,
                          goToTeam: _goToTeam,
                          showTeamDialog: _showJoinCreateTeamDialog,
                        )
                      : TeamsRowContainerWidget(
                          teams: teams,
                          goToTeam: _goToTeam,
                          showTeamDialog: _showJoinCreateTeamDialog,
                        );
                })
          ],
        ),
      ),
    );
  }

  Widget _toggleGridBtn() {
    return IconButton(
      onPressed: _toggleGrid,
      icon:
          Icon(_isGrid ? Icons.grid_view_outlined : Icons.table_rows_outlined),
      color: Style.sec,
    );
  }

  void _toggleGrid() {
    setState(() {
      _isGrid = !_isGrid;
    });
  }

  void _showJoinCreateTeamDialog() {
    showDialog(
        context: context,
        builder: (_) => JoinCreateTeamDialog(
              teamsNotifier: _teamsLoadingNotifier,
            ));
  }

  void _goToTeam(Team team) async {
    if (team.quizzes.isEmpty) {
      team.updateQuizzes(
          await _firebase.getQuizzesDisplayData(
              team.id, team.isOwner(_firebase.user)),
          false);
    }
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TeamPage(
                team: team,
              )));
    }
  }
}
