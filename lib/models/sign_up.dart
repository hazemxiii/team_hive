import 'package:flutter/material.dart';

class SignUp {
  static TextEditingController email = TextEditingController();
  static TextEditingController password = TextEditingController();
  static TextEditingController confirmPassword = TextEditingController();
  static TextEditingController fName = TextEditingController();
  static TextEditingController lName = TextEditingController();
  static MemoryImage? image;

  static List<GlobalKey<FormState>> formKeys = [GlobalKey(), GlobalKey()];

  static bool _isValidEmail(String? email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email ?? "");
  }

  static String? emailValidator(String? v) {
    if ((v ?? "").trim() == "") {
      return "Can't be Empty";
    }
    if (!_isValidEmail(v)) {
      return "Please Enter A Valid Email Address";
    }
    return null;
  }

  static String? passwordValidator(String? v) {
    v = v ?? "";
    if (v.trim().length < 6) {
      return "Password Must Be At Least 6 Characters";
    }
    if (password.text != confirmPassword.text) {
      return "Passwords Don't Match";
    }
    return null;
  }

  static String? nameValidator(String? v) {
    v = v ?? "";
    if (v.trim() == "") {
      return "Can't be Empty";
    }
    return null;
  }
}
