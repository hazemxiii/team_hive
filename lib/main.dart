import 'package:flutter/material.dart';
import 'package:team_hive/auth/login_page.dart';
import 'package:team_hive/home_page.dart';

import 'package:team_hive/service/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:team_hive/service/backend.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Style.initColors();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const App(),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final firebase = BackendService();
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: Style.sec,
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Color.lerp(Style.back, Style.main, 0.5),
          )),
      home: !firebase.isLogged
          ? const LoginPage()
          : FutureBuilder(
              future: firebase.getCurrentUserProfile(),
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SizedBox();
                } else {
                  return const HomePage();
                }
              }),
    );
  }
}
