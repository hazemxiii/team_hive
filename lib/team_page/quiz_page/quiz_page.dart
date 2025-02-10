import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/models/question/mcq_question.dart';
import 'package:team_hive/models/question/question.dart';
import 'package:team_hive/models/question/written_question.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/team.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';
import 'package:team_hive/team_page/quiz_page/fab.dart';
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
  late final FirebaseService _firebase;

  @override
  initState() {
    super.initState();
    _firebase = context.read<FirebaseService>();
    nameController = TextEditingController(text: widget.quiz.name);
  }

  int _activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.team.isOwner(_firebase.user)
          ? Fab(
              quiz: widget.quiz,
              onTap: () {
                setState(() {
                  _activeIndex = widget.quiz.questions.length - 1;
                });
              })
          : null,
      drawer: _drawer(),
      backgroundColor: Style.back,
      appBar: AppBar(
        backgroundColor: Style.back,
        foregroundColor: Style.sec,
        centerTitle: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: TextField(
            enabled: widget.team.isOwner(_firebase.user),
            cursorColor: Style.main,
            style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            onChanged: (v) => widget.quiz.setName(v),
            controller: nameController,
            decoration: const InputDecoration(
                border: InputBorder.none, hintText: "Exam Name"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: widget.quiz.questions.isNotEmpty
              ? [
                  if (!widget.team.isOwner(_firebase.user) && !_isDisplayOnly())
                    _answeredIndicator(),
                  _questionContainer(),
                  _navButtonsWidget()
                ]
              : [],
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
    bool? isCorrect = q.isQuestionCorrect();
    return Container(
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${_activeIndex + 1}",
                style: Style.headingStyle,
              ),
              if (widget.team.isOwner(_firebase.user)) _questionOptions(q),
              // TODO: display written mark too
              if (!widget.team.isOwner(_firebase.user) &&
                  isCorrect != null &&
                  q is McqQuestion)
                _markWidget(q)
            ],
          ),
          q is McqQuestion
              ? McqQuestionWidget(
                  isDisplay: _isDisplayOnly(),
                  question: q,
                  isOwner: widget.team.isOwner(_firebase.user),
                )
              : WrittenQuestionWidget(
                  isDisplay: _isDisplayOnly(),
                  question: (q as WrittenQuestion),
                  isOwner: widget.team.isOwner(_firebase.user),
                ),
        ],
      ),
    );
  }

  Widget _questionOptions(Question q) {
    TextEditingController markController =
        TextEditingController(text: q.totalMark.toString());
    return Row(
      children: [
        Text(
          "Mark:",
          style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 30,
          child: TextField(
            cursorColor: Style.sec,
            textAlign: TextAlign.center,
            style: TextStyle(color: Style.sec),
            onChanged: (v) => q.totalMark = double.tryParse(v) ?? 1,
            decoration: const InputDecoration(border: InputBorder.none),
            controller: markController,
          ),
        ),
        IconButton(
            color: Style.sec,
            onPressed: () => _deleteQuestion(q),
            icon: const Icon(
              Icons.delete_outline,
            )),
      ],
    );
  }

  Widget _markWidget(Question q) {
    double mark = q.mark();
    return Text(
      "${q.mark()}/${q.totalMark}",
      style: TextStyle(
          color: mark == q.totalMark ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold),
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
          if (isNextEnabled || !_isDisplayOnly())
            MaterialButton(
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Style.sec),
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Style.sec,
              onPressed: isNextEnabled ? () => _navQuestions(true) : _sendQuiz,
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
                    isNextEnabled
                        ? Icons.arrow_forward_ios
                        : Icons.send_rounded,
                    color: Style.back,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  bool _isDisplayOnly() {
    if (widget.quiz.grade == null && widget.quiz.getQuizState() != 2) {
      return false;
    }
    return true;
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

  void _deleteQuestion(Question q) {
    setState(() {
      int i = widget.quiz.questions.indexOf(q);
      if (i == _activeIndex &&
          i == widget.quiz.questions.length - 1 &&
          i != 0) {
        _activeIndex--;
      }
      widget.quiz.questions.removeAt(i);
      if (q.isAnswered()) {
        QuizPage.answeredCountNot.value--;
      }
    });
  }

  void _sendQuiz() async {
    bool isOwner = widget.team.isOwner(_firebase.user);
    if (isOwner) {
      _createQuiz();
    } else {
      _submitQuiz();
    }
  }

  void _createQuiz() async {
    String? v = widget.quiz.validateQuiz();
    if (v != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v)));
    } else {
      String? error = await _firebase.createQuiz(widget.team, widget.quiz);
      if (error == null && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _submitQuiz() async {
    _firebase.submitQuiz(widget.quiz, widget.team);
  }
}
