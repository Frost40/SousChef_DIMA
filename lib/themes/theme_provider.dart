import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/themes/dark_mode.dart';
import 'package:sous_chef/themes/theme_extensions.dart';

class ThemeProvider with ChangeNotifier {
  static const String THEME_KEY = 'theme_preference';
  ThemeData _themeData = lightMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void toggleTheme() {
    themeData = themeData == lightMode ? darkMode : lightMode;
  }

  // Load saved theme preference
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDark = prefs.getBool(THEME_KEY) ?? false;
    themeData = isDark ? darkMode : lightMode;
  }

  // Save theme preference
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_KEY, isDarkMode);
  }
}