import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/auth/sign_up/sign_up_page.dart';
import 'package:team_hive/home_page.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/firebase.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login To TeamHive",
                  style: Style.headingStyle,
                ),
                Text(
                  "Enter Your Email And Password To Enter Your Space",
                  style: Style.miniTextStyle,
                ),
                const SizedBox(
                  height: 30,
                ),
                const FormWidget(),
                ..._separatorWidget(),
                const SizedBox(
                  height: 20,
                ),
                _googleSignInBtn(),
                const SizedBox(
                  height: 50,
                ),
                _noAccountWidget(context)
              ],
            ),
          ),
        ),
      )),
    );
  }

  List<Widget> _separatorWidget() {
    return [
      const SizedBox(
        height: 20,
      ),
      Container(
        color: Colors.grey,
        width: double.infinity,
        height: 1,
      ),
      const SizedBox(
        height: 5,
      ),
      const Text(
        "Or Continue With",
        style: TextStyle(color: Colors.grey),
      ),
    ];
  }

  Widget _googleSignInBtn() {
    return MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        color: Style.back,
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        onPressed: _googleSignIn,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "images/google.png",
              width: 15,
            ),
            const VerticalDivider(
              width: 5,
            ),
            Text(
              "Google",
              style: TextStyle(color: Style.main, fontWeight: FontWeight.bold),
            )
          ],
        ));
  }

  Widget _noAccountWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't Have An Account?",
          style: TextStyle(color: Style.main),
        ),
        IconButton(
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SignUpPage())),
            icon: Text(
              "Sign Up",
              style: TextStyle(color: Style.sec),
            ))
      ],
    );
  }

  void _googleSignIn() {}
}

class FormWidget extends StatefulWidget {
  const FormWidget({super.key});

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _key = GlobalKey<FormState>();
  bool _isHidden = true;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _emailInput(),
            const SizedBox(
              height: 10,
            ),
            _passwordInput(),
            const SizedBox(
              height: 10,
            ),
            _signInBtn(),
            const SizedBox(
              height: 20,
            ),
            _forgotPasswordBtn()
          ],
        ));
  }

  Widget _emailInput() {
    return TextFormField(
      controller: _emailController,
      cursorColor: Style.main,
      style: Style.textStyle,
      decoration:
          Style.getInputDecoration(true, hintText: "Email", isLabel: true),
    );
  }

  Widget _passwordInput() {
    return TextFormField(
      controller: _passController,
      obscureText: _isHidden,
      cursorColor: Style.main,
      style: Style.textStyle,
      decoration: Style.getInputDecoration(true,
          hintText: "Password",
          isLabel: true,
          suffix: IconButton(
              onPressed: _toggleVisibility,
              icon: Icon(_isHidden ? Icons.visibility_off : Icons.visibility))),
    );
  }

  Widget _signInBtn() {
    return MaterialButton(
      padding: const EdgeInsets.all(15),
      minWidth: double.infinity,
      onPressed: _login,
      color: Style.main,
      child: Text(
        "Sign In",
        style: TextStyle(color: Style.back),
      ),
    );
  }

  Widget _forgotPasswordBtn() {
    return MaterialButton(
      elevation: 0,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightElevation: 0,
      highlightColor: Colors.transparent,
      hoverElevation: 0,
      padding: const EdgeInsets.all(15),
      onPressed: _forgotPassword,
      color: Style.back,
      child: Text(
        "Forgot Your Password?",
        style: TextStyle(color: Style.sec),
      ),
    );
  }

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Future<void> _login() async {
    final f = context.read<FirebaseService>();
    String? s =
        await f.emailSignIn(_emailController.text, _passController.text);

    if (mounted) {
      if (FirebaseService().user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s ?? "Unkown Error")));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()));
      }
    }
  }

  void _forgotPassword() {}
}
