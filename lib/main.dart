// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'pages/home_page.dart';
// import 'pages/accounts_page.dart';
// import 'pages/slots_page.dart';
// import 'pages/key_verification_page.dart';
// import 'theme_provider.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => ThemeProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _isKeyVerified = false;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkKeyStatus();
//   }

//   Future<void> _checkKeyStatus() async {
//     // Check if key has been verified previously
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _isKeyVerified = prefs.getBool('keyVerified') ?? false;
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return MaterialApp(
//           title: 'Dashboard',
//           theme: ThemeData.light(),
//           darkTheme: ThemeData.dark(),
//           themeMode: themeProvider.themeMode,
//           home: _isLoading
//               ? const Scaffold(body: Center(child: CircularProgressIndicator()))
//               : _isKeyVerified
//                   ? const HomePage()
//                   : const KeyVerificationPage(),
//           routes: {
//             '/home': (context) => const HomePage(),
//             '/accounts': (context) => const AccountsPage(),
//             '/slots': (context) => const SlotsPage(),
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/accounts_page.dart';
import 'pages/slots_page.dart';
import 'pages/key_verification_page.dart';
import 'theme_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isKeyVerified = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkKeyStatus();
  }

  Future<void> _checkKeyStatus() async {
    // Check if key has been verified previously
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isKeyVerified = prefs.getBool('keyVerified') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FEITIAN Authenticator',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: _isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _isKeyVerified
                  ? const HomePage()
                  : const KeyVerificationPage(),
          routes: {
            '/': (context) => const HomePage(),
            '/accounts': (context) => const AccountsPage(),
            '/slots': (context) => const SlotsPage(),
            '/help': (context) => const Scaffold(
                  body: Center(child: Text("Help Page")),
                ),
            '/usb': (context) => const Scaffold(
                  body: Center(child: Text("USB Connection Page")),
                ),
            '/nfc': (context) => const Scaffold(
                  body: Center(child: Text("NFC Connection Page")),
                ),
            '/business': (context) => const Scaffold(
                  body: Center(child: Text("Business Page")),
                ),
          },
        );
      },
    );
  }
}
