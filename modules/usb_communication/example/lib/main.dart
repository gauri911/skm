import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feitian Authenticator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF232F34),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feitian Authenticator'),
        backgroundColor: const Color(0xFF344955),
        actions: const [
          Row(
            children: [
              Icon(Icons.usb, color: Colors.white),
              SizedBox(width: 5),
              Text('USB Connected'),
              SizedBox(width: 15),
              Icon(Icons.nfc, color: Colors.white),
              SizedBox(width: 5),
              Text('Plus FIDO Key'),
              SizedBox(width: 15),
              Icon(Icons.business, color: Colors.white),
              SizedBox(width: 5),
              Text('Hello for Business'),
              SizedBox(width: 15),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF344955),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF232F34),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              _buildDrawerItem(Icons.home, 'Home', true),
              _buildDrawerItem(Icons.account_circle, 'Accounts'),
              _buildDrawerItem(Icons.vpn_key, 'Passkeys'),
              _buildDrawerItem(FontAwesomeIcons.certificate, 'Certificates'),
              _buildDrawerItem(Icons.slideshow, 'Slots'),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Home',
              style: TextStyle(color: Colors.blue, fontSize: 24),
            ),
            const SizedBox(height: 20),
            const Text(
              'FEITIAN ePass FIDO2 FIDO U2F\nUSB-A+NFC Security Key | K9',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Serial No: 864942749\nVersion No: 2.1.0',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/device_image.png', // Replace with actual path
                height: 150,
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png', // Replace with actual path
                    height: 50,
                  ),
                  const Text(
                    'FEITIAN\nWE BUILD SECURITY',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, [bool isSelected = false]) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white,
        ),
      ),
      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
      onTap: () {
        // Handle navigation
      },
    );
  }
}
