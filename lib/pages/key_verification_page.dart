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
      // VID and PID for Feitian security key
      const String vid = "085D&096E";
      const String pid = "085D&096E";

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
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.vpn_key_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Security Key Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please insert your Feitian security key',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Insert your Feitian security key into an available USB port to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : () => _checkForKey(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isChecking
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Checking...'),
                          ],
                        )
                      : const Text('Check for Key'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Show help dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Security Key Help'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(
                                  'To use this application, you need a Feitian security key:'),
                              SizedBox(height: 8),
                              Text(
                                  '1. Make sure your security key is properly inserted'),
                              Text('2. Try another USB port if not detected'),
                              Text(
                                  '3. Ensure you\'re using a compatible Feitian key'),
                              Text(
                                  '4. Restart the application if problems persist'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Need help?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
