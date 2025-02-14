import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';
import 'package:team_hive/team_page/quiz_page/quiz_page.dart';

class QuizzesPage extends StatefulWidget {
  final Team team;
  const QuizzesPage({super.key, required this.team});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Quizzes",
                style: Style.headingStyle,
              ),
              const SizedBox(
                width: 15,
              ),
              if (widget.team.owner.email ==
                  context.read<BackendService>().user.email)
                IconButton(
                    color: Style.sec,
                    onPressed: _addQuiz,
                    icon: const Icon(Icons.add))
            ],
          ),
          Expanded(
            child: GridView.builder(
                itemCount: widget.team.quizzes.length,
                itemBuilder: (_, i) => QuizWidget(
                      team: widget.team,
                      quiz: widget.team.quizzes[i],
                      goToQuiz: _goToQuiz,
                    ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 200)),
          )
        ],
      ),
    );
  }

  void _addQuiz() {
    _goToQuiz(context, widget.team, Quiz(name: ""), false);
  }

  void _goToQuiz(
      BuildContext context, Team team, Quiz quiz, bool withDetails) async {
    if (withDetails) {
      BackendService firebase = context.read<BackendService>();
      bool isOwner = team.isOwner(firebase.user);
      if (isOwner || quiz.getQuizState() == 0 || quiz.getQuizState() == 1) {
        if (quiz.questions.isEmpty) {
          Quiz? q = await firebase.getQuizData(team.id, quiz.name);
          if (q != null) {
            q.setGrade(quiz.grade);
            quiz.copy(q);
          }
        }
      }
    }
    if (context.mounted) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => QuizPage(team: team, quiz: quiz)));
    }
  }
}

class QuizWidget extends StatelessWidget {
  final Quiz quiz;
  final Team team;
  final Function goToQuiz;
  const QuizWidget(
      {super.key,
      required this.quiz,
      required this.team,
      required this.goToQuiz});

  @override
  Widget build(BuildContext context) {
    int status = quiz.getQuizState();
    return InkWell(
      onTap: () => goToQuiz(context, team, quiz, true),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(color: Style.section),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    style: TextStyle(
                        color: Style.main,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    quiz.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (quiz.grade != null) _gradeWidget(quiz.grade!)
              ],
            ),
            if (quiz.grade == null)
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: _examStatusWidget(status)),
            if (quiz.startDate != null)
              _dateWidget(quiz.startDate!, "Starts At"),
            if (quiz.deadline != null) _dateWidget(quiz.deadline!, "Due by")
          ],
        ),
      ),
    );
  }

  Widget _gradeWidget(double grade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          color: Color.lerp(Style.sec, Style.back, 0.5)),
      child: Text(
          style: TextStyle(
              color: Style.main, fontWeight: FontWeight.bold, fontSize: 12),
          "Grade: $grade"),
    );
  }

  Widget _examStatusWidget(int status) {
    if (status == 0) {
      return const Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: Colors.green,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Active",
            style: TextStyle(color: Colors.green),
          )
        ],
      );
    } else if (status == 1) {
      return const Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Colors.red,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Past Deadline",
            style: TextStyle(color: Colors.red),
          )
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: Style.sec,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "Cooming soon...",
            style: TextStyle(color: Style.sec),
          )
        ],
      );
    }
  }

  Widget _dateWidget(DateTime date, String label) {
    return Row(
      children: [Expanded(child: Text("$label: ${_formattedDate(date)}"))],
    );
  }

  String _formattedDate(DateTime date) {
    TimeOfDay time = TimeOfDay.fromDateTime(date);
    return "${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}/${date.year} ${time.hourOfPeriod}:${time.minute.toString().padLeft(2, "0")} ${time.period == DayPeriod.am ? "AM" : "PM"}";
  }
}
