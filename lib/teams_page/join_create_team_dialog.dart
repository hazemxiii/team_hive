import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';

class JoinCreateTeamDialog extends StatefulWidget {
  final ValueNotifier teamsNotifier;
  const JoinCreateTeamDialog({super.key, required this.teamsNotifier});

  @override
  State<JoinCreateTeamDialog> createState() => _JoinCreateTeamDialogState();
}

class _JoinCreateTeamDialogState extends State<JoinCreateTeamDialog> {
  Color backColor = Color.lerp(Style.back, Style.sec, 0.2)!;
  final _pageController = PageController(initialPage: 0);
  final _joinController = TextEditingController();
  final _createController = TextEditingController();
  final _joinFormKey = GlobalKey<FormState>();
  final _createFormKey = GlobalKey<FormState>();
  late final BackendService _backend;

  @override
  void initState() {
    _backend = context.read<BackendService>();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _joinController.dispose();
    _createController.dispose();
    super.dispose();
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
              "${_backend.user.isPremium ? "Create or " : ""}Join a Team",
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
          if (_backend.user.isPremium) _segmentWidget(1, "Create"),
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
      if (await _backend.createTeam(_createController.text)) {
        List<Team> teams = await _backend.getTeamsNames();
        _backend.user.setTeams(teams);
        widget.teamsNotifier.value = false;
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to Create Team")));
        }
      }
    }
  }

  void _joinTeam() async {
    if (_joinFormKey.currentState!.validate()) {
      widget.teamsNotifier.value = true;
      await _backend.joinTeam(_joinController.text);
      List<Team> teams = await _backend.getTeamsNames();
      _backend.user.setTeams(teams);
      widget.teamsNotifier.value = false;
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
