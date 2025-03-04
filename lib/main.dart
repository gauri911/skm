import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/accounts_page.dart';
import 'pages/credentials_page.dart';
import 'pages/certificates_page.dart';
import 'pages/slots_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FEITIAN Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[200],
        fontFamily: 'Segoe UI',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/accounts': (context) => const AccountsPage(),
        '/credentials': (context) => const CredentialsPage(),
        '/certificates': (context) => const CertificatesPage(),
        '/slots': (context) => const SlotsPage(),
      },
    );
  }
}
