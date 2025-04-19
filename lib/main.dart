import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/accounts_page.dart';
import 'pages/slots_page.dart';
import 'pages/key_verification_page.dart';
import 'theme_provider.dart';
import 'services/usb_monitor_service.dart';
import 'providers/verification_provider.dart';
import 'providers/piv_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear verification status at startup to ensure fresh verification
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('keyVerified');
  await prefs.remove('detectedKeyName');

  // Initialize providers that don't depend on PivProvider
  final providers = [
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ChangeNotifierProvider(create: (context) => VerificationProvider()),
    Provider(create: (context) => UsbMonitorService()),
  ];

  // Try to add PivProvider
  try {
    // Wrap in a lazy provider to delay initialization until needed
    providers.add(ChangeNotifierProvider.value(value: PivProvider()));
  } catch (e) {
    debugPrint('Error initializing PivProvider: $e');
    // Continue without PivProvider - we'll handle this in the UI
  }

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  late UsbMonitorService _usbMonitor;
  late VerificationProvider _verificationProvider;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkKeyStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _usbMonitor = Provider.of<UsbMonitorService>(context);
    _verificationProvider = Provider.of<VerificationProvider>(context);
    _usbMonitor.startMonitoring();
    _setupDeviceMonitoring();
  }

  void _setupDeviceMonitoring() {
    _usbMonitor.deviceStatus.listen((bool devicePresent) async {
      print(
        'Device status changed: ${devicePresent ? 'Connected' : 'Disconnected'}',
      );
      print('Current verification status: ${_verificationProvider.isVerified}');
      print(
        'Previous verification status: ${_verificationProvider.wasVerified}',
      );

      if (!devicePresent && _verificationProvider.isVerified) {
        print('Key unplugged detected, clearing verification status');
        await _clearVerificationStatus();
        _verificationProvider.clearVerification();
        print('Verification status updated to: false');

        // Force navigation to key verification page
        if (_navigatorKey.currentState != null) {
          print('Forcing navigation to key verification page');
          _navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const KeyVerificationPage(),
            ),
            (route) => false,
          );
        }
      }
    });
  }

  Future<void> _clearVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('keyVerified');
    await prefs.remove('detectedKeyName');
    print('Verification status cleared from SharedPreferences');
  }

  Future<void> _checkKeyStatus() async {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _usbMonitor.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Consumer<VerificationProvider>(
          builder: (context, verificationProvider, child) {
            print(
              'Building MaterialApp with isVerified: ${verificationProvider.isVerified}',
            );
            return MaterialApp(
              navigatorKey: _navigatorKey,
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
              home:
                  _isLoading
                      ? const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      )
                      : verificationProvider.isVerified
                      ? const HomePage()
                      : const KeyVerificationPage(),
              routes: {
                '/accounts': (context) => const AccountsPage(),
                '/slots': (context) => const SlotsPage(),
                '/help':
                    (context) =>
                        const Scaffold(body: Center(child: Text("Help Page"))),
                '/usb':
                    (context) => const Scaffold(
                      body: Center(child: Text("USB Connection Page")),
                    ),
                '/nfc':
                    (context) => const Scaffold(
                      body: Center(child: Text("NFC Connection Page")),
                    ),
                '/business':
                    (context) => const Scaffold(
                      body: Center(child: Text("Business Page")),
                    ),
              },
            );
          },
        );
      },
    );
  }
}
