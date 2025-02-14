import 'package:flutter/material.dart';
import 'package:team_hive/service/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Center(
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
              color: Style.back,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: CircularProgressIndicator(
            color: Style.sec,
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const LoadingWidget());
  }
}
