import 'package:flutter/material.dart';
import 'package:team_hive/models/question/mcq_question.dart';
import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';
import 'package:team_hive/models/question/written_question.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/team_page/quiz_page/choice_widget.dart';
import 'package:team_hive/team_page/quiz_page/quiz_page.dart';

class McqQuestionWidget extends StatefulWidget {
  final McqQuestion question;
  final bool isOwner;
  final bool isDisplay;
  const McqQuestionWidget(
      {super.key,
      required this.question,
      required this.isOwner,
      required this.isDisplay});

  @override
  State<McqQuestionWidget> createState() => _McqQuestionWidgetState();
}

class _McqQuestionWidgetState extends State<McqQuestionWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            enabled: widget.isOwner,
            decoration: const InputDecoration(
                border: InputBorder.none, hintText: "Question"),
            cursorColor: Style.main,
            controller: _controller,
            onChanged: (v) => widget.question.text = v,
            style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: [
            ...widget.question.choices.map((choice) {
              // return _choiceWidget(choice, false);
              return ChoiceWidget(
                choice: choice,
                isLast: false,
                isOwner: widget.isOwner,
                changeChoice: _changeChoice,
                addChoice: _addChoice,
                question: widget.question,
                isDisplay: widget.isDisplay,
              );
            }),
            if (widget.isOwner)
              ChoiceWidget(
                choice: "",
                isLast: true,
                isOwner: widget.isOwner,
                changeChoice: _changeChoice,
                addChoice: _addChoice,
                question: widget.question,
                isDisplay: widget.isDisplay,
              )
            // if (widget.isOwner) _choiceWidget("", true)
          ],
        ),
        if (!(widget.question.isQuestionCorrect() ?? true))
          _correctAnswerWidget()
      ],
    );
  }

  void _initController() {
    try {
      var r = _controller.selection;
      _controller.text = widget.question.text;
      _controller.selection = r;
    } catch (e) {
      _controller.selection =
          TextSelection.collapsed(offset: widget.question.text.length);
    }
  }

  Widget _correctAnswerWidget() {
    String s;
    try {
      s = (widget.question as MultiMcqQuestion).correctChoices.join(",");
    } catch (e) {
      s = (widget.question as SingleMcqQuestion).correctAnswer!;
    }
    return Text(
      "Correct Answer: $s",
      style: TextStyle(color: Style.sec),
    );
  }

  void _addChoice(String v) {
    setState(() {
      widget.question.choices.add(v);
    });
  }

  void _changeChoice(String old, String v) {
    if (widget.question.choices.contains(v)) {
      return;
    }
    int choiceI = widget.question.choices.indexOf(old);
    setState(() {});
    widget.question.choices[choiceI] = v;
    if (widget.question is SingleMcqQuestion) {
      if ((widget.question as SingleMcqQuestion).answer == old) {
        (widget.question as SingleMcqQuestion).answer = v;
      }
    } else {
      int oldI = (widget.question as MultiMcqQuestion).answer.indexOf(old);
      if (oldI != -1) {
        (widget.question as MultiMcqQuestion).answer[oldI] = v;
      }
    }
  }
}

class WrittenQuestionWidget extends StatefulWidget {
  final WrittenQuestion question;
  final bool isOwner;
  final bool isDisplay;
  const WrittenQuestionWidget(
      {super.key,
      required this.question,
      required this.isOwner,
      required this.isDisplay});

  @override
  State<WrittenQuestionWidget> createState() => _WrittenQuestionWidgetState();
}

class _WrittenQuestionWidgetState extends State<WrittenQuestionWidget> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  void _initController(TextEditingController controller, String value) {
    try {
      var r = controller.selection;
      controller.text = value;
      controller.selection = r;
    } catch (e) {
      controller.selection = TextSelection.collapsed(offset: value.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initController(questionController, widget.question.text);
    _initController(answerController, widget.question.answer);
    final border = OutlineInputBorder(
        borderSide: BorderSide(color: Style.main),
        borderRadius: const BorderRadius.all(Radius.circular(5)));
    return Column(
      children: [
        TextField(
          enabled: widget.isOwner,
          cursorColor: Style.main,
          style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
              border: InputBorder.none, hintText: "Question"),
          onChanged: (v) => widget.question.text = v,
          controller: questionController,
        ),
        TextField(
          enabled: !widget.isDisplay,
          cursorColor: Style.sec,
          style: TextStyle(color: Style.sec),
          maxLines: null,
          decoration: InputDecoration(
              enabledBorder: border,
              focusedBorder: border,
              hintText: "Your Answer"),
          onChanged: _answerQuestion,
          controller: answerController,
        )
      ],
    );
  }

  void _answerQuestion(String v) {
    bool wasAnswered = widget.question.answer != "";
    widget.question.answer = v.trim();
    if (widget.question.answer == "" && wasAnswered) {
      QuizPage.answeredCountNot.value--;
    }
    if (widget.question.answer != "" && !wasAnswered) {
      QuizPage.answeredCountNot.value++;
    }
  }
}
