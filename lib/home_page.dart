import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pages = [
    Container(
      child: Text("1"),
    ),
    Container(
      child: Text("2"),
    ),
    Container(
      child: Text("3"),
    )
  ];

  int _activePageI = 0;
  bool isExpanded = false;
  late final FirebaseService firebase;

  @override
  void initState() {
    firebase = context.read<FirebaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.back,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.sizeOf(context).width >= 600) _navRail(),
          _pages[_activePageI]
        ],
      ),
    );
  }

  Widget _navRail() {
    double maxWidth = 150;
    double minWidth = 80;
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
        leading: AnimatedContainer(
          padding: EdgeInsets.only(left: isExpanded ? 20 : 0),
          alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 360),
          width: isExpanded ? maxWidth : 30,
          child: Container(
            alignment: Alignment.center,
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Style.sec,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              // image: DecorationImage(
              //     image: AssetImage("images/google.png"), fit: BoxFit.cover)
            ),
            child: _nameWidget(),
          ),
        ),
        indicatorColor: Style.sec,
        selectedIconTheme: IconThemeData(color: Style.back),
        backgroundColor: Style.section,
        extended: isExpanded,
        onDestinationSelected: (i) {
          setState(() {
            _activePageI = i;
          });
        },
        destinations: const [
          NavigationRailDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: Text("Home")),
          NavigationRailDestination(
              selectedIcon: Icon(Icons.book),
              icon: Icon(Icons.book_outlined),
              label: Text("Tasks")),
          NavigationRailDestination(
              selectedIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: Text("Settings"))
        ],
        selectedIndex: _activePageI);
  }

  Widget _nameWidget() {
    if (firebase.fName == null) {
      return FutureBuilder(
          future: firebase.getName(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Text("");
            }
            return Text(
              firebase.fName ?? "."[0],
              style: TextStyle(color: Style.back),
            );
          });
    } else {
      return Text(
        firebase.fName ?? "."[0],
        style: TextStyle(color: Style.back),
      );
    }
  }

  void _toggleExpandRail() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
}
