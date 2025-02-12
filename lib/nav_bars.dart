import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/home_page.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';

class NameWidget extends StatelessWidget {
  const NameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BackendService firebase = context.read<BackendService>();
    return Text(
      (firebase.user.fName)[0],
      style: TextStyle(color: Style.back),
    );
  }
}

class RailWidget extends StatefulWidget {
  const RailWidget({super.key});

  @override
  State<RailWidget> createState() => _RailWidgetState();
}

class _RailWidgetState extends State<RailWidget> {
  bool isExpanded = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = 150;
    double minWidth = 80;
    return ValueListenableBuilder(
        valueListenable: ActivePage.activePageI,
        builder: (context, v, _) {
          return NavigationRail(
              minExtendedWidth: maxWidth,
              minWidth: minWidth,
              trailing: Expanded(
                child: AnimatedContainer(
                  alignment: Alignment.bottomRight,
                  duration: const Duration(milliseconds: 360),
                  width: isExpanded ? maxWidth : 40,
                  child: IconButton(
                      alignment: Alignment.centerRight,
                      onPressed: _toggleExpandRail,
                      icon: Icon(
                        Icons.menu,
                        color: Style.sec,
                      )),
                ),
              ),
              indicatorColor: Style.sec,
              useIndicator: v == 0 ? false : true,
              selectedIconTheme: IconThemeData(color: Style.back),
              backgroundColor: Style.section,
              extended: isExpanded,
              onDestinationSelected: (i) {
                setState(() {
                  ActivePage.setPage(i);
                });
              },
              destinations: [
                NavigationRailDestination(
                    icon: Container(
                      alignment: Alignment.center,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Style.sec,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                        // image: DecorationImage(
                        //     image: AssetImage("images/google.png"), fit: BoxFit.cover)
                      ),
                      child: const NameWidget(),
                    ),
                    label: const Text("Profile")),
                const NavigationRailDestination(
                    selectedIcon: Icon(Icons.home),
                    icon: Icon(Icons.home_outlined),
                    label: Text("Home")),
                const NavigationRailDestination(
                    selectedIcon: Icon(Icons.book),
                    icon: Icon(Icons.book_outlined),
                    label: Text("Tasks")),
                const NavigationRailDestination(
                    selectedIcon: Icon(Icons.settings),
                    icon: Icon(Icons.settings_outlined),
                    label: Text("Settings"))
              ],
              selectedIndex: v);
        });
  }

  void _toggleExpandRail() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
}

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ActivePage.activePageI,
        builder: (context, v, _) {
          return BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (i) => ActivePage.setPage(i),
            currentIndex: v,
            items: [
              _nameWidget(),
              BottomNavigationBarItem(
                  backgroundColor: Style.section,
                  label: "Home",
                  icon: Icon(
                    Icons.home_outlined,
                    color: Style.sec,
                  ),
                  activeIcon: Icon(Icons.home, color: Style.sec)),
              BottomNavigationBarItem(
                  backgroundColor: Style.section,
                  label: "Tasks",
                  icon: Icon(Icons.book_outlined, color: Style.sec),
                  activeIcon: Icon(Icons.book, color: Style.sec)),
              BottomNavigationBarItem(
                  backgroundColor: Style.section,
                  label: "Settings",
                  icon: Icon(Icons.settings_outlined, color: Style.sec),
                  activeIcon: Icon(Icons.settings, color: Style.sec))
            ],
          );
        });
  }

  BottomNavigationBarItem _nameWidget() {
    return BottomNavigationBarItem(
        backgroundColor: Style.section,
        label: "Profile",
        icon: Container(
          alignment: Alignment.center,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: Style.sec,
              borderRadius: const BorderRadius.all(Radius.circular(999))),
          child: const NameWidget(),
        ));
  }
}
