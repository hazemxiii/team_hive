import 'package:flutter/material.dart';

class Style {
  static bool _isLight = true;
  static late Color _back;
  static late Color _main;
  static late Color _sec;
  static late Color _section;
  static late TextStyle _headingStyle;
  static late TextStyle _miniTextStyle;
  static late OutlineInputBorder _outBorder;
  static late OutlineInputBorder _outBorderF;
  static late OutlineInputBorder _outEBorder;
  static late OutlineInputBorder _outEBorderF;
  static late UnderlineInputBorder _underBorder;
  static late UnderlineInputBorder _underBorderF;
  static late UnderlineInputBorder _underEBorder;
  static late UnderlineInputBorder _underEBorderF;
  static late TextStyle _textStyle;

  static void initColors() {
    _back = _isLight ? Colors.white : const Color.fromARGB(255, 35, 35, 35);
    _main = _isLight ? const Color.fromARGB(255, 0, 0, 0) : Colors.white;
    _sec = Colors.green;
    // _sec = Colors.blue;
    _section = const Color(0xFFF3F4F6);
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

    _underBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: Color.lerp(_main, _back, 0.5)!));
    _underBorderF = UnderlineInputBorder(borderSide: BorderSide(color: _main));
    _underEBorder =
        const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red));
    _underEBorderF =
        const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red));

    _textStyle = TextStyle(color: _main);
  }

  static void toggleDarkMode() {
    _isLight = !_isLight;
    initColors();
  }

  static InputDecoration getInputDecoration(bool isOut,
      {String hintText = "",
      bool isLabel = false,
      Widget? suffix,
      bool isError = false}) {
    return InputDecoration(
      enabledBorder: isOut
          ? (isError ? _outEBorder : _outBorder)
          : (isError ? _underEBorder : _underBorder),
      focusedBorder: isOut
          ? (isError ? _outEBorderF : _outBorderF)
          : (isError ? _underEBorderF : _underBorderF),
      errorBorder: isOut ? _outEBorder : _underEBorder,
      focusedErrorBorder: isOut ? _outEBorderF : _underEBorderF,
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
  static Color get section => _section;
  static TextStyle get headingStyle => _headingStyle;
  static TextStyle get miniTextStyle => _miniTextStyle;
  static TextStyle get textStyle => _textStyle;
}
