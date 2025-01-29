import 'package:flutter/material.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/service/app_colors.dart';

class QuizzesPage extends StatelessWidget {
  final List<Quiz> quizzes;
  const QuizzesPage({super.key, required this.quizzes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quizzes",
            style: Style.headingStyle,
          ),
          Expanded(
            child: GridView.builder(
                itemCount: quizzes.length,
                itemBuilder: (_, i) => QuizWidget(quiz: quizzes[i]),
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
}

class QuizWidget extends StatelessWidget {
  final Quiz quiz;
  const QuizWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    int? percent = quiz.percent();
    return Container(
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
              if (percent != null) _gradeWidget(percent)
            ],
          ),
          _examStatusWidget(quiz.getQuizState())
        ],
      ),
    );
  }

  Widget _gradeWidget(int percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          color: Color.lerp(Style.sec, Style.back, 0.5)),
      child: Text(
          style: TextStyle(
              color: Style.main, fontWeight: FontWeight.bold, fontSize: 12),
          "Grade: $percent%"),
    );
  }

  Widget _examStatusWidget(int status) {
    if (status == 0) {
      return Text("on");
    } else if (status == 1) {
      return Text("passed");
    } else {
      return Text("yet to come");
    }
  }
}
