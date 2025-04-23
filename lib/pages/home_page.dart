import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../models/feitian_security_key.dart';
import '../providers/piv_provider.dart';
import 'dart:async';
import '../services/pin_management_service.dart';
import '../services/usb_detection_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const String DEFAULT_PIN = "123456";
  static const String DEFAULT_PUK = "12345678";
  static const int MIN_PIN_LENGTH = 6;
  static const int MAX_PIN_LENGTH = 8;
  static const int MIN_PUK_LENGTH = 8;
  static const int MAX_PUK_LENGTH = 12;

  bool isCollapsed = false; // State to track sidebar collapse
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  String securityKeyName = 'FEITIAN iePass K44 USB Security Key';
  String securityKeyImage = 'assets/usb_security_key.png';

  // Add USB detection service
  late UsbDetectionService _usbDetectionService;
  late StreamSubscription _usbSubscription;

  // Add state variables to track button states
  Map<String, bool> interfaceButtonStates = {
    'FIDO': false,
    'PIV': false,
    'CCID': false,
    'OTP': false,
  };

  // Flag to track if a SET PIN dialog is already showing
  bool _isPinDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _loadDetectedKeyInfo();

    // Initialize animation controller with duration
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true); // Makes the animation loop back and forth

    // Create a slight rotation animation
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Create a slight scale animation
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize USB detection
    _usbDetectionService = UsbDetectionService();
    _usbSubscription = _usbDetectionService.onUsbConnectionChanged.listen(
      _handleUsbConnection,
    );
  }

  // Handle when a USB device is connected
  void _handleUsbConnection(bool isConnected) async {
    if (isConnected) {
      // Check if PIN is set
      final pinService = PinManagementService();
      bool isPinSet = await pinService.isPinSet();

      if (!isPinSet && !_isPinDialogShowing) {
        // If PIN is not set and no dialog is currently showing, show the PIN setup dialog
        if (mounted) {
          // Set flag to prevent multiple dialogs
          setState(() {
            _isPinDialogShowing = true;
          });

          // Use Future.delayed to avoid showing dialog during build
          Future.delayed(Duration.zero, () {
            _showSetPinDialog(context);
          });
        }
      }
    }
  }

  Future<void> _loadDetectedKeyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final detectedKeyName = prefs.getString('detectedKeyName');

    if (detectedKeyName != null) {
      final detectedKey = feitianSecurityKeys.firstWhere(
        (key) => key.name == detectedKeyName,
        orElse: () => feitianSecurityKeys.first,
      );

      setState(() {
        securityKeyName = detectedKey.name;
        securityKeyImage = detectedKey.imagePath;
      });
    }
  }

  @override
  void dispose() {
    _usbSubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Modified function to show custom snackbar for feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.white,
            fontSize: 13,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.black54, // Semi-transparent background
        margin: EdgeInsets.only(
          bottom: 20,
          left:
              MediaQuery.of(context).size.width * 0.5, // Position in right half
          right: 20,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        width: 200, // Fixed width to make it smaller
      ),
    );
  }

  // Function to toggle interface button state
  void _toggleInterfaceButton(String interface) {
    setState(() {
      interfaceButtonStates[interface] = !interfaceButtonStates[interface]!;
    });
    _showSnackBar(
      '$interface interface ${interfaceButtonStates[interface]! ? 'enabled' : 'disabled'}',
    );

    // Show appropriate management dialog based on interface
    if (interface == 'PIV' && interfaceButtonStates[interface]!) {
      _showPIVManagementDialog();
    } else if (interface == 'FIDO' && interfaceButtonStates[interface]!) {
      _showFIDOManagementDialog();
    }
  }

  // Function to show PIV Management Dialog - implementing the missing function
  Future<void> _showPIVManagementDialog() async {
    final pinService = PinManagementService();
    bool isPinSet = await pinService.isPinSet();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PIV Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'PIN Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white60 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (!isPinSet)
                      _buildPIVActionButton(
                        'Set PIN',
                        Icons.add_circle_outline,
                        () {
                          Navigator.pop(context);
                          _showSetPinDialog(context);
                        },
                      ),
                    _buildPIVActionButton('Change PIN', Icons.vpn_key, () {
                      Navigator.pop(context);
                      if (isPinSet) {
                        _showChangePinDialog(context);
                      } else {
                        _showSnackBar(
                          'You must set a PIN before you can change it',
                        );
                      }
                    }),
                    _buildPIVActionButton('Change PUK', Icons.shield, () {
                      Navigator.pop(context);
                      _showChangePUKDialog();
                    }),
                    _buildPIVActionButton('Reset PIN', Icons.refresh, () {
                      Navigator.pop(context);
                      _showResetDialog();
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Certificate Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white60 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildCertButton(
                        'Import Certificate',
                        Icons.upload_file,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCertButton(
                        'Export Certificate',
                        Icons.download,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildCertButton(
                        'Generate Key Pair',
                        Icons.vpn_key,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCertButton(
                        'Change Manager Key',
                        Icons.security,
                        () {
                          Navigator.pop(context);
                          _showChangeManagerKeyDialog();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to show FIDO Management Dialog
  Future<void> _showFIDOManagementDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FIDO Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFIDOManagementOption('PIN MANAGEMENT', [
                  _buildFIDOManagementAction('Change PIN', Icons.vpn_key, () {
                    Navigator.pop(context);
                    _showChangePinDialog(context);
                  }),
                ]),
                const SizedBox(height: 16),
                _buildFIDOManagementOption('FINGERPRINT MANAGEMENT', [
                  _buildFIDOManagementAction(
                    'Fingerprint Management',
                    Icons.fingerprint,
                    () {
                      Navigator.pop(context);
                      // TODO: Implement fingerprint management
                      _showSnackBar('Fingerprint management coming soon');
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                _buildFIDOManagementOption('CREDENTIAL MANAGEMENT', [
                  _buildFIDOManagementAction(
                    'Enum Credential',
                    Icons.list_alt,
                    () {
                      Navigator.pop(context);
                      // TODO: Implement credential enumeration
                      _showSnackBar('Credential enumeration coming soon');
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                _buildFIDOManagementOption('RESET', [
                  _buildFIDOManagementAction('Reset Device', Icons.restore, () {
                    Navigator.pop(context);
                    _showResetDialog();
                  }),
                ]),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget for FIDO management options
  Widget _buildFIDOManagementOption(String title, List<Widget> actions) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white60 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: actions),
        ),
      ],
    );
  }

  // Helper widget for FIDO management actions
  Widget _buildFIDOManagementAction(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  // New method for setting initial PIN
  void _showSetPinDialog(BuildContext context) {
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    bool isLoading = false;
    String errorMessage = '';
    String infoMessage =
        'Set a PIN for your USB security key. This PIN will be required for future operations.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set PIN'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(infoMessage, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPinController,
                      decoration: const InputDecoration(
                        labelText: 'New PIN (6-8 digits)',
                        border: OutlineInputBorder(),
                        helperText: 'PIN must be 6-8 digits',
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPinController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm PIN',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    // Reset the dialog flag when the dialog is closed
                    this.setState(() {
                      _isPinDialogShowing = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Set PIN'),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            // Validate PIN input
                            if (newPinController.text.isEmpty ||
                                confirmPinController.text.isEmpty) {
                              setState(() {
                                errorMessage = 'Please enter both fields';
                              });
                              return;
                            }

                            if (newPinController.text.length < MIN_PIN_LENGTH) {
                              setState(() {
                                errorMessage =
                                    'PIN must be at least $MIN_PIN_LENGTH digits';
                              });
                              return;
                            }

                            if (newPinController.text.length > MAX_PIN_LENGTH) {
                              setState(() {
                                errorMessage =
                                    'PIN must be at most $MAX_PIN_LENGTH digits';
                              });
                              return;
                            }

                            if (newPinController.text !=
                                confirmPinController.text) {
                              setState(() {
                                errorMessage = 'PINs do not match';
                              });
                              return;
                            }

                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                              infoMessage =
                                  'Setting PIN on USB security key...';
                            });

                            try {
                              final pinService = PinManagementService();
                              bool success = await pinService.setInitialPin(
                                newPinController.text,
                              );

                              if (success) {
                                // Reset the dialog flag when the dialog is successfully completed
                                this.setState(() {
                                  _isPinDialogShowing = false;
                                });
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('PIN set successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() {
                                  isLoading = false;
                                  errorMessage =
                                      'Failed to set PIN. Make sure the security key is connected.';
                                });
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Error: ${e.toString()}';
                              });
                            }
                          },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Reset the dialog flag when the dialog is closed in any way (including tapping outside if barrierDismissible is true)
      this.setState(() {
        _isPinDialogShowing = false;
      });
    });
  }

  // Modified method for changing existing PIN
  void _showChangePinDialog(BuildContext context) {
    final TextEditingController oldPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    bool isLoading = false;
    String errorMessage = '';
    String infoMessage = 'Change the PIN for your USB security key.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change PIN'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(infoMessage, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: oldPinController,
                      decoration: const InputDecoration(
                        labelText: 'Current PIN',
                        border: OutlineInputBorder(),
                        helperText: 'Enter your current PIN',
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPinController,
                      decoration: const InputDecoration(
                        labelText: 'New PIN (6-8 digits)',
                        border: OutlineInputBorder(),
                        helperText: 'PIN must be 6-8 digits',
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPinController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New PIN',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Change PIN'),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            // Validate PIN input
                            if (oldPinController.text.isEmpty ||
                                newPinController.text.isEmpty ||
                                confirmPinController.text.isEmpty) {
                              setState(() {
                                errorMessage = 'Please fill all fields';
                              });
                              return;
                            }

                            if (newPinController.text.length < MIN_PIN_LENGTH) {
                              setState(() {
                                errorMessage =
                                    'New PIN must be at least $MIN_PIN_LENGTH digits';
                              });
                              return;
                            }

                            if (newPinController.text.length > MAX_PIN_LENGTH) {
                              setState(() {
                                errorMessage =
                                    'New PIN must be at most $MAX_PIN_LENGTH digits';
                              });
                              return;
                            }

                            if (newPinController.text !=
                                confirmPinController.text) {
                              setState(() {
                                errorMessage = 'New PINs do not match';
                              });
                              return;
                            }

                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                              infoMessage =
                                  'Changing PIN on USB security key...';
                            });

                            try {
                              final pinService = PinManagementService();

                              // First validate the current PIN
                              bool isCurrentPinValid = await pinService
                                  .validatePin(oldPinController.text);

                              if (!isCurrentPinValid) {
                                setState(() {
                                  isLoading = false;
                                  errorMessage = 'Current PIN is incorrect';
                                });
                                return;
                              }

                              // If valid, change the PIN
                              bool success = await pinService.changePin(
                                oldPinController.text,
                                newPinController.text,
                              );

                              if (success) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('PIN changed successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() {
                                  isLoading = false;
                                  errorMessage =
                                      'Failed to change PIN. Make sure the security key is connected.';
                                });
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Error: ${e.toString()}';
                              });
                            }
                          },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Generic dialog builder for PIN/PUK/Manager Key
  Future<void> _showCredentialDialog({
    required String title,
    required String oldLabel,
    required String newLabel,
    required String confirmLabel,
    required bool useDefaultOption,
    required String defaultValue,
    required int minLength,
    required int maxLength,
    required Future<bool> Function(String oldValue, String newValue) onSubmit,
  }) async {
    bool useDefault = false;
    TextEditingController oldController = TextEditingController();
    TextEditingController newController = TextEditingController();
    TextEditingController confirmController = TextEditingController();

    String? validateInput(String value) {
      if (value.isEmpty) return 'Please enter $newLabel';
      if (!RegExp(r'^\d+$').hasMatch(value)) return '$newLabel must be numeric';
      if (value.contains(' ')) return '$newLabel cannot contain spaces';
      if (value.length < minLength || value.length > maxLength) {
        return '$newLabel must be $minLength-$maxLength digits';
      }
      return null;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (useDefaultOption)
                      Row(
                        children: [
                          Checkbox(
                            value: useDefault,
                            onChanged: (bool? value) {
                              setState(() {
                                useDefault = value ?? false;
                              });
                            },
                          ),
                          Text('Use default $oldLabel'),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            '$oldLabel:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: oldController,
                            decoration: InputDecoration(
                              hintText: 'Please input $oldLabel',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              isDense: true,
                            ),
                            obscureText: true,
                            enabled: !useDefault,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            '$newLabel:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: newController,
                            decoration: InputDecoration(
                              hintText: 'Please input $newLabel',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              isDense: true,
                            ),
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            '$confirmLabel:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: confirmController,
                            decoration: InputDecoration(
                              hintText: 'Please confirm $newLabel',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              isDense: true,
                            ),
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final newValue = newController.text;
                            final confirmValue = confirmController.text;
                            final oldValue =
                                useDefault ? defaultValue : oldController.text;
                            final error = validateInput(newValue);
                            if (error != null) {
                              _showSnackBar(error);
                              return;
                            }
                            if (newValue != confirmValue) {
                              _showSnackBar(
                                'New and Confirm values do not match',
                              );
                              return;
                            }
                            if (!useDefault && oldValue.isEmpty) {
                              _showSnackBar('Please enter $oldLabel');
                              return;
                            }
                            try {
                              final success = await onSubmit(
                                oldValue,
                                newValue,
                              );
                              if (success) {
                                _showSnackBar('$title successful');
                                Navigator.of(context).pop();
                              } else {
                                _showSnackBar('Failed to $title');
                              }
                            } catch (e) {
                              _showSnackBar('Error: ${e.toString()}');
                            }
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Refactor dialog calls to use the generic dialog
  Future<void> _showChangePINDialog() async {
    await _showCredentialDialog(
      title: 'Change PIN',
      oldLabel: 'Old PIN',
      newLabel: 'New PIN',
      confirmLabel: 'Confirm PIN',
      useDefaultOption: true,
      defaultValue: DEFAULT_PIN,
      minLength: MIN_PIN_LENGTH,
      maxLength: MAX_PIN_LENGTH,
      onSubmit: (oldPin, newPin) async {
        final pinService = PinManagementService();
        return pinService.changePin(oldPin, newPin);
      },
    );
  }

  Future<void> _showChangePUKDialog() async {
    await _showCredentialDialog(
      title: 'Change PUK',
      oldLabel: 'Old PUK',
      newLabel: 'New PUK',
      confirmLabel: 'Confirm PUK',
      useDefaultOption: true,
      defaultValue: DEFAULT_PUK,
      minLength: MIN_PUK_LENGTH,
      maxLength: MAX_PUK_LENGTH,
      onSubmit: (oldPuk, newPuk) async {
        final pivProvider = Provider.of<PivProvider>(context, listen: false);
        return pivProvider.changePuk(oldPuk, newPuk);
      },
    );
  }

  Future<void> _showChangeManagerKeyDialog() async {
    await _showCredentialDialog(
      title: 'Change Manager Key',
      oldLabel: 'Old Key',
      newLabel: 'New Key',
      confirmLabel: 'Confirm Key',
      useDefaultOption: true,
      defaultValue: '', // Set to actual default if available
      minLength: 6, // Adjust as needed
      maxLength: 24, // Adjust as needed
      onSubmit: (oldKey, newKey) async {
        final pivProvider = Provider.of<PivProvider>(context, listen: false);
        return pivProvider.changeManagementKey(oldKey, newKey);
      },
    );
  }

  // Function to show Reset PIN dialog
  Future<void> _showResetDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          title: Text(
            'Reset PIN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to reset the PIN to default?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              child: const Text('Reset', style: TextStyle(fontSize: 16)),
              onPressed: () async {
                try {
                  final pivProvider = Provider.of<PivProvider>(
                    context,
                    listen: false,
                  );
                  final success = await pivProvider.resetToDefaultPin();
                  if (success) {
                    _showSnackBar('PIN reset to default');
                  } else {
                    _showSnackBar('Failed to reset PIN');
                  }
                } catch (e) {
                  _showSnackBar('Error: ${e.toString()}');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // PIN status indicator widget to add to your UI where appropriate
  Widget _buildPinStatusIndicator() {
    return FutureBuilder<bool>(
      future: PinManagementService().isPinSet(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        bool isPinSet = snapshot.data ?? false;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPinSet ? Icons.lock : Icons.lock_open,
              color: isPinSet ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isPinSet ? 'PIN Set' : 'PIN Not Set',
              style: TextStyle(
                color: isPinSet ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPIVActionButton(
    String label,
    IconData icon, [
    Function()? onTap,
  ]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black87 : null,
            border: Border(
              bottom: BorderSide(
                color: isDarkMode ? Colors.white10 : Colors.grey[300]!,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isDarkMode ? Colors.white54 : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertButton(String label, IconData icon, [Function()? onTap]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black87 : Colors.grey[500],
          border: Border.all(
            color: isDarkMode ? Colors.white12 : Colors.grey[600]!,
          ),
          boxShadow:
              isDarkMode
                  ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0.7,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDarkMode ? Colors.white70 : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog() async {
    TextEditingController textController = TextEditingController(
      text: securityKeyName,
    );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode ? Colors.black : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side:
                isDarkMode
                    ? const BorderSide(color: Colors.white10, width: 1)
                    : BorderSide.none,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Security Key Name',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color:
                              isDarkMode ? Colors.white24 : Colors.grey[400]!,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color:
                              isDarkMode ? Colors.white24 : Colors.grey[400]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color:
                              isDarkMode
                                  ? Colors.blue[700]!
                                  : Colors.blue[400]!,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color:
                                isDarkMode ? Colors.white54 : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.blue.shade300
                                    : Colors.blue[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            securityKeyName = textController.text;
                          });
                          Navigator.of(context).pop();
                          _showSnackBar('Security key name updated');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              // Add PIN status indicator to the app bar
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildPinStatusIndicator(),
              ),
            ],
          ),
          body: Row(
            children: [
              Sidebar(
                isCollapsed: isCollapsed,
                onToggle: () {
                  setState(() {
                    isCollapsed = !isCollapsed;
                  });
                },
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors:
                          themeProvider.isDarkMode
                              ? [
                                const Color.fromARGB(221, 0, 0, 0),
                                const Color.fromARGB(221, 31, 32, 31),
                                const Color.fromARGB(221, 43, 41, 41),
                              ]
                              : [
                                Colors.grey[200]!,
                                Colors.grey[350]!,
                                Colors.grey[400]!,
                              ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics:
                              constraints.maxHeight < 600
                                  ? const AlwaysScrollableScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Text(
                                    'Home',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.white70
                                              : const Color.fromARGB(
                                                255,
                                                6,
                                                6,
                                                6,
                                              ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                _buildEmbossedCard(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          securityKeyName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                themeProvider.isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: _showEditDialog,
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color:
                                              themeProvider.isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black45,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  bottomBorder: true,
                                  isDarkMode: themeProvider.isDarkMode,
                                ),
                                const SizedBox(height: 10),
                                _buildDataRows(themeProvider.isDarkMode),
                                const SizedBox(height: 24),
                                Center(
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform(
                                        alignment: Alignment.center,
                                        transform:
                                            Matrix4.identity()
                                              ..rotateZ(
                                                _rotationAnimation.value,
                                              )
                                              ..scale(_scaleAnimation.value),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(
                                                  0.2 +
                                                      0.1 *
                                                          _animationController
                                                              .value,
                                                ),
                                                blurRadius:
                                                    20 *
                                                    _animationController.value,
                                                spreadRadius:
                                                    5 *
                                                    _animationController.value,
                                              ),
                                            ],
                                          ),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      securityKeyImage,
                                      height: 180,
                                      width: 210,
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.white70
                                              : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white60 : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRows(bool isDarkMode) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildEmbossedCard(
                child: _buildInfoTile('PID & VID', '045D&6789E'),
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEmbossedCard(
                child: _buildInfoTile('CosVersion No', '1.6.00'),
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildEmbossedCard(
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Functions',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'U2F',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'FIDO2',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEmbossedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applications',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildClickableChip('FIDO', isDarkMode),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildClickableChip('PIV', isDarkMode)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildClickableChip('CCID', isDarkMode),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildClickableChip('OTP', isDarkMode)),
                      ],
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmbossedCard({
    required Widget child,
    bool bottomBorder = false,
    EdgeInsets padding = const EdgeInsets.all(16),
    bool isDarkMode = false,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color.fromARGB(255, 46, 46, 46)
                : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.5),
            offset: const Offset(-3, -3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            color:
                isDarkMode
                    ? const Color.fromARGB(255, 195, 195, 195).withOpacity(0.4)
                    : const Color.fromARGB(255, 151, 151, 151).withOpacity(0.2),
            offset: const Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 0.8,
          ),
        ],
        border:
            bottomBorder
                ? Border(
                  bottom: BorderSide(
                    color:
                        isDarkMode
                            ? Colors.blue.shade700
                            : Colors.blue.shade300,
                    width: 1.5,
                  ),
                )
                : null,
      ),
      child: child,
    );
  }

  Widget _buildClickableChip(String label, bool isDarkMode) {
    bool isActive = interfaceButtonStates[label] ?? false;

    return GestureDetector(
      onTap: () => _toggleInterfaceButton(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? (isDarkMode ? Colors.grey[600] : Colors.grey[500])
                  : (isDarkMode ? Colors.grey[800] : Colors.grey[300]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 0.5,
              )
            else
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.9),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            if (isActive)
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0.5,
              )
            else
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.15),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color:
                isActive
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black54),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
