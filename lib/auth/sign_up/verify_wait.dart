import 'dart:async';

import 'package:flutter/material.dart';
import 'package:team_hive/home_page.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';

class VerifyWaitPage extends StatefulWidget {
  final String email;
  final String fName;
  final String lName;
  const VerifyWaitPage(
      {super.key,
      required this.email,
      required this.fName,
      required this.lName});

  @override
  State<VerifyWaitPage> createState() => _VerifyWaitPageState();
}

class _VerifyWaitPageState extends State<VerifyWaitPage> {
  late Timer timer;
  late final BackendService _backend = BackendService();
  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_backend.isVerified) {
        t.cancel();
        await _backend.createUserDoc(widget.fName, widget.lName);
        await _backend.getCurrentUserProfile();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (_) => false);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.grey);
    return Scaffold(
      backgroundColor: Style.back,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Style.section,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Verify Your Email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Style.sec,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "We've Sent You a Verification Email",
                  textAlign: TextAlign.center,
                  style: style,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: CircularProgressIndicator(
                    color: Style.sec,
                  ),
                ),
                const Text(
                    textAlign: TextAlign.center,
                    "Please check your inbox and click the verification link to complete your registration.",
                    style: style),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                    textAlign: TextAlign.center,
                    "If you don't see the email, check your spam folder.",
                    style: style),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  color: Style.back,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  onPressed: () {},
                  child: Text(
                    textAlign: TextAlign.center,
                    "Resend Verification Email",
                    style: TextStyle(color: Style.sec),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
