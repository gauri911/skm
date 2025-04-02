import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:usb_communication/usb_fido.dart';

class KeyVerificationPage extends StatefulWidget {
  const KeyVerificationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KeyVerificationPageState createState() => _KeyVerificationPageState();
}

class _KeyVerificationPageState extends State<KeyVerificationPage> {
  bool _isChecking = false;
  final UsbFido _usbFido = UsbFido();
  Timer? _scanTimer; // Timer for periodic scanning

  @override
  void initState() {
    super.initState();
    // Start periodic scanning for the security key
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _isChecking) return;
      _checkForKey(silent: true);
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  Future<void> _checkForKey({bool silent = false}) async {
    // If already checking, exit early
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Correct VID and PID for the specific Feitian security key
      const String vid = "096e";
      const String pid = "086e";

      print("Checking for USB device with VID: $vid, PID: $pid");

      final devicePath = _usbFido.findUsbDevice(vid, pid);

      print("Device path: $devicePath");

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      setState(() {
        _isChecking = false;
      });

      if (devicePath != null) {
        // Success: Device found
        print("Security key detected at: $devicePath");

        // Store in shared preferences that key is verified
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('keyVerified', true);

        // Stop the periodic scanning
        _scanTimer?.cancel();

        // Navigate to home page after key is verified
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (!silent) {
        // Key not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Security key not detected. Please insert your Feitian key.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error detecting security key: $e");

      if (!mounted) return;

      setState(() {
        _isChecking = false;
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting security key: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Key Verification'),
      ),
      body: const Center(
        child: Text('Key Verification Page'),
      ),
    );
  }
}
