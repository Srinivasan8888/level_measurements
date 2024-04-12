import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    colorScheme: ColorScheme.light(
  brightness: Brightness.light,
  background: Colors.grey.shade400,
));

ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme.dark(
  brightness: Brightness.dark,
  background: Colors.grey.shade900,
));
