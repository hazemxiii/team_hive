import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  late final FirebaseService _firebase;
  List<Team> teams = [];

  @override
  initState() {
    _firebase = context.read();
    teams = _firebase.user.teams;
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
            _isGrid ? _gridView() : _rowView()
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
                (index) => _cardContainer(Text(
                      teams[index].name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    )))
          ],
        ),
      ),
    );
  }

  Widget _cardContainer(Widget child) {
    return Container(
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
                          color: Color(Random().nextInt(Colors.white.value) +
                              Colors.black.value),
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
    showDialog(context: context, builder: (_) => const TeamDialog());
  }
}

class TeamDialog extends StatefulWidget {
  const TeamDialog({super.key});

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
      child: TextFormField(
        cursorColor: Style.sec,
        style: TextStyle(color: Style.sec),
        validator: validator,
        decoration: InputDecoration(
            enabledBorder: border,
            focusedBorder: borderF,
            errorBorder: borderE,
            focusedErrorBorder: borderE),
        controller: controller,
      ),
    );
  }

  MaterialButton _btn(bool isJoin) {
    return MaterialButton(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      height: 40,
      minWidth: 120,
      color: Style.sec,
      onPressed: isJoin ? () => _joinTeam : _createTeam,
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
      if (await _firebase.createTeam(_createController.text)) {}
    }
  }

  void _joinTeam() {
    if (_joinFormKey.currentState!.validate()) {}
  }
}
