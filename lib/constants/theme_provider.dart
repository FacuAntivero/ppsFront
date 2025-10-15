import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: CupertinoColors.black,
    secondary: const Color(0xFFEEEEEE),
    tertiary: const Color(0xFFB6B6B6),
    surface: CupertinoColors.black,
    onSurface: Colors.white,
    shadow: const Color(0xFF646464).withOpacity(0.12),
    primaryContainer: CupertinoColors.white,
    secondaryContainer: CupertinoColors.systemGrey6, //background profileScreen
    onBackground: const Color(0xFFE2E2E2),
  ),
  //textTheme: _baseTextTheme(CupertinoColors.black),
);

final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: CupertinoColors.black,
  colorScheme: ColorScheme.dark(
    primary: CupertinoColors.white,
    secondary: const Color(0xFFEEEEEE),
    tertiary: const Color(0xFFB6B6B6),
    surface: CupertinoColors.white,
    onSurface: Colors.black,
    shadow: CupertinoColors.black.withOpacity(0.7),
    primaryContainer: CupertinoColors.black,
    secondaryContainer: CupertinoColors.black, //background profileScreen
  ),
  //textTheme: _baseTextTheme(CupertinoColors.white),
);
