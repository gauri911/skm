// // // import 'dart:async';
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'home_page.dart';
// // // import 'package:usb_communication/usb_fido.dart';
// // // import '../models/feitian_security_key.dart';
// // // import '../providers/verification_provider.dart';

// // // class KeyVerificationPage extends StatefulWidget {
// // //   const KeyVerificationPage({super.key});

// // //   @override
// // //   // ignore: library_private_types_in_public_api
// // //   _KeyVerificationPageState createState() => _KeyVerificationPageState();
// // // }

// // // class _KeyVerificationPageState extends State<KeyVerificationPage> {
// // //   bool _isChecking = false;
// // //   final UsbFido _usbFido = UsbFido();
// // //   Timer? _scanTimer; // Timer for periodic scanning

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     // Clear any previous verification status
// // //     _clearVerificationStatus();
// // //     // Start periodic scanning for the security key
// // //     _scanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
// // //       if (!mounted || _isChecking) return;
// // //       _checkForKey(silent: true);
// // //     });
// // //   }

// // //   Future<void> _clearVerificationStatus() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     await prefs.remove('keyVerified');
// // //     await prefs.remove('detectedKeyName');
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _scanTimer?.cancel(); // Cancel timer when widget is disposed
// // //     super.dispose();
// // //   }

// // //   Future<void> _checkForKey({bool silent = false}) async {
// // //     // If already checking, exit early
// // //     if (_isChecking) return;

// // //     setState(() {
// // //       _isChecking = true;
// // //     });

// // //     try {
// // //       String? devicePath;
// // //       FeitianSecurityKey? detectedKey;

// // //       // Check for any of the supported Feitian security keys
// // //       for (final securityKey in feitianSecurityKeys) {
// // //         print(
// // //           "Checking for USB device with VID: ${securityKey.vid}, PID: ${securityKey.pid} (${securityKey.name})",
// // //         );

// // //         final path = _usbFido.findUsbDevice(securityKey.vid, securityKey.pid);

// // //         if (path != null) {
// // //           devicePath = path;
// // //           detectedKey = securityKey;
// // //           break; // Stop checking once we find a matching device
// // //         }
// // //       }

// // //       print("Device path: $devicePath");

// // //       await Future.delayed(const Duration(milliseconds: 300));

// // //       if (!mounted) return;

// // //       setState(() {
// // //         _isChecking = false;
// // //       });

// // //       if (devicePath != null && detectedKey != null) {
// // //         // Success: Device found
// // //         print("Security key detected: ${detectedKey.name} at: $devicePath");

// // //         // Store in shared preferences that key is verified
// // //         final prefs = await SharedPreferences.getInstance();
// // //         await prefs.setBool('keyVerified', true);
// // //         await prefs.setString('detectedKeyName', detectedKey.name);

// // //         // Update verification status in the provider
// // //         if (mounted) {
// // //           final verificationProvider = Provider.of<VerificationProvider>(context, listen: false);
// // //           verificationProvider.updateVerificationStatus(true);
// // //         }

// // //         // Stop the periodic scanning
// // //         _scanTimer?.cancel();

// // //         // Navigate to home page after key is verified
// // //         Navigator.of(context).pushReplacement(
// // //           MaterialPageRoute(builder: (context) => const HomePage()),
// // //         );
// // //       } else if (!silent) {
// // //         // No supported key found
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text(
// // //               'Security key not detected. Please insert your Feitian key.',
// // //             ),
// // //             backgroundColor: Colors.red,
// // //             duration: Duration(seconds: 2),
// // //           ),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       print("Error detecting security key: $e");

// // //       if (!mounted) return;

// // //       setState(() {
// // //         _isChecking = false;
// // //       });

// // //       if (!silent) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text('Error detecting security key: ${e.toString()}'),
// // //             backgroundColor: Colors.red,
// // //             duration: const Duration(seconds: 2),
// // //           ),
// // //         );
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('Key Verification')),
// // //       body: const Center(child: Text('Key Verification Page')),
// // //     );
// // //   }
// // // }

// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'home_page.dart';
// // import 'package:usb_communication/usb_fido.dart';
// // import '../models/feitian_security_key.dart';
// // import '../providers/verification_provider.dart';

// // class KeyVerificationPage extends StatefulWidget {
// //   const KeyVerificationPage({super.key});

// //   @override
// //   _KeyVerificationPageState createState() => _KeyVerificationPageState();
// // }

// // class _KeyVerificationPageState extends State<KeyVerificationPage> {
// //   bool _isChecking = false;
// //   bool _isKeyDetected = false;
// //   final UsbFido _usbFido = UsbFido();
// //   Timer? _scanTimer;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _clearVerificationStatus();
// //     _scanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
// //       if (!mounted || _isChecking) return;
// //       _checkForKey(silent: true);
// //     });
// //   }

// //   Future<void> _clearVerificationStatus() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('keyVerified');
// //     await prefs.remove('detectedKeyName');
// //   }

// //   @override
// //   void dispose() {
// //     _scanTimer?.cancel();
// //     super.dispose();
// //   }

// //   Future<void> _checkForKey({bool silent = false}) async {
// //     if (_isChecking) return;

// //     setState(() {
// //       _isChecking = true;
// //       _isKeyDetected = false;
// //     });

// //     try {
// //       String? devicePath;
// //       FeitianSecurityKey? detectedKey;

// //       for (final securityKey in feitianSecurityKeys) {
// //         print(
// //           "Checking for USB device with VID: ${securityKey.vid}, PID: ${securityKey.pid} (${securityKey.name})",
// //         );

// //         final path = _usbFido.findUsbDevice(securityKey.vid, securityKey.pid);

// //         if (path != null) {
// //           devicePath = path;
// //           detectedKey = securityKey;
// //           break;
// //         }
// //       }

// //       print("Device path: $devicePath");

// //       await Future.delayed(const Duration(milliseconds: 300));

// //       if (!mounted) return;

// //       if (devicePath != null && detectedKey != null) {
// //         setState(() {
// //           _isKeyDetected = true;
// //         });

// //         print("Security key detected: ${detectedKey.name} at: $devicePath");

// //         final prefs = await SharedPreferences.getInstance();
// //         await prefs.setBool('keyVerified', true);
// //         await prefs.setString('detectedKeyName', detectedKey.name);

// //         if (mounted) {
// //           final verificationProvider = Provider.of<VerificationProvider>(
// //             context,
// //             listen: false,
// //           );
// //           verificationProvider.updateVerificationStatus(true);
// //         }

// //         _scanTimer?.cancel();

// //         Navigator.of(context).pushReplacement(
// //           MaterialPageRoute(builder: (context) => const HomePage()),
// //         );
// //       } else if (!silent) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text(
// //               'Security key not detected. Please insert your Feitian key.',
// //             ),
// //             backgroundColor: Colors.red,
// //             duration: Duration(seconds: 2),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       print("Error detecting security key: $e");

// //       if (!mounted) return;

// //       if (!silent) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Error detecting security key: ${e.toString()}'),
// //             backgroundColor: Colors.red,
// //             duration: const Duration(seconds: 2),
// //           ),
// //         );
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isChecking = false;
// //         });
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text(''), centerTitle: true, elevation: 2),
// //       body: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [Colors.blue.withOpacity(0.1), Colors.white],
// //           ),
// //         ),
// //         child: Center(
// //           child: Padding(
// //             padding: const EdgeInsets.all(24.0),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 // Security Key Icon with Animation
// //                 AnimatedContainer(
// //                   duration: const Duration(milliseconds: 300),
// //                   padding: const EdgeInsets.all(20),
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     color:
// //                         _isChecking
// //                             ? Colors.blue.withOpacity(0.1)
// //                             : Colors.grey.withOpacity(0.1),
// //                   ),
// //                   child: Icon(
// //                     Icons.usb_rounded,
// //                     size: 80,
// //                     color: _isChecking ? Colors.blue : Colors.grey,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),

// //                 // Status Text
// //                 AnimatedDefaultTextStyle(
// //                   duration: const Duration(milliseconds: 300),
// //                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
// //                     color: _isChecking ? Colors.blue : Colors.grey[700],
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   child: Text(
// //                     _isChecking
// //                         ? 'Checking for security key...'
// //                         : 'No FEITIAN security key inserted',
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Instructions
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 24),
// //                   child: Text(
// //                     'Please insert your FEITIAN security key to continue ',
// //                     style: Theme.of(
// //                       context,
// //                     ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 40),

// //                 // Manual Check Button
// //                 ElevatedButton.icon(
// //                   onPressed:
// //                       _isChecking ? null : () => _checkForKey(silent: false),
// //                   icon: const Icon(Icons.refresh),
// //                   label: Text(
// //                     _isChecking ? 'Checking...' : 'Check for Key',
// //                     style: const TextStyle(fontSize: 16),
// //                   ),
// //                   style: ElevatedButton.styleFrom(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 32,
// //                       vertical: 16,
// //                     ),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(30),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),

// //                 // Loading Indicator
// //                 if (_isChecking)
// //                   Column(
// //                     children: [
// //                       const SizedBox(height: 16),
// //                       const CircularProgressIndicator(),
// //                       const SizedBox(height: 16),
// //                       Text(
// //                         'Scanning for security key...',
// //                         style: TextStyle(color: Colors.grey[600], fontSize: 14),
// //                       ),
// //                     ],
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'home_page.dart';
// import 'package:usb_communication/usb_fido.dart';
// import '../models/feitian_security_key.dart';
// import '../providers/verification_provider.dart';

// class KeyVerificationPage extends StatefulWidget {
//   const KeyVerificationPage({super.key});

//   @override
//   _KeyVerificationPageState createState() => _KeyVerificationPageState();
// }

// class _KeyVerificationPageState extends State<KeyVerificationPage> {
//   bool _isChecking = false;
//   bool _isKeyDetected = false;
//   final UsbFido _usbFido = UsbFido();
//   Timer? _scanTimer;

//   @override
//   void initState() {
//     super.initState();
//     _clearVerificationStatus();
//     _scanTimer = Timer.periodic(const Duration(seconds: 11), (_) {
//       if (!mounted || _isChecking) return;
//       _checkForKey(silent: true);
//     });
//   }

//   Future<void> _clearVerificationStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('keyVerified');
//     await prefs.remove('detectedKeyName');
//   }

//   @override
//   void dispose() {
//     _scanTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _checkForKey({bool silent = false}) async {
//     if (_isChecking) return;

//     setState(() {
//       _isChecking = true;
//       _isKeyDetected = false;
//     });

//     try {
//       String? devicePath;
//       FeitianSecurityKey? detectedKey;

//       for (final securityKey in feitianSecurityKeys) {
//         print(
//           "Checking for USB device with VID: ${securityKey.vid}, PID: ${securityKey.pid} (${securityKey.name})",
//         );

//         final path = _usbFido.findUsbDevice(securityKey.vid, securityKey.pid);

//         if (path != null) {
//           devicePath = path;
//           detectedKey = securityKey;
//           break;
//         }
//       }

//       print("Device path: $devicePath");

//       await Future.delayed(const Duration(milliseconds: 300));

//       if (!mounted) return;

//       if (devicePath != null && detectedKey != null) {
//         setState(() {
//           _isKeyDetected = true;
//         });

//         print("Security key detected: ${detectedKey.name} at: $devicePath");

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('keyVerified', true);
//         await prefs.setString('detectedKeyName', detectedKey.name);

//         if (mounted) {
//           final verificationProvider = Provider.of<VerificationProvider>(
//             context,
//             listen: false,
//           );
//           verificationProvider.updateVerificationStatus(true);
//         }

//         _scanTimer?.cancel();

//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const HomePage()),
//         );
//       } else if (!silent) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Security key not detected. Please insert your Feitian key.',
//             ),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error detecting security key: $e");

//       if (!mounted) return;

//       if (!silent) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error detecting security key: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isChecking = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text(''), centerTitle: true, elevation: 2),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue.withOpacity(0.1), Colors.white],
//           ),
//         ),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Security Key Image
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   child: Image.asset(
//                     'assets/images/security_key.png', // Make sure this path matches your asset
//                     height: 150,
//                     width: 150,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Status Text
//                 Text(
//                   _isChecking
//                       ? 'Checking for security key...'
//                       : 'No FEITIAN security key inserted',
//                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                     color: _isChecking ? Colors.blue : Colors.grey[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),

//                 // Instructions
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Text(
//                     'Please insert your FEITIAN security key to continue ',
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 // Manual Check Button
//                 ElevatedButton.icon(
//                   onPressed:
//                       _isChecking ? null : () => _checkForKey(silent: false),
//                   icon: const Icon(Icons.refresh),
//                   label: Text(
//                     _isChecking ? 'Checking...' : 'Check for Key',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 16,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Loading Indicator
//                 if (_isChecking)
//                   Column(
//                     children: [
//                       const SizedBox(height: 16),
//                       const CircularProgressIndicator(),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Scanning for security key...',
//                         style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:usb_communication/usb_fido.dart';
import '../models/feitian_security_key.dart';
import '../providers/verification_provider.dart';

class KeyVerificationPage extends StatefulWidget {
  const KeyVerificationPage({super.key});

  @override
  _KeyVerificationPageState createState() => _KeyVerificationPageState();
}

class _KeyVerificationPageState extends State<KeyVerificationPage> {
  bool _isChecking = false;
  bool _isKeyDetected = false;
  final UsbFido _usbFido = UsbFido();
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _clearVerificationStatus();
    _scanTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || _isChecking) return;
      _checkForKey(silent: true);
    });
  }

  Future<void> _clearVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('keyVerified');
    await prefs.remove('detectedKeyName');
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForKey({bool silent = false}) async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
      _isKeyDetected = false;
    });

    try {
      String? devicePath;
      FeitianSecurityKey? detectedKey;

      for (final securityKey in feitianSecurityKeys) {
        print(
          "Checking for USB device with VID: ${securityKey.vid}, PID: ${securityKey.pid} (${securityKey.name})",
        );

        final path = _usbFido.findUsbDevice(securityKey.vid, securityKey.pid);

        if (path != null) {
          devicePath = path;
          detectedKey = securityKey;
          break;
        }
      }

      print("Device path: $devicePath");

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      if (devicePath != null && detectedKey != null) {
        setState(() {
          _isKeyDetected = true;
        });

        print("Security key detected: ${detectedKey.name} at: $devicePath");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('keyVerified', true);
        await prefs.setString('detectedKeyName', detectedKey.name);

        if (mounted) {
          final verificationProvider = Provider.of<VerificationProvider>(
            context,
            listen: false,
          );
          verificationProvider.updateVerificationStatus(true);
        }

        _scanTimer?.cancel();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Security key not detected. Please insert your Feitian key.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error detecting security key: $e");

      if (!mounted) return;

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting security key: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), centerTitle: true, elevation: 2),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // USB Security Key Image
                  Image.asset(
                    'assets/usb_security_key.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),

                  // Status Text
                  Text(
                    _isChecking
                        ? 'Checking for security key...'
                        : 'No FEITIAN security key inserted',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: _isChecking ? Colors.blue : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Please insert your FEITIAN security key to continue',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Manual Check Button
                  ElevatedButton.icon(
                    onPressed:
                        _isChecking ? null : () => _checkForKey(silent: false),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      _isChecking ? 'Checking...' : 'Check for Key',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Loading Indicator
                  if (_isChecking)
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Scanning for security key...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
