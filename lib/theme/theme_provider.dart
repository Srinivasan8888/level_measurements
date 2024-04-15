import 'package:flutter/material.dart';
import 'package:level/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeProvider() {
    loadTheme();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    saveTheme();
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  void saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeData == darkMode);
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeData = isDarkMode ? darkMode : lightMode;
    notifyListeners();
  }
}
