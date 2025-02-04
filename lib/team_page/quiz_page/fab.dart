import 'package:flutter/material.dart';
import 'package:team_hive/models/question/multi_mcq_question.dart';
import 'package:team_hive/models/question/question.dart';
import 'package:team_hive/models/question/single_mcq_question.dart';
import 'package:team_hive/models/question/written_question.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/service/app_colors.dart';

class Fab extends StatefulWidget {
  final Quiz quiz;
  final Function onTap;
  const Fab({super.key, required this.quiz, required this.onTap});

  @override
  State<Fab> createState() => _FabState();
}

class _FabState extends State<Fab> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _animation =
        Tween<double>(begin: -210, end: 10).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 200,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _animation.value == -210
                  ? _animationController.forward
                  : _animationController.reverse,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Style.sec,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Style.back,
                    ),
                    Text(
                      "Add a Question",
                      style: TextStyle(
                          color: Style.back, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),
          _addBtn(const Icon(Icons.square_outlined), "MCQ (multi answers)",
              MultiMcqQuestion(), 0, _animation.value),
          _addBtn(const Icon(Icons.circle_outlined), "MCQ (one answer)",
              SingleMcqQuestion(), 60, _animation.value),
          _addBtn(const Icon(Icons.text_format), "Written", WrittenQuestion(),
              120, _animation.value),
        ],
      ),
    );
  }

  Positioned _addBtn(
      Icon icon, String label, Question q, double top, double right) {
    return Positioned(
        top: top,
        right: right,
        child: MaterialButton(
          height: 50,
          // minWidth: 100,
          textColor: Style.sec,
          color: Style.section,
          onPressed: () {
            widget.quiz.addQuestion(q);
            widget.onTap();
            _animationController.reverse();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              Text(
                label,
              )
            ],
          ),
        ));
  }
}
