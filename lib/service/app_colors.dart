import 'package:flutter/material.dart';

class Style {
  static bool _isLight = true;
  static late Color _back;
  static late Color _main;
  static late Color _sec;
  static late TextStyle _headingStyle;
  static late TextStyle _miniTextStyle;
  static late OutlineInputBorder _outBorder;
  static late OutlineInputBorder _outBorderF;
  static late OutlineInputBorder _outEBorder;
  static late OutlineInputBorder _outEBorderF;
  static late TextStyle _textStyle;

  static void initColors() {
    _back = _isLight ? Colors.white : const Color.fromARGB(255, 35, 35, 35);
    _main = _isLight ? const Color.fromARGB(255, 0, 0, 0) : Colors.white;
    _sec = Colors.blue;
    _headingStyle =
        TextStyle(color: _main, fontSize: 22, fontWeight: FontWeight.bold);
    _miniTextStyle = const TextStyle(
        color: Color.fromARGB(255, 154, 154, 154),
        fontSize: 14,
        fontWeight: FontWeight.bold);
    _outBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Color.lerp(_main, _back, 0.5)!));
    _outBorderF = OutlineInputBorder(borderSide: BorderSide(color: _main));
    _outEBorder =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    _outEBorderF =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    _textStyle = TextStyle(color: _main);
  }

  static void toggleDarkMode() {
    _isLight = !_isLight;
    initColors();
  }

  static InputDecoration getInputDecoration(bool isOut,
      {String hintText = "", bool isLabel = false, Widget? suffix}) {
    return InputDecoration(
      enabledBorder: isOut ? _outBorder : null,
      focusedBorder: isOut ? _outBorderF : null,
      errorBorder: isOut ? _outEBorder : null,
      focusedErrorBorder: isOut ? _outEBorderF : null,
      hintText: (!isLabel && hintText != "") ? hintText : null,
      label: (isLabel && hintText != "")
          ? Text(
              hintText,
              style: _miniTextStyle,
            )
          : null,
      suffixIcon: suffix,
    );
  }

  static Color get back => _back;
  static Color get main => _main;
  static Color get sec => _sec;
  static TextStyle get headingStyle => _headingStyle;
  static TextStyle get miniTextStyle => _miniTextStyle;
  static TextStyle get textStyle => _textStyle;
}
