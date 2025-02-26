import 'package:flutter/material.dart';
import 'package:team_hive/models/quiz.dart';
import 'package:team_hive/models/user.dart';
import 'package:team_hive/service/app_colors.dart';

class ResponsesDialog extends StatelessWidget {
  const ResponsesDialog(
      {super.key,
      required this.responses,
      required this.noResponse,
      required this.quiz});
  final Map<MyUser, double> responses;
  final List<MyUser> noResponse;
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    List<MyUser> users = responses.keys.toList();
    double totalGrade = quiz.totalGrade;
    return Dialog.fullscreen(
      backgroundColor: Style.back,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                color: Style.sec,
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.close)),
            Expanded(
              child: ListView.builder(
                  itemCount: responses.length + noResponse.length,
                  itemBuilder: (context, i) {
                    if (i < responses.length) {
                      return _responseWidget(users[i], totalGrade);
                    } else {
                      return _responseWidget(
                          noResponse[i % noResponse.length], totalGrade);
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responseWidget(MyUser user, double totalGrade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Style.back,
          border: Border.fromBorderSide(
              BorderSide(color: Color.lerp(Colors.black, Colors.white, 0.8)!)),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.email,
                style: TextStyle(fontWeight: FontWeight.bold, color: Style.sec),
              ),
              Text("${user.fName} ${user.lName}")
            ],
          )),
          responses.containsKey(user)
              ? Text("${responses[user].toString()}/$totalGrade")
              : const Icon(
                  Icons.close,
                  color: Colors.red,
                )
        ],
      ),
    );
  }
}
