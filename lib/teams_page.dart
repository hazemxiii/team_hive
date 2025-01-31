import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';
import 'package:team_hive/team_page/team_page.dart';

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
                  return _isGrid ? _gridView() : _rowView();
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

  Widget _gridView() {
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
              onTap: _showTeamDialog,
              child: _cardContainer(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Style.sec,
                  ),
                  Text(
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
                      onTap: () => _goToTeam(teams[index]),
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

  Widget _rowView() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: _showTeamDialog,
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
                (i) => _rowContainer(Row(
                      children: [
                        Container(
                          width: 3,
                          height: 20,
                          color: teams[i].color,
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

  void _toggleGrid() {
    setState(() {
      _isGrid = !_isGrid;
    });
  }

  void _showTeamDialog() {
    showDialog(
        context: context,
        builder: (_) => TeamDialog(
              teamsNotifier: _teamsLoadingNotifier,
            ));
  }

  void _goToTeam(Team team) async {
    team.updateQuizzes([Quiz(name: "Quiz 1"), Quiz(name: "name")], false);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TeamPage(
              team: team,
            )));
  }
}

class TeamDialog extends StatefulWidget {
  final ValueNotifier teamsNotifier;
  const TeamDialog({super.key, required this.teamsNotifier});

  @override
  State<TeamDialog> createState() => _TeamDialogState();
}

class _TeamDialogState extends State<TeamDialog> {
  Color backColor = Color.lerp(Style.back, Style.sec, 0.2)!;
  final _pageController = PageController(initialPage: 0);
  final _joinController = TextEditingController();
  final _createController = TextEditingController();
  final _joinFormKey = GlobalKey<FormState>();
  final _createFormKey = GlobalKey<FormState>();
  late final FirebaseService _firebase;

  @override
  void initState() {
    _firebase = context.read<FirebaseService>();
    super.initState();
  }

  int _section = 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              textAlign: TextAlign.left,
              "Create or Join a Team",
              style: Style.headingStyle,
            ),
            _segmentBtn(),
            _sectionsBuilder()
          ],
        ),
      ),
    );
  }

  Widget _segmentBtn() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: backColor),
      child: Row(
        children: [
          _segmentWidget(0, "Join"),
          _segmentWidget(1, "Create"),
        ],
      ),
    );
  }

  Widget _segmentWidget(int i, String txt) {
    return Expanded(
      child: InkWell(
        onTap: () => _setSection(i),
        child: AnimatedContainer(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: _section == i ? Style.sec : backColor,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          duration: const Duration(milliseconds: 200),
          child: Text(txt,
              style: TextStyle(color: _section == i ? Style.back : Style.main)),
        ),
      ),
    );
  }

  Widget _sectionsBuilder() {
    return SizedBox(
      width: min(MediaQuery.sizeOf(context).width, 400),
      height: 200,
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [_sectionWidget(true), _sectionWidget(false)],
      ),
    );
  }

  Widget _sectionWidget(bool isJoin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            isJoin ? "Join Code" : "Team Name",
            style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
          ),
        ),
        _input(isJoin ? _joinController : _createController, _validator,
            isJoin ? _joinFormKey : _createFormKey),
        const SizedBox(
          height: 10,
        ),
        _btn(isJoin)
      ],
    );
  }

  Form _input(TextEditingController controller,
      FormFieldValidator<String> validator, GlobalKey<FormState> key) {
    final border =
        OutlineInputBorder(borderSide: BorderSide(color: Style.main));
    final borderF =
        OutlineInputBorder(borderSide: BorderSide(color: Style.sec, width: 2));
    const borderE =
        OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    return Form(
      key: key,
      child: ValueListenableBuilder(
          valueListenable: widget.teamsNotifier,
          builder: (context, v, _) {
            return TextFormField(
              cursorColor: Style.sec,
              style: TextStyle(color: Style.sec),
              validator: validator,
              decoration: InputDecoration(
                  suffixIconConstraints:
                      const BoxConstraints(maxWidth: 50, maxHeight: 30),
                  suffixIcon: v
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: CircularProgressIndicator(
                            color: Style.sec,
                          ),
                        )
                      : null,
                  enabledBorder: border,
                  focusedBorder: borderF,
                  errorBorder: borderE,
                  focusedErrorBorder: borderE),
              controller: controller,
            );
          }),
    );
  }

  MaterialButton _btn(bool isJoin) {
    return MaterialButton(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      height: 40,
      minWidth: 120,
      color: Style.sec,
      onPressed: isJoin ? _joinTeam : _createTeam,
      child: Text(
        isJoin ? "Join" : "Create",
        style: TextStyle(color: Style.back),
      ),
    );
  }

  void _setSection(int i) {
    _pageController.animateToPage(i,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
    setState(() {
      _section = i;
    });
  }

  String? _validator(String? v) {
    if ((v ?? "").trim() == "") {
      return "Can't be Empty";
    }
    return null;
  }

  void _createTeam() async {
    if (_createFormKey.currentState!.validate()) {
      widget.teamsNotifier.value = true;
      if (await _firebase.createTeam(_createController.text)) {
        List<Team> teams = await _firebase.getTeams();
        _firebase.user.setTeams(teams);
        widget.teamsNotifier.value = false;
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _joinTeam() async {
    if (_joinFormKey.currentState!.validate()) {
      widget.teamsNotifier.value = true;
      await _firebase.joinTeam(_joinController.text);
      List<Team> teams = await _firebase.getTeams();
      _firebase.user.setTeams(teams);
      widget.teamsNotifier.value = false;
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
