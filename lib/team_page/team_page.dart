import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/coming_soon.dart';
import 'package:team_hive/home_page.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';
import 'package:team_hive/team_page/files_page/Files_page.dart';
import 'package:team_hive/team_page/quizzes_page/quizzes_page.dart';
import 'package:team_hive/team_page/team_settings_page/team_settings_page.dart';

class TeamPage extends StatefulWidget {
  final Team team;
  const TeamPage({super.key, required this.team});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final BackendService _firebase;
  late Map<String, List<IconData>> _icons;
  late List<Widget> _pages;
  int _activePageI = 0;

  @override
  void initState() {
    _firebase = context.read<BackendService>();
    _icons = _drawerIcons();
    _pages = _pagesBuilder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawer(),
      backgroundColor: Style.back,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (_) => false),
              icon: const Icon(Icons.home_outlined))
        ],
        title: Row(
          children: [
            Text(widget.team.name),
            const SizedBox(
              width: 10,
            ),
            IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.team.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Team ID copied")));
                },
                icon: const Icon(Icons.person_add_outlined)),
          ],
        ),
        backgroundColor: Style.section,
        foregroundColor: Style.sec,
      ),
      body: _pages[_activePageI],
    );
  }

  Drawer _drawer() {
    return Drawer(
      backgroundColor: Style.section,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ..._icons.keys.toList().map((e) {
                return _drawerButton(e);
              })
            ],
          ),
        ),
      ),
    );
  }

  IconButton _drawerButton(String page) {
    int i = _icons.keys.toList().indexOf(page);
    bool isActive = i == _activePageI;
    return IconButton(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          setState(() {
            _activePageI = i;
          });
        },
        icon: Row(
          children: [
            Icon(
              _icons[page]![isActive ? 1 : 0],
              color: isActive ? Style.sec : Style.main,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              page,
              style: TextStyle(color: isActive ? Style.sec : Style.main),
            ),
          ],
        ));
  }

  Map<String, List<IconData>> _drawerIcons() {
    return {
      "Files": [Icons.folder_outlined, Icons.folder],
      "Chat": [Icons.chat_outlined, Icons.chat],
      "Quizzes": [Icons.check_outlined, Icons.check],
      "Tasks": [Icons.book_outlined, Icons.book],
      if (_firebase.user.email == widget.team.owner.email)
        "Settings": [Icons.settings_outlined, Icons.settings]
    };
  }

  List<Widget> _pagesBuilder() {
    return [
      FilesPage(team: widget.team),
      const ComingSoonPage(
        title: "Chat",
        isFullPage: true,
      ),
      QuizzesPage(team: widget.team),
      const ComingSoonPage(
        title: "Tasks",
        isFullPage: true,
      ),
      TeamSettingsPage(team: widget.team),
    ];
  }
}
