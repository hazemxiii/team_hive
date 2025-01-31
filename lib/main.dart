import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/auth/login_page.dart';
import 'package:team_hive/home_page.dart';
import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';
import 'package:team_hive/models/question/written_question.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:team_hive/service/firebase.dart';
import 'package:team_hive/team_page/quiz_page/quiz_page.dart';
import 'firebase_options.dart';
/*
https://www.figma.com/design/d4NRtX6iZtgDvjEW7tHr57/TeamHive?node-id=0-1&t=3OKBjxRjyCIDgUuK-1
*/

// TODO: dispose the disposable

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
    final firebase = context.read<FirebaseService>();
    return MaterialApp(
      theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color.lerp(Style.back, Style.main, 0.5),
      )),
      home: !firebase.isLogged
          ? const LoginPage()
          : FutureBuilder(
              future: firebase.getUserData(),
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SizedBox();
                } else {
                  Quiz q = Quiz(name: "name", questions: [
                    WrittenQuestion(text: "What's your name?"),
                    SingleMcqQuestion(
                      text: "What's your name?",
                      choices: ["HI", "Bye", "Hazem"],
                    ),
                    MultiMcqQuestion(
                      text: "What's a salut?",
                      choices: ["HI", "Bye", "Hazem"],
                    )
                  ]);
                  return QuizPage(
                      team: Team(
                          name: "Test Team",
                          color: Style.sec,
                          owner: firebase.user,
                          id: "id"),
                      quiz: q);
                  // TODO: return the navigation to home page
                  return const HomePage();
                }
              }),
    );
  }
}
