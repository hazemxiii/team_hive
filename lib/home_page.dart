import 'package:flutter/material.dart';
import 'package:team_hive/coming_soon.dart';
import 'package:team_hive/nav_bars.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/settings_page.dart';
import 'package:team_hive/teams_page/teams_page.dart';

class ActivePage {
  static final ValueNotifier<int> _activePageI = ValueNotifier(1);
  static void setPage(int i) {
    _activePageI.value = i;
  }

  static ValueNotifier<int> get activePageI => _activePageI;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pages = const [
    ComingSoonPage(
      title: "Profile",
      isFullPage: false,
    ),
    TeamsPage(),
    ComingSoonPage(
      title: "Tasks",
      isFullPage: false,
    ),
    SettingsPage()
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _isScreenSmall() ? const BottomNavBarWidget() : null,
      backgroundColor: Style.back,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isScreenSmall()) const RailWidget(),
          ValueListenableBuilder(
              valueListenable: ActivePage._activePageI,
              builder: (context, v, _) => _pages[v])
        ],
      ),
    );
  }

  bool _isScreenSmall() {
    return MediaQuery.sizeOf(context).width < 450;
  }
}
