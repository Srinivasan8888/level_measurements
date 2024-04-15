// import 'package:flutter/material.dart';
//
// ThemeData lightMode = ThemeData(
//     colorScheme: ColorScheme.light(
//         brightness: Brightness.light,
//         background: Colors.grey.shade400,
//         primary: Colors.grey.shade300,
//         secondary: Colors.grey.shade200));
//
// ThemeData darkMode = ThemeData(
//     colorScheme: ColorScheme.dark(
//         brightness: Brightness.dark,
//         background: Colors.grey.shade900,
//         primary: Colors.grey.shade800,
//         secondary: Colors.grey.shade700));

import 'package:flutter/material.dart';

// ThemeData lightMode = ThemeData(
//     colorScheme: ColorScheme.light(
//         brightness: Brightness.light,
//         background: Colors.cyan.shade50,
//         primary: Colors.lightBlue.shade100,
//         secondary: Colors.lightBlue.shade200,
//         tertiary: Colors.blue.shade300));
//
// ThemeData darkMode = ThemeData(
//     colorScheme: ColorScheme.dark(
//         brightness: Brightness.dark,
//         background: Colors.grey.shade800,
//         primary: Colors.grey.shade600,
//         secondary: Colors.grey.shade700,
//         tertiary: Colors.grey.shade500));

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    background: Color.fromRGBO(203, 241, 245, 1.0),
    primary: Color.fromRGBO(277, 253, 253, 1.0),
    secondary: Color.fromRGBO(166, 227, 223, 1.0),
    tertiary: Color.fromRGBO(113, 201, 206, 1.0),
  ),
);

ThemeData darkMode = ThemeData(
    colorScheme: const ColorScheme.dark(
  brightness: Brightness.dark,
  background: Color.fromRGBO(34, 40, 49, 1.0),
  primary: Color.fromRGBO(57, 62, 70, 1.0),
  secondary: Color.fromRGBO(0, 173, 181, 1.0),
  tertiary: Color.fromRGBO(238, 238, 238, 1.0),
));
