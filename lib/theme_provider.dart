// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   late SharedPreferences _prefs;
//   String _currentTheme = 'system';
//   ThemeMode _themeMode = ThemeMode.system;

//   ThemeProvider() {
//     _loadTheme();
//   }

//   Future<void> _loadTheme() async {
//     _prefs = await SharedPreferences.getInstance();
//     _currentTheme = _prefs.getString('theme') ?? 'system';
//     switch (_currentTheme) {
//       case 'light':
//         _themeMode = ThemeMode.light;
//         break;
//       case 'dark':
//         _themeMode = ThemeMode.dark;
//         break;
//       default:
//         _themeMode = ThemeMode.system;
//     }
//     notifyListeners();
//   }

//   String get currentTheme => _currentTheme;
//   ThemeMode get themeMode => _themeMode;

//   void setTheme(String theme, {bool notify = true}) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _currentTheme = theme;
//     prefs.setString('theme', theme);

//     switch (theme) {
//       case 'light':
//         _themeMode = ThemeMode.light;
//         break;
//       case 'dark':
//         _themeMode = ThemeMode.dark;
//         break;
//       default:
//         _themeMode = ThemeMode.system;
//     }

//     if (notify) {
//       notifyListeners();
//     }
//   }
// }

// theme_provider.dart
// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    final themeModeString = _prefs.getString(_themeKey) ?? 'system';
    _themeMode = _getThemeModeFromString(themeModeString);
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    final mode = _getThemeModeFromString(theme);
    await setThemeMode(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, _getStringFromThemeMode(mode));
    notifyListeners();
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _getThemeModeFromString(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
