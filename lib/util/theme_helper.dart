import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }

class ThemeHelper with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeHelper() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme');

    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (theme == AppTheme.light) {
      _themeMode = ThemeMode.light;
      prefs.setString('theme', 'light');
    } else if (theme == AppTheme.dark) {
      _themeMode = ThemeMode.dark;
      prefs.setString('theme', 'dark');
    } else {
      _themeMode = ThemeMode.system;
      prefs.setString('theme', 'system');
    }

    notifyListeners();
  }
}


