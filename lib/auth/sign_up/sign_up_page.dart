import 'dart:math';
import 'package:flutter/material.dart';
import 'package:team_hive/auth/sign_up/pages.dart';
import 'package:team_hive/models/sign_up.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final controller = PageController(initialPage: 0);

  @override
  void dispose() {
    controller.dispose();
    SignUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double minWidth = 600;

    return Scaffold(
      backgroundColor: Style.back,
      body: SafeArea(
          child: Center(
              child: SizedBox(
        width: min(MediaQuery.of(context).size.width - 50, minWidth),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Create Your Account",
                style: Style.headingStyle,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Step ${_getPage() + 1} of 2",
                  style: Style.miniTextStyle,
                ),
              ),
              _progressWidget(),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 300,
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller,
                  children: const [FirstPage(), SecondPage()],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _navigateBtnsWidget()
            ],
          ),
        ),
      ))),
    );
  }

  Widget _progressWidget() {
    return LinearProgressIndicator(
      minHeight: 10,
      color: Style.sec,
      backgroundColor: Style.back,
      value: (_getPage() + 1) / 2,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
    );
  }

  Widget _navigateBtnsWidget() {
    return Column(
      children: [
        _navigateBtn(true),
        const SizedBox(
          height: 5,
        ),
        _navigateBtn(false)
      ],
    );
  }

  Widget _navigateBtn(bool isNext) {
    return MaterialButton(
      color: isNext ? Style.main : Style.back,
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      height: 50,
      onPressed: () => _scroll(isNext),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: isNext
            ? [
                if (_getPage() < 1)
                  Icon(
                    Icons.arrow_forward,
                    color: Style.back,
                  ),
                Text(
                  _getPage() == 1 ? "Create Account" : "Next",
                  style: TextStyle(color: Style.back),
                )
              ]
            : [
                Icon(
                  Icons.arrow_back,
                  color: Style.main,
                ),
                Text(
                  "Previous",
                  style: TextStyle(color: Style.main),
                )
              ],
      ),
    );
  }

  int _getPage() {
    try {
      return controller.page!.toInt();
    } catch (e) {
      return 0;
    }
  }

  void _scroll(bool isNext) async {
    if (isNext) {
      if (SignUp.formKeys[_getPage()].currentState!.validate()) {
        if (_getPage() == 1) {
          _createAccount();
        } else {
          await controller.nextPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
        }
      }
    } else {
      await controller.previousPage(
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    }
    setState(() {});
  }

  void _createAccount() async {
    String? s = await BackendService().createEmailAccount(SignUp.email.text,
        SignUp.password.text, SignUp.fName.text, SignUp.lName.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s ?? "Account Created Successfully")));
      if (s == null) {
        SignUp.clear();
        Navigator.of(context).pop();
      }
    }
  }
}
