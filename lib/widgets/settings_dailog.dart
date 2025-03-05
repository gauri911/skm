import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Add this import
import '../theme_provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: const Text('Settings dialog content'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class AppearanceDialog extends StatelessWidget {
  const AppearanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Appearance Settings'),
      content: Consumer<ThemeProvider>(
        // <-- Ensure ThemeProvider is properly set up
        builder: (context, themeProvider, child) {
          return DropdownButton<String>(
            value: themeProvider.currentTheme,
            items: const [
              DropdownMenuItem(
                value: 'light',
                child: Text('Light Mode'),
              ),
              DropdownMenuItem(
                value: 'dark',
                child: Text('Dark Mode'),
              ),
              DropdownMenuItem(
                value: 'system',
                child: Text('System Default'),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                themeProvider.setTheme(newValue);
              }
            },
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
