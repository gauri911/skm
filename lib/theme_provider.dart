import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _currentTheme = 'system';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _currentTheme = _prefs.getString('theme') ?? 'system';
    switch (_currentTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  String get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;

  void setTheme(String theme, {bool notify = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentTheme = theme;
    prefs.setString('theme', theme);

    switch (theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    if (notify) {
      notifyListeners();
    }
  }
}
