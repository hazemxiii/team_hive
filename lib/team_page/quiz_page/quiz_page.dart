import 'package:flutter/material.dart';
import 'package:team_hive/models/question/mcq_question.dart';
import 'package:team_hive/models/question/question.dart';
import 'package:team_hive/models/question/written_question.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/team_page/quiz_page/question_widgets.dart';

class QuizPage extends StatefulWidget {
  final Team team;
  final Quiz quiz;
  static final ValueNotifier<int> answeredCountNot = ValueNotifier(0);
  const QuizPage({super.key, required this.team, required this.quiz});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final TextEditingController nameController;

  @override
  initState() {
    super.initState();
    nameController = TextEditingController(text: widget.quiz.name);
  }

// TODO:add questions
// TODO: owner vs user ui
  int _activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawer(),
      backgroundColor: Style.back,
      appBar: AppBar(
        backgroundColor: Style.back,
        foregroundColor: Style.sec,
        centerTitle: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: TextField(
            cursorColor: Style.main,
            style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            onChanged: (v) => widget.quiz.setName(v),
            controller: nameController,
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _answeredIndicator(),
            _questionContainer(),
            _navButtonsWidget()
          ],
        ),
      ),
    );
  }

  Drawer _drawer() {
    int i = 0;
    return Drawer(
      backgroundColor: Style.section,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: widget.quiz.questions.map((q) {
              return _questionButton(i++);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _answeredIndicator() {
    return ValueListenableBuilder(
        valueListenable: QuizPage.answeredCountNot,
        builder: (c, v, _) => LinearProgressIndicator(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              backgroundColor: Style.section,
              color: Style.sec,
              value: v / widget.quiz.questions.length,
            ));
  }

  Widget _questionButton(int index) {
    bool isSelected = index == _activeIndex;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 20),
        minWidth: 300,
        color: !isSelected ? Style.back : Style.sec,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Style.sec),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        onPressed: () {
          setState(() {
            _activeIndex = index;
          });
        },
        child: Text(
          "Question ${index + 1}",
          style: TextStyle(color: !isSelected ? Style.sec : Style.back),
        ),
      ),
    );
  }

  Widget _questionContainer() {
    Question q = widget.quiz.questions[_activeIndex];

    return Container(
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Question ${_activeIndex + 1}",
            style: Style.headingStyle,
          ),
          q is McqQuestion
              ? McqQuestionWidget(question: q)
              : WrittenQuestionWidget(question: (q as WrittenQuestion)),
        ],
      ),
    );
  }

  Widget _navButtonsWidget() {
    bool isNextEnabled = _activeIndex < widget.quiz.questions.length - 1;
    bool isPrevEnabled = _activeIndex > 0;
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MaterialButton(
            disabledColor: Style.back,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Style.main),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Style.main,
            onPressed: isPrevEnabled ? () => _navQuestions(false) : null,
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: isPrevEnabled ? Style.back : Style.main,
                ),
                Text(
                  "Previous",
                  style:
                      TextStyle(color: isPrevEnabled ? Style.back : Style.main),
                )
              ],
            ),
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Style.sec),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Style.sec,
            onPressed: () => isNextEnabled ? _navQuestions(true) : () {},
            child: Row(
              children: [
                Text(
                  isNextEnabled ? "Next" : "Submit",
                  style: TextStyle(color: Style.back),
                ),
                if (!isNextEnabled)
                  const SizedBox(
                    width: 5,
                  ),
                Icon(
                  isNextEnabled ? Icons.arrow_forward_ios : Icons.send_rounded,
                  color: Style.back,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _navQuestions(bool next) {
    setState(() {
      if (next) {
        _activeIndex++;
      } else {
        _activeIndex--;
      }
    });
  }
}
