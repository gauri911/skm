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
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeName = prefs.getString('theme') ?? 'light';

    if (themeName == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  // Set theme and save to SharedPreferences
  Future<void> setTheme(String themeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);

    if (themeName == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  // Convenience methods
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setTheme('dark');
    } else {
      await setTheme('light');
    }
  }
}
