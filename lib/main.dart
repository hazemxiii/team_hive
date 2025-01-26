import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/auth/login_page.dart';
import 'package:team_hive/home_page.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:team_hive/service/firebase.dart';
import 'firebase_options.dart';
/*
https://www.figma.com/design/d4NRtX6iZtgDvjEW7tHr57/TeamHive?node-id=0-1&t=3OKBjxRjyCIDgUuK-1
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Style.initColors();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      Provider(
        create: (context) => FirebaseService(),
      )
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color.lerp(Style.back, Style.main, 0.5),
      )),
      home:
          FirebaseService().user == null ? const LoginPage() : const HomePage(),
    );
  }
}
