import 'package:flutter/material.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';

class TeamsGridContainerWidget extends StatelessWidget {
  final List<Team> teams;
  final Function(Team t) goToTeam;
  final Function showTeamDialog;
  const TeamsGridContainerWidget(
      {super.key,
      required this.teams,
      required this.goToTeam,
      required this.showTeamDialog});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              maxCrossAxisExtent: 200),
          children: [
            InkWell(
              onTap: () => showTeamDialog(),
              child: _cardContainer(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Style.sec,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    "Create/Join A Team",
                    style: TextStyle(
                      color: Style.sec,
                    ),
                  ),
                ],
              )),
            ),
            ...List.generate(
                teams.length,
                (index) => InkWell(
                      onTap: () => goToTeam(teams[index]),
                      // onTap: () => _goToTeam(teams[index]),
                      child: _cardContainer(Text(
                        textAlign: TextAlign.center,
                        teams[index].name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )),
                    ))
          ],
        ),
      ),
    );
  }

  Widget _cardContainer(Widget child) {
    return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Style.section,
            border: Border.fromBorderSide(
                BorderSide(color: Style.section, width: 2)),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: child);
  }
}

class TeamsRowContainerWidget extends StatelessWidget {
  final List<Team> teams;
  final Function(Team t) goToTeam;
  final Function showTeamDialog;
  const TeamsRowContainerWidget(
      {super.key,
      required this.teams,
      required this.goToTeam,
      required this.showTeamDialog});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () => showTeamDialog(),
              child: _rowContainer(Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Style.sec,
                  ),
                  const VerticalDivider(
                    color: Colors.transparent,
                    width: 2,
                  ),
                  Text(
                    "Create/Join A Team",
                    style: TextStyle(color: Style.sec),
                  )
                ],
              )),
            ),
            ...List.generate(
                teams.length,
                (i) => _rowContainer(InkWell(
                      onTap: () => goToTeam(teams[i]),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 20,
                            color: Style.sec,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              teams[i].name,
                              style: TextStyle(
                                  color: Style.main,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          )
                        ],
                      ),
                    )))
          ],
        ),
      ),
    );
  }

  Widget _rowContainer(Widget child) {
    return Container(
        height: 45,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
            color: Style.section,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: child);
  }
}
