import 'package:flutter/material.dart';
import 'package:team_hive/models/question/mcq_question.dart';
import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';
import 'package:team_hive/models/question/written_question.dart';
import 'package:team_hive/service/app_colors.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: widget.question.text);
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
            controller: controller,
            onChanged: (v) => widget.question.text = v,
            style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: [
            ...widget.question.choices.map((choice) {
              return _choiceWidget(choice, false);
            }),
            if (widget.isOwner) _choiceWidget("", true)
          ],
        ),
        if (!(widget.question.isQuestionCorrect() ?? true))
          _correctAnswerWidget()
      ],
    );
  }

  Widget _choiceWidget(String choice, bool isLast) {
    final TextEditingController controller =
        TextEditingController(text: choice);
    controller.selection = TextSelection.collapsed(offset: choice.length);
    TextField text = TextField(
      style: TextStyle(color: Style.main),
      cursorColor: Style.main,
      enabled: widget.isOwner,
      onChanged: (v) => !isLast ? _changeChoice(choice, v) : _addChoice(v),
      controller: controller,
      decoration:
          const InputDecoration(border: InputBorder.none, hintText: "Option"),
    );
    if (widget.question is SingleMcqQuestion) {
      return RadioListTile(
          activeColor: _getChoiceActiveColor(choice),
          contentPadding: const EdgeInsets.all(0),
          title: text,
          value: choice,
          groupValue: (widget.question as SingleMcqQuestion).answer,
          onChanged: (v) => (!isLast && !widget.isDisplay)
              ? _setSingleChoice(widget.question as SingleMcqQuestion, v)
              : null);
    }
    return CheckboxListTile(
        contentPadding: const EdgeInsets.all(0),
        activeColor: _getChoiceActiveColor(choice),
        title: text,
        value: (widget.question as MultiMcqQuestion).answer.contains(choice),
        onChanged: (v) => (!isLast && !widget.isDisplay)
            ? _setMultiChoice((widget.question as MultiMcqQuestion), choice)
            : null);
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
    setState(() {
      widget.question.choices[choiceI] = v;
    });
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

  void _setSingleChoice(SingleMcqQuestion q, String? choice) {
    bool wasAnswered = q.answer != null;
    setState(() {
      q.answer = choice;
      if (!wasAnswered) {
        QuizPage.answeredCountNot.value++;
      }
    });
  }

  void _setMultiChoice(MultiMcqQuestion q, String choice) {
    bool wasAnswered = q.answer.isNotEmpty;
    setState(() {
      if (q.answer.contains(choice)) {
        q.answer.remove(choice);
        if (q.answer.isEmpty && wasAnswered) {
          QuizPage.answeredCountNot.value--;
        }
      } else {
        q.answer.add(choice);
        if (!wasAnswered) {
          QuizPage.answeredCountNot.value++;
        }
      }
    });
  }

  Color _getChoiceActiveColor(String choice) {
    if (!widget.question.hasCorrectAnswer()) {
      return Style.sec;
    }
    if (widget.question.isChoiceCorrect(choice)) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  // Color _getMultiChocieActiveColor(String choice) {
  //   List<String> correct = (widget.question as MultiMcqQuestion).correctChoices;
  //   if (correct.isEmpty) {
  //     return Style.sec;
  //   }
  //   if (correct.contains(choice)) {
  //     return Colors.green;
  //   } else {
  //     return Colors.red;
  //   }
  // }
}

class WrittenQuestionWidget extends StatelessWidget {
  final WrittenQuestion question;
  final bool isOwner;
  final bool isDisplay;
  const WrittenQuestionWidget(
      {super.key,
      required this.question,
      required this.isOwner,
      required this.isDisplay});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
        borderSide: BorderSide(color: Style.main),
        borderRadius: const BorderRadius.all(Radius.circular(5)));
    final questionController = TextEditingController(text: question.text);
    final answerController = TextEditingController(text: question.answer);
    return Column(
      children: [
        TextField(
          enabled: isOwner,
          cursorColor: Style.main,
          style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
              border: InputBorder.none, hintText: "Question"),
          onChanged: (v) => question.text = v,
          controller: questionController,
        ),
        TextField(
          enabled: !isDisplay,
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
    bool wasAnswered = question.answer != "";
    question.answer = v.trim();
    if (question.answer == "" && wasAnswered) {
      QuizPage.answeredCountNot.value--;
    }
    if (question.answer != "" && !wasAnswered) {
      QuizPage.answeredCountNot.value++;
    }
  }
}
