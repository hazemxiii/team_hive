import 'package:flutter/material.dart';
import 'package:team_hive/service/app_colors.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  final bool isFullPage;
  const ComingSoonPage(
      {super.key, required this.title, required this.isFullPage});

  @override
  Widget build(BuildContext context) {
    if (isFullPage) {
      return Scaffold(
        backgroundColor: Style.back,
        body: content(),
      );
    }
    return Expanded(child: content());
  }

  Widget content() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_outlined,
            color: Style.sec,
            size: 50,
          ),
          Text(
            textAlign: TextAlign.center,
            "$title is Coming Soon...",
            style: TextStyle(
                color: Style.sec, fontWeight: FontWeight.bold, fontSize: 24),
          )
        ],
      ),
    );
  }
}
