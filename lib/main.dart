import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/accounts_page.dart';
import 'pages/credentials_page.dart';
import 'pages/certificates_page.dart';
import 'pages/slots_page.dart';
import 'widgets/sidebar.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Dashboard',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          initialRoute: '/', // Define the initial route
          routes: {
            '/': (context) => const HomePage(),
            '/accounts': (context) => const AccountsPage(),
            '/credentials': (context) => const CredentialsPage(),
            '/certificates': (context) => const CertificatesPage(),
            '/slots': (context) => const SlotsPage(),
          },
        );
      },
    );
  }
}
