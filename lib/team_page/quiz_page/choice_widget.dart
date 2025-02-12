import 'package:flutter/material.dart';
import 'package:team_hive/models/question/mcq_question.dart';
import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/team_page/quiz_page/quiz_page.dart';

class ChoiceWidget extends StatefulWidget {
  const ChoiceWidget(
      {super.key,
      required this.choice,
      required this.isLast,
      required this.isOwner,
      required this.changeChoice,
      required this.addChoice,
      required this.question,
      required this.isDisplay});
  final String choice;
  final bool isLast;
  final bool isOwner;
  final bool isDisplay;
  final McqQuestion question;
  final Function(String choice, String v) changeChoice;
  final Function(String v) addChoice;

  @override
  State<ChoiceWidget> createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
  final TextEditingController _choiceController = TextEditingController();
  late final TextField text;

  @override
  void initState() {
    text = TextField(
      style: TextStyle(color: Style.main),
      cursorColor: Style.main,
      enabled: widget.isOwner,
      onChanged: (v) => !widget.isLast
          ? widget.changeChoice(widget.choice, v)
          : widget.addChoice(v),
      controller: _choiceController,
      decoration:
          const InputDecoration(border: InputBorder.none, hintText: "Option"),
    );
    super.initState();
  }

  @override
  void dispose() {
    _choiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initController();
    if (widget.question is SingleMcqQuestion) {
      return RadioListTile(
          activeColor: _getChoiceActiveColor(widget.choice),
          contentPadding: const EdgeInsets.all(0),
          title: text,
          value: widget.choice,
          groupValue: (widget.question as SingleMcqQuestion).answer,
          onChanged: (v) => (!widget.isLast && !widget.isDisplay)
              ? _setSingleChoice(widget.question as SingleMcqQuestion, v)
              : null);
    }
    return CheckboxListTile(
        contentPadding: const EdgeInsets.all(0),
        activeColor: _getChoiceActiveColor(widget.choice),
        title: text,
        value: (widget.question as MultiMcqQuestion)
            .answer
            .contains(widget.choice),
        onChanged: (v) => (!widget.isLast && !widget.isDisplay)
            ? _setMultiChoice(
                (widget.question as MultiMcqQuestion), widget.choice)
            : null);
  }

  void _initController() {
    try {
      var r = _choiceController.selection;
      _choiceController.text = widget.choice;
      _choiceController.selection = r;
    } catch (e) {
      _choiceController.selection =
          TextSelection.collapsed(offset: widget.choice.length);
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
}
