import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../models/feitian_security_key.dart';
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

    // New cream color palette for dialog
    final dialogBgColor =
        isDarkMode ? const Color(0xFF2A2922) : const Color(0xFFF5F1E3);
    final dialogTextColor =
        isDarkMode ? const Color(0xFFE8E4D5) : const Color(0xFF5A5444);
    final dialogHeaderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFEAE6D7);
    final dialogBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFE0D9C0);
    final dialogAccentColor =
        isDarkMode ? const Color(0xFFD1C9A6) : const Color(0xFFBBB193);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: dialogBorderColor, width: 1.0),
          ),
          backgroundColor: dialogBgColor,
          elevation: 5,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with rounded corners
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: dialogHeaderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PIV Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dialogTextColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: dialogTextColor.withOpacity(0.7),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIN Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: dialogTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: dialogHeaderColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: dialogBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (!isPinSet)
                              _buildPIVActionButton(
                                'Set PIN',
                                Icons.add_circle_outline,
                                () {
                                  Navigator.pop(context);
                                  _showSetPinDialog(context);
                                },
                                dialogTextColor,
                                dialogBorderColor.withOpacity(0.5),
                              ),
                            _buildPIVActionButton(
                              'Change PIN',
                              Icons.vpn_key,
                              () {
                                Navigator.pop(context);
                                if (isPinSet) {
                                  _showChangePinDialog(context);
                                } else {
                                  _showSnackBar(
                                    'You must set a PIN before you can change it',
                                  );
                                }
                              },
                              dialogTextColor,
                              dialogBorderColor.withOpacity(0.5),
                            ),
                            _buildPIVActionButton(
                              'Change PUK',
                              Icons.shield,
                              () {
                                Navigator.pop(context);
                                _showChangePUKDialog();
                              },
                              dialogTextColor,
                              dialogBorderColor.withOpacity(0.5),
                            ),
                            _buildPIVActionButton(
                              'Reset PIN',
                              Icons.refresh,
                              () {
                                Navigator.pop(context);
                                _showResetDialog();
                              },
                              dialogTextColor,
                              dialogBorderColor.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Certificate Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: dialogTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCertButton(
                              'Import Certificate',
                              Icons.upload_file,
                              dialogAccentColor,
                              dialogTextColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCertButton(
                              'Export Certificate',
                              Icons.download,
                              dialogAccentColor,
                              dialogTextColor,
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
                              dialogAccentColor,
                              dialogTextColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCertButton(
                              'Change Manager Key',
                              Icons.security,
                              dialogAccentColor,
                              dialogTextColor,
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

    // Enhanced color palette for FIDO dialog
    final dialogBgColor =
        isDarkMode ? const Color(0xFF2A2922) : const Color(0xFFF5F1E3);
    final dialogTextColor =
        isDarkMode ? const Color(0xFFE8E4D5) : const Color(0xFF5A5444);
    final dialogHeaderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFEAE6D7);
    final dialogBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFE0D9C0);
    final accentColor =
        isDarkMode ? const Color(0xFFD1C9A6) : const Color(0xFFBBB193);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: dialogBorderColor, width: 1.0),
          ),
          backgroundColor: dialogBgColor,
          elevation: 8,
          child: Container(
            width: 480, // Slightly wider for better layout
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with rounded corners and subtle gradient
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        dialogHeaderColor,
                        dialogHeaderColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: dialogTextColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'FIDO Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: dialogTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: dialogTextColor.withOpacity(0.7),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                // Content with grid layout
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row with two option cards side by side
                      Row(
                        children: [
                          // PIN Management Card
                          Expanded(
                            child: _buildFIDOOptionCard(
                              title: 'PIN MANAGEMENT',
                              icon: Icons.vpn_key,
                              options: [
                                _buildFIDOActionItem(
                                  'Change PIN',
                                  Icons.edit,
                                  () {
                                    Navigator.pop(context);
                                    _showChangePinDialog(context);
                                  },
                                  dialogTextColor,
                                ),
                              ],
                              headerColor: accentColor,
                              bgColor: dialogHeaderColor.withOpacity(0.3),
                              borderColor: dialogBorderColor,
                              textColor: dialogTextColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Fingerprint Management Card
                          Expanded(
                            child: _buildFIDOOptionCard(
                              title: 'FINGERPRINT MANAGEMENT',
                              icon: Icons.fingerprint,
                              options: [
                                _buildFIDOActionItem(
                                  'Fingerprint Management',
                                  Icons.fingerprint,
                                  () {
                                    Navigator.pop(context);
                                    _showSnackBar(
                                      'Fingerprint management coming soon',
                                    );
                                  },
                                  dialogTextColor,
                                ),
                              ],
                              headerColor: accentColor,
                              bgColor: dialogHeaderColor.withOpacity(0.3),
                              borderColor: dialogBorderColor,
                              textColor: dialogTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Second row with two more option cards side by side
                      Row(
                        children: [
                          // Credential Management Card
                          Expanded(
                            child: _buildFIDOOptionCard(
                              title: 'CREDENTIAL MANAGEMENT',
                              icon: Icons.list_alt,
                              options: [
                                _buildFIDOActionItem(
                                  'Enum Credential',
                                  Icons.assignment,
                                  () {
                                    Navigator.pop(context);
                                    _showSnackBar(
                                      'Credential enumeration coming soon',
                                    );
                                  },
                                  dialogTextColor,
                                ),
                              ],
                              headerColor: accentColor,
                              bgColor: dialogHeaderColor.withOpacity(0.3),
                              borderColor: dialogBorderColor,
                              textColor: dialogTextColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Reset Card
                          Expanded(
                            child: _buildFIDOOptionCard(
                              title: 'RESET',
                              icon: Icons.restore,
                              options: [
                                _buildFIDOActionItem(
                                  'Reset Device',
                                  Icons.refresh,
                                  () {
                                    Navigator.pop(context);
                                    _showResetDialog();
                                  },
                                  dialogTextColor,
                                ),
                              ],
                              headerColor: accentColor,
                              bgColor: dialogHeaderColor.withOpacity(0.3),
                              borderColor: dialogBorderColor,
                              textColor: dialogTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget for FIDO management option cards
  Widget _buildFIDOOptionCard({
    required String title,
    required IconData icon,
    required List<Widget> options,
    required Color headerColor,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: textColor.withOpacity(0.9)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Options list
          Column(children: options),
        ],
      ),
    );
  }

  // Helper widget for FIDO action items
  Widget _buildFIDOActionItem(
    String label,
    IconData icon,
    VoidCallback onTap,
    Color textColor,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(11),
        bottomRight: Radius.circular(11),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor.withOpacity(0.8)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: textColor.withOpacity(0.6),
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Cream color palette for dialog
    final dialogBgColor =
        isDarkMode ? const Color(0xFF2A2922) : const Color(0xFFF5F1E3);
    final dialogTextColor =
        isDarkMode ? const Color(0xFFE8E4D5) : const Color(0xFF5A5444);
    final dialogHeaderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFEAE6D7);
    final dialogBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFE0D9C0);
    final dialogInputBgColor =
        isDarkMode ? const Color(0xFF201E17) : const Color(0xFFFFFFFC);
    final dialogInputBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFDAD2B4);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: dialogBorderColor, width: 1.0),
              ),
              backgroundColor: dialogBgColor,
              elevation: 5,
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: dialogHeaderColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Text(
                        'Set PIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dialogTextColor,
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            infoMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: dialogTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: newPinController,
                            decoration: InputDecoration(
                              labelText: 'New PIN (6-8 digits)',
                              labelStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor.withOpacity(
                                    0.8,
                                  ),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: dialogInputBgColor,
                              helperText: 'PIN must be 6-8 digits',
                              helperStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.6),
                              ),
                            ),
                            obscureText: true,
                            style: TextStyle(color: dialogTextColor),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: confirmPinController,
                            decoration: InputDecoration(
                              labelText: 'Confirm PIN',
                              labelStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor.withOpacity(
                                    0.8,
                                  ),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: dialogInputBgColor,
                            ),
                            obscureText: true,
                            style: TextStyle(color: dialogTextColor),
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
                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: dialogTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                            ),
                            onPressed: () {
                              // Reset the dialog flag when the dialog is closed
                              this.setState(() {
                                _isPinDialogShowing = false;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dialogHeaderColor,
                              foregroundColor: dialogTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      // Validate PIN input
                                      if (newPinController.text.isEmpty ||
                                          confirmPinController.text.isEmpty) {
                                        setState(() {
                                          errorMessage =
                                              'Please enter both fields';
                                        });
                                        return;
                                      }

                                      if (newPinController.text.length <
                                          MIN_PIN_LENGTH) {
                                        setState(() {
                                          errorMessage =
                                              'PIN must be at least $MIN_PIN_LENGTH digits';
                                        });
                                        return;
                                      }

                                      if (newPinController.text.length >
                                          MAX_PIN_LENGTH) {
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
                                        final pinService =
                                            PinManagementService();
                                        bool success = await pinService
                                            .setInitialPin(
                                              newPinController.text,
                                            );

                                        if (success) {
                                          // Reset the dialog flag when the dialog is successfully completed
                                          this.setState(() {
                                            _isPinDialogShowing = false;
                                          });
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'PIN set successfully',
                                              ),
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
                                          errorMessage =
                                              'Error: ${e.toString()}';
                                        });
                                      }
                                    },
                            child: Text(
                              'Set PIN',
                              style: TextStyle(
                                color: dialogTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset the dialog flag when the dialog is closed in any way (including tapping outside if barrierDismissible is true)
      setState(() {
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Cream color palette for dialog
    final dialogBgColor =
        isDarkMode ? const Color(0xFF2A2922) : const Color(0xFFF5F1E3);
    final dialogTextColor =
        isDarkMode ? const Color(0xFFE8E4D5) : const Color(0xFF5A5444);
    final dialogHeaderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFEAE6D7);
    final dialogBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFE0D9C0);
    final dialogInputBgColor =
        isDarkMode ? const Color(0xFF201E17) : const Color(0xFFFFFFFC);
    final dialogInputBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFDAD2B4);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: dialogBorderColor, width: 1.0),
              ),
              backgroundColor: dialogBgColor,
              elevation: 5,
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: dialogHeaderColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Text(
                        'Change PIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dialogTextColor,
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            infoMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: dialogTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: oldPinController,
                            decoration: InputDecoration(
                              labelText: 'Current PIN',
                              labelStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor.withOpacity(
                                    0.8,
                                  ),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: dialogInputBgColor,
                              helperText: 'Enter your current PIN',
                              helperStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.6),
                              ),
                            ),
                            obscureText: true,
                            style: TextStyle(color: dialogTextColor),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: newPinController,
                            decoration: InputDecoration(
                              labelText: 'New PIN (6-8 digits)',
                              labelStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor.withOpacity(
                                    0.8,
                                  ),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: dialogInputBgColor,
                              helperText: 'PIN must be 6-8 digits',
                              helperStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.6),
                              ),
                            ),
                            obscureText: true,
                            style: TextStyle(color: dialogTextColor),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: confirmPinController,
                            decoration: InputDecoration(
                              labelText: 'Confirm New PIN',
                              labelStyle: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: dialogInputBorderColor.withOpacity(
                                    0.8,
                                  ),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: dialogInputBgColor,
                            ),
                            obscureText: true,
                            style: TextStyle(color: dialogTextColor),
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
                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: dialogTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dialogHeaderColor,
                              foregroundColor: dialogTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      // Validate PIN input
                                      if (oldPinController.text.isEmpty ||
                                          newPinController.text.isEmpty ||
                                          confirmPinController.text.isEmpty) {
                                        setState(() {
                                          errorMessage =
                                              'Please fill all fields';
                                        });
                                        return;
                                      }

                                      if (newPinController.text.length <
                                          MIN_PIN_LENGTH) {
                                        setState(() {
                                          errorMessage =
                                              'New PIN must be at least $MIN_PIN_LENGTH digits';
                                        });
                                        return;
                                      }

                                      if (newPinController.text.length >
                                          MAX_PIN_LENGTH) {
                                        setState(() {
                                          errorMessage =
                                              'New PIN must be at most $MAX_PIN_LENGTH digits';
                                        });
                                        return;
                                      }

                                      if (newPinController.text !=
                                          confirmPinController.text) {
                                        setState(() {
                                          errorMessage =
                                              'New PINs do not match';
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
                                        final pinService =
                                            PinManagementService();

                                        // First validate the current PIN
                                        bool isCurrentPinValid =
                                            await pinService.validatePin(
                                              oldPinController.text,
                                            );

                                        if (!isCurrentPinValid) {
                                          setState(() {
                                            isLoading = false;
                                            errorMessage =
                                                'Current PIN is incorrect';
                                          });
                                          return;
                                        }

                                        // If valid, change the PIN
                                        bool success = await pinService
                                            .changePin(
                                              oldPinController.text,
                                              newPinController.text,
                                            );

                                        if (success) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'PIN changed successfully',
                                              ),
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
                                          errorMessage =
                                              'Error: ${e.toString()}';
                                        });
                                      }
                                    },
                            child: Text(
                              'Change PIN',
                              style: TextStyle(
                                color: dialogTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
    bool isLoading = false;
    String errorMessage = '';

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Cream color palette for dialog
    final dialogBgColor =
        isDarkMode ? const Color(0xFF2A2922) : const Color(0xFFF5F1E3);
    final dialogTextColor =
        isDarkMode ? const Color(0xFFE8E4D5) : const Color(0xFF5A5444);
    final dialogHeaderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFEAE6D7);
    final dialogBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFE0D9C0);
    final dialogInputBgColor =
        isDarkMode ? const Color(0xFF201E17) : const Color(0xFFFFFFFC);
    final dialogInputBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFDAD2B4);

    String? validateInput(String value) {
      if (value.isEmpty) return 'Please enter $newLabel';
      if (!RegExp(r'^\d+$').hasMatch(value)) return '$newLabel must be numeric';
      if (value.length < minLength)
        return '$newLabel must be at least $minLength digits';
      if (value.length > maxLength)
        return '$newLabel must be at most $maxLength digits';
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
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: dialogBorderColor, width: 1.0),
              ),
              backgroundColor: dialogBgColor,
              elevation: 5,
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: dialogHeaderColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: dialogTextColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: dialogTextColor.withOpacity(0.7),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  fillColor: MaterialStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.selected,
                                    )) {
                                      return dialogTextColor;
                                    }
                                    return dialogTextColor.withOpacity(0.3);
                                  }),
                                  checkColor: dialogTextColor,
                                ),
                                Text(
                                  'Use default $oldLabel',
                                  style: TextStyle(color: dialogTextColor),
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
                                  '$oldLabel:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: dialogTextColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: oldController,
                                  decoration: InputDecoration(
                                    hintText: 'Please input $oldLabel',
                                    hintStyle: TextStyle(
                                      color: dialogTextColor.withOpacity(0.6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor
                                            .withOpacity(0.8),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: dialogInputBgColor,
                                    isDense: true,
                                  ),
                                  obscureText: true,
                                  enabled: !useDefault,
                                  style: TextStyle(color: dialogTextColor),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  '$newLabel:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: dialogTextColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: newController,
                                  decoration: InputDecoration(
                                    hintText: 'Please input $newLabel',
                                    hintStyle: TextStyle(
                                      color: dialogTextColor.withOpacity(0.6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor
                                            .withOpacity(0.8),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: dialogInputBgColor,
                                    isDense: true,
                                  ),
                                  obscureText: true,
                                  style: TextStyle(color: dialogTextColor),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  '$confirmLabel:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: dialogTextColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: confirmController,
                                  decoration: InputDecoration(
                                    hintText: 'Please confirm $newLabel',
                                    hintStyle: TextStyle(
                                      color: dialogTextColor.withOpacity(0.6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: dialogInputBorderColor
                                            .withOpacity(0.8),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: dialogInputBgColor,
                                    isDense: true,
                                  ),
                                  obscureText: true,
                                  style: TextStyle(color: dialogTextColor),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
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
                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: dialogTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: dialogTextColor.withOpacity(0.8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dialogHeaderColor,
                              foregroundColor: dialogTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'OK',
                              style: TextStyle(
                                color: dialogTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      final newValue = newController.text;
                                      final confirmValue =
                                          confirmController.text;
                                      final oldValue =
                                          useDefault
                                              ? defaultValue
                                              : oldController.text;

                                      final error = validateInput(newValue);
                                      if (error != null) {
                                        setState(() {
                                          errorMessage = error;
                                        });
                                        return;
                                      }

                                      if (newValue != confirmValue) {
                                        setState(() {
                                          errorMessage =
                                              '$newLabel and $confirmLabel do not match';
                                        });
                                        return;
                                      }

                                      if (!useDefault && oldValue.isEmpty) {
                                        setState(() {
                                          errorMessage =
                                              'Please enter $oldLabel';
                                        });
                                        return;
                                      }

                                      setState(() {
                                        isLoading = true;
                                        errorMessage = '';
                                      });

                                      try {
                                        final success = await onSubmit(
                                          oldValue,
                                          newValue,
                                        );

                                        if (success) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '$title successful',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                            errorMessage =
                                                'Operation failed. Please try again.';
                                          });
                                        }
                                      } catch (e) {
                                        setState(() {
                                          isLoading = false;
                                          errorMessage =
                                              'Error: ${e.toString()}';
                                        });
                                      }
                                    },
                          ),
                        ],
                      ),
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
    Color? textColor,
    Color? borderColor,
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
                color:
                    borderColor ??
                    (isDarkMode ? Colors.white10 : Colors.grey[300]!),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    textColor ??
                    (isDarkMode ? Colors.white54 : Colors.grey[700]),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      textColor ??
                      (isDarkMode ? Colors.white70 : Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertButton(
    String label,
    IconData icon, [
    Color? bgColor,
    Color? textColor,
    Function()? onTap,
  ]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor ?? (isDarkMode ? Colors.black87 : Colors.grey[500]),
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
              color: textColor ?? (isDarkMode ? Colors.white70 : Colors.white),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color:
                    textColor ?? (isDarkMode ? Colors.white70 : Colors.white),
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

    // Cream color palette for dialog
    final dialogBgColor =
        isDarkMode ? const Color(0xFF2A2922) : const Color(0xFFF5F1E3);
    final dialogTextColor =
        isDarkMode ? const Color(0xFFE8E4D5) : const Color(0xFF5A5444);
    final dialogHeaderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFEAE6D7);
    final dialogBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFE0D9C0);
    final dialogInputBgColor =
        isDarkMode ? const Color(0xFF201E17) : const Color(0xFFFFFFFC);
    final dialogInputBorderColor =
        isDarkMode ? const Color(0xFF38352D) : const Color(0xFFDAD2B4);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: dialogBorderColor, width: 1.0),
          ),
          backgroundColor: dialogBgColor,
          elevation: 5,
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: dialogHeaderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Text(
                    'Edit Security Key Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dialogTextColor,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          labelText: 'Security Key Name',
                          labelStyle: TextStyle(
                            color: dialogTextColor.withOpacity(0.8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: dialogInputBorderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: dialogInputBorderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: dialogInputBorderColor.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: dialogInputBgColor,
                        ),
                        style: TextStyle(color: dialogTextColor),
                      ),
                    ],
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: dialogTextColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: dialogTextColor.withOpacity(0.8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dialogHeaderColor,
                          foregroundColor: dialogTextColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: dialogTextColor,
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method for PIV PIN Reset dialog
  void _showResetDialog() {
    _showCredentialDialog(
      title: 'Reset PIN with PUK',
      oldLabel: 'PUK',
      newLabel: 'New PIN',
      confirmLabel: 'Confirm PIN',
      useDefaultOption: true,
      defaultValue: DEFAULT_PIN,
      minLength: MIN_PIN_LENGTH,
      maxLength: MAX_PIN_LENGTH,
      onSubmit: (puk, newPin) async {
        final pinService = PinManagementService();
        return await pinService.resetPinWithPuk(puk, newPin);
      },
    );
  }

  // Method for PIV PUK Change dialog
  void _showChangePUKDialog() {
    _showCredentialDialog(
      title: 'Change PUK',
      oldLabel: 'Current PUK',
      newLabel: 'New PUK',
      confirmLabel: 'Confirm PUK',
      useDefaultOption: true,
      defaultValue: DEFAULT_PUK,
      minLength: MIN_PUK_LENGTH,
      maxLength: MAX_PUK_LENGTH,
      onSubmit: (oldPuk, newPuk) async {
        final pinService = PinManagementService();
        return await pinService.changePuk(oldPuk, newPuk, context);
      },
    );
  }

  // Method for PIV Manager Key Change dialog
  void _showChangeManagerKeyDialog() {
    _showCredentialDialog(
      title: 'Change Manager Key',
      oldLabel: 'Current Key',
      newLabel: 'New Key',
      confirmLabel: 'Confirm Key',
      useDefaultOption: true,
      defaultValue: DEFAULT_PIN,
      minLength: MIN_PIN_LENGTH,
      maxLength: MAX_PIN_LENGTH,
      onSubmit: (oldKey, newKey) async {
        final pinService = PinManagementService();
        return await pinService.changeManagerKey(oldKey, newKey, context);
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
