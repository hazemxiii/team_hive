import 'package:flutter/material.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';
import 'package:team_hive/team_page/quiz_page/quiz_page.dart';
import 'package:team_hive/team_page/quizzes_page/responses_dialog.dart';

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
              if (widget.team.owner.email == BackendService().user.email)
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
      BackendService firebase = BackendService();
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

class QuizWidget extends StatefulWidget {
  final Quiz quiz;
  final Team team;
  final Function goToQuiz;
  const QuizWidget(
      {super.key,
      required this.quiz,
      required this.team,
      required this.goToQuiz});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  @override
  Widget build(BuildContext context) {
    final backend = BackendService();
    int status = widget.quiz.getQuizState();
    return InkWell(
      onTap: () => widget.goToQuiz(context, widget.team, widget.quiz, true),
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
                    widget.quiz.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.team.isOwner(backend.user)) _contextMenu(),
                if (widget.quiz.grade != null) _gradeWidget(widget.quiz.grade!)
              ],
            ),
            if (widget.quiz.grade == null)
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: _examStatusWidget(status)),
            if (widget.quiz.startDate != null)
              _dateWidget(widget.quiz.startDate!, "Starts At"),
            if (widget.quiz.deadline != null)
              _dateWidget(widget.quiz.deadline!, "Due by")
          ],
        ),
      ),
    );
  }

  Widget _contextMenu() {
    return PopupMenuButton(
        color: Style.sec,
        itemBuilder: (context) {
          return [
            PopupMenuItem(
                onTap: () => _showResponses(),
                child: Text(
                  "Show Responses",
                  style: TextStyle(color: Style.back),
                )),
            PopupMenuItem(
                onTap: () => _toggleShowAnswers(),
                child: Text(
                  widget.quiz.answersShown ? "Hide Answers" : "Show Answers",
                  style: TextStyle(color: Style.back),
                ))
          ];
        });
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
          "Grade: ${grade == -1 ? "Hidden" : grade}"),
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

  void _showResponses() async {
    var backend = BackendService();

    Quiz? q = await backend.getQuizData(widget.team.id, widget.quiz.name);
    if (q != null) {
      widget.quiz.copy(q);
    }

    Map? data =
        await backend.getQuizResponses(widget.quiz.name, widget.team.id);
    if (mounted && data != null) {
      showDialog(
          context: context,
          builder: (_) => ResponsesDialog(
              responses: data['responses'],
              noResponse: data['noAnswer'],
              quiz: widget.quiz));
    }
  }

  void _toggleShowAnswers() async {
    bool success = await BackendService()
        .toggleShowAnswers(widget.team.id, widget.quiz.name);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
          content: Text(success
              ? (widget.quiz.answersShown
                  ? "Answers are Hidden"
                  : "Answers are Now Visible to Members")
              : "An Error Happened")));
      setState(() {
        widget.quiz.toggleAnswersShown();
      });
    }
  }
}
