import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool isCollapsed = false; // State to track sidebar collapse
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _fidoPinController = TextEditingController();
  final TextEditingController _credentialPinController =
      TextEditingController();

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _fidoPinController.dispose();
    _credentialPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode using Provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Define colors based on theme
    final backgroundColor =
        isDarkMode ? const Color(0xFF111111) : Colors.grey[200]!;

    // Create a gradient for light/dark mode
    final gradientColors =
        isDarkMode
            ? [
              const Color(0xFF1A1A1A),
              const Color(0xFF101010),
              const Color(0xFF080808),
            ]
            : [Colors.grey[200]!, Colors.grey[350]!, Colors.grey[400]!];

    final textColor = isDarkMode ? Colors.white : Colors.grey[800]!;
    final cardColor = isDarkMode ? const Color(0xFF272727) : Colors.grey[300]!;
    final buttonColor =
        isDarkMode ? const Color(0xFF272727) : Colors.grey[300]!;

    // Shadow colors for neumorphic effect
    final cardShadowLight =
        isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.9);

    final cardShadowDark =
        isDarkMode
            ? Colors.black.withOpacity(0.7)
            : Colors.black.withOpacity(0.2);

    // Dialog colors
    final dialogColor =
        isDarkMode ? const Color(0xFF202020) : Colors.grey[100]!;
    final dialogTextColor = isDarkMode ? Colors.white : Colors.grey[800]!;
    final dialogBorderColor =
        isDarkMode ? Colors.grey[700]! : Colors.grey[400]!;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                  colors: gradientColors,
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
                            // Header
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                'Account',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            // Get Started Card
                            _buildGetStartedCard(
                              cardColor: cardColor,
                              cardShadowLight: cardShadowLight,
                              cardShadowDark: cardShadowDark,
                              textColor: textColor,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons in a Row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    'PIN Management',
                                    Icons.pin_outlined,
                                    () => _showPinDialog(
                                      context,
                                      dialogColor,
                                      dialogTextColor,
                                      dialogBorderColor,
                                      isDarkMode,
                                    ),
                                    buttonColor: buttonColor,
                                    cardShadowLight: cardShadowLight,
                                    cardShadowDark: cardShadowDark,
                                    textColor: textColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    'Fingerprint Management',
                                    Icons.fingerprint,
                                    () => _showFingerprintDialog(
                                      context,
                                      dialogColor,
                                      dialogTextColor,
                                      dialogBorderColor,
                                      isDarkMode,
                                    ),
                                    buttonColor: buttonColor,
                                    cardShadowLight: cardShadowLight,
                                    cardShadowDark: cardShadowDark,
                                    textColor: textColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    'Credential Management',
                                    Icons.key_outlined,
                                    () => _showCredentialDialog(
                                      context,
                                      dialogColor,
                                      dialogTextColor,
                                      dialogBorderColor,
                                      isDarkMode,
                                    ),
                                    buttonColor: buttonColor,
                                    cardShadowLight: cardShadowLight,
                                    cardShadowDark: cardShadowDark,
                                    textColor: textColor,
                                  ),
                                ),
                              ],
                            ),
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
  }

  Widget _buildGetStartedCard({
    required Color cardColor,
    required Color cardShadowLight,
    required Color cardShadowDark,
    required Color textColor,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardShadowLight,
            offset: const Offset(-3, -3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: cardShadowDark,
            offset: const Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade300,
            width: 1.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set up your authentication settings now',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Icon(Icons.edit_outlined, color: textColor.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Add and manage authentication methods OATH / PIV / FIDO2 for your Security keys',
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    required Color buttonColor,
    required Color cardShadowLight,
    required Color cardShadowDark,
    required Color textColor,
  }) {
    return Container(
      height: 48, // Fixed height for all buttons
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: cardShadowLight,
            offset: const Offset(-2, -2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: cardShadowDark,
            offset: const Offset(2, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPinDialog(
    BuildContext context,
    Color dialogColor,
    Color textColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    // Clear controllers before showing dialog
    _oldPinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();

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
      builder: (BuildContext context) {
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
            decoration: BoxDecoration(
              color: dialogBgColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with rounded corners
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Old PIN:',
                              style: TextStyle(
                                fontSize: 14,
                                color: dialogTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _oldPinController,
                              decoration: InputDecoration(
                                hintText: 'Please input old PIN',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: dialogTextColor.withOpacity(0.5),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
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
                              style: TextStyle(
                                fontSize: 13,
                                color: dialogTextColor,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'New PIN:',
                              style: TextStyle(
                                fontSize: 14,
                                color: dialogTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _newPinController,
                              decoration: InputDecoration(
                                hintText: 'Please input new PIN',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: dialogTextColor.withOpacity(0.5),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
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
                              style: TextStyle(
                                fontSize: 13,
                                color: dialogTextColor,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Confirm PIN:',
                              style: TextStyle(
                                fontSize: 14,
                                color: dialogTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _confirmPinController,
                              decoration: InputDecoration(
                                hintText: 'Please input confirm PIN',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: dialogTextColor.withOpacity(0.5),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
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
                              style: TextStyle(
                                fontSize: 13,
                                color: dialogTextColor,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ],
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
                          'Change PIN',
                          style: TextStyle(
                            color: dialogTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          // Validate and process PIN change
                          if (_newPinController.text ==
                              _confirmPinController.text) {
                            // Process PIN change
                            Navigator.of(context).pop();
                            // Show success message or handle further actions
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PIN changed successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // Show error that PINs don't match
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'New PIN and Confirm PIN do not match',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                backgroundColor:
                                    isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                              ),
                            );
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
  }

  void _showFingerprintDialog(
    BuildContext context,
    Color dialogColor,
    Color textColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    // Clear controller before showing dialog
    _fidoPinController.clear();

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
      builder: (BuildContext context) {
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
            decoration: BoxDecoration(
              color: dialogBgColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with rounded corners
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
                    'Fingerprint Management',
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
                      Text(
                        'Please verify FIDO2 PIN before accessing fingerprint management',
                        style: TextStyle(fontSize: 14, color: dialogTextColor),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'FIDO2 PIN:',
                              style: TextStyle(
                                fontSize: 14,
                                color: dialogTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _fidoPinController,
                              decoration: InputDecoration(
                                hintText: 'Please input FIDO PIN',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: dialogTextColor.withOpacity(0.5),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
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
                              style: TextStyle(
                                fontSize: 13,
                                color: dialogTextColor,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ],
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
                          'Verify',
                          style: TextStyle(
                            color: dialogTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          // Process FIDO verification
                          if (_fidoPinController.text.isNotEmpty) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fingerprint verification successful',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter FIDO PIN',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                backgroundColor:
                                    isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                              ),
                            );
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
  }

  void _showCredentialDialog(
    BuildContext context,
    Color dialogColor,
    Color textColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    // Clear controller before showing dialog
    _credentialPinController.clear();

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
      builder: (BuildContext context) {
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
            decoration: BoxDecoration(
              color: dialogBgColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with rounded corners
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
                    'Credential Management',
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
                      Text(
                        'Please verify your credentials before accessing credential management',
                        style: TextStyle(fontSize: 14, color: dialogTextColor),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Credential PIN:',
                              style: TextStyle(
                                fontSize: 14,
                                color: dialogTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _credentialPinController,
                              decoration: InputDecoration(
                                hintText: 'Please input Credential PIN',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: dialogTextColor.withOpacity(0.5),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
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
                              style: TextStyle(
                                fontSize: 13,
                                color: dialogTextColor,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ],
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
                          'Verify',
                          style: TextStyle(
                            color: dialogTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          // Process Credential verification
                          if (_credentialPinController.text.isNotEmpty) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Credential verification successful',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter Credential PIN',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                backgroundColor:
                                    isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                              ),
                            );
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
  }
}
