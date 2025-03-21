// import 'package:flutter/material.dart';

// class SettingsDialog extends StatefulWidget {
//   const SettingsDialog({super.key});

//   @override
//   State<SettingsDialog> createState() => _SettingsDialogState();
// }

// class _SettingsDialogState extends State<SettingsDialog> {
//   // Default theme is light mode
//   String _selectedTheme = 'light';

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text(
//         'Settings',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Theme',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Light mode radio button
//           RadioListTile<String>(
//             title: const Text(
//               'Light Mode',
//               style: TextStyle(fontSize: 14),
//             ),
//             value: 'light',
//             groupValue: _selectedTheme,
//             onChanged: (value) {
//               setState(() {
//                 _selectedTheme = value!;
//                 // Theme change logic will be added later
//               });
//             },
//             contentPadding: const EdgeInsets.symmetric(horizontal: 0),
//             dense: true,
//           ),
//           // Dark mode radio button
//           RadioListTile<String>(
//             title: const Text(
//               'Dark Mode',
//               style: TextStyle(fontSize: 14),
//             ),
//             value: 'dark',
//             groupValue: _selectedTheme,
//             onChanged: (value) {
//               setState(() {
//                 _selectedTheme = value!;
//                 // Theme change logic will be added later
//               });
//             },
//             contentPadding: const EdgeInsets.symmetric(horizontal: 0),
//             dense: true,
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text('Close'),
//         ),
//         TextButton(
//           onPressed: () {
//             // Save settings logic will be implemented later
//             Navigator.of(context).pop();
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }
// settings_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    // Initialize theme based on current app theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedTheme =
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode
              ? 'dark'
              : 'light';
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Make sure _selectedTheme is initialized even if the post-frame callback hasn't run yet
    if (!mounted) return const SizedBox.shrink();
    _selectedTheme =
        _selectedTheme ?? (themeProvider.isDarkMode ? 'dark' : 'light');

    return AlertDialog(
      title: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Light mode radio button
          RadioListTile<String>(
            title: const Text(
              'Light Mode',
              style: TextStyle(fontSize: 14),
            ),
            value: 'light',
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            dense: true,
          ),
          // Dark mode radio button
          RadioListTile<String>(
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontSize: 14),
            ),
            value: 'dark',
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            dense: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () async {
            // Save theme setting and apply it immediately
            await themeProvider.setTheme(_selectedTheme);
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
