import 'package:flutter/material.dart';

List<ThemeData> getThemes() {
  return [
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
    ),
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Color.fromRGBO(33, 33, 33, 1),
    ),
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Color.fromRGBO(30, 50, 50, 1),
    ),
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Color.fromRGBO(40, 20, 25, 1),
    ),
  ];
}
