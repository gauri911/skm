import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/sidebar.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = false; // State to track sidebar collapse
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  String securityKeyName = 'FEITIAN iePass K44 USB Security Key';

  // Add state variables to track button states
  Map<String, bool> interfaceButtonStates = {
    'FIDO': false,
    'PIV': false,
    'CCID': false,
    'OTP': false,
  };

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with duration
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true); // Makes the animation loop back and forth

    // Create a slight rotation animation
    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Create a slight scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Modified function to show custom snackbar for feedback
  void _showSnackBar(String message) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show the custom SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.white,
            fontSize: 13,
          ),
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.black54, // Semi-transparent background
        margin: EdgeInsets.only(
          bottom: 20,
          left:
              MediaQuery.of(context).size.width * 0.5, // Position in right half
          right: 20,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        width: 200, // Fixed width to make it smaller
      ),
    );
  }

  // Function to handle copying text to clipboard
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label copied to clipboard');
  }

  // Function to toggle interface button state
  void _toggleInterfaceButton(String interface) {
    setState(() {
      interfaceButtonStates[interface] = !interfaceButtonStates[interface]!;
    });
    _showSnackBar(
        '$interface interface ${interfaceButtonStates[interface]! ? 'enabled' : 'disabled'}');

    // Add this code to show the PIV management dialog when PIV is enabled
    if (interface == 'PIV' && interfaceButtonStates[interface]!) {
      _showPIVManagementDialog();
    }
  }

// Function to show Change PIN dialog
  Future<void> _showChangePINDialog() async {
    bool useDefault = false;
    TextEditingController oldPinController = TextEditingController();
    TextEditingController newPinController = TextEditingController();
    TextEditingController confirmPinController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Container(
                width: 550, // Increased width
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change PIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Old PIN:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: oldPinController,
                            decoration: InputDecoration(
                              hintText: 'Please input old pin',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                            enabled: !useDefault,
                          ),
                        ),
                        SizedBox(width: 10),
                        Checkbox(
                          value: useDefault,
                          onChanged: (value) {
                            setState(() {
                              useDefault = value!;
                            });
                          },
                        ),
                        Text(
                          'Use Default',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'New PIN:',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: newPinController,
                            decoration: InputDecoration(
                              hintText: 'Please input new pin',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Confirm PIN:',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: confirmPinController,
                            decoration: InputDecoration(
                              hintText: 'Please input confirm pin',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Implement PIN change logic here
                            if (newPinController.text ==
                                confirmPinController.text) {
                              _showSnackBar('PIN changed successfully');
                              Navigator.of(context).pop();
                            } else {
                              _showSnackBar(
                                  'New PIN and Confirm PIN do not match');
                            }
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
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

// Function to show Change PUK dialog
  Future<void> _showChangePUKDialog() async {
    bool useDefault = false;
    TextEditingController oldPukController = TextEditingController();
    TextEditingController newPukController = TextEditingController();
    TextEditingController confirmPukController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Container(
                width: 550, // Increased width
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change PUK',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Old PUK:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: oldPukController,
                            decoration: InputDecoration(
                              hintText: 'Please input old PUK',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                            enabled: !useDefault,
                          ),
                        ),
                        SizedBox(width: 10),
                        Checkbox(
                          value: useDefault,
                          onChanged: (value) {
                            setState(() {
                              useDefault = value!;
                            });
                          },
                        ),
                        Text(
                          'Use Default',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'New PUK:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: newPukController,
                            decoration: InputDecoration(
                              hintText: 'Please input new PUK',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Confirm PUK:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: confirmPukController,
                            decoration: InputDecoration(
                              hintText: 'Please input confirm PUK',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Implement PUK change logic here
                            if (newPukController.text ==
                                confirmPukController.text) {
                              _showSnackBar('PUK changed successfully');
                              Navigator.of(context).pop();
                            } else {
                              _showSnackBar(
                                  'New PUK and Confirm PUK do not match');
                            }
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
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

// Function to show Change Manager Key dialog
  Future<void> _showChangeManagerKeyDialog() async {
    bool useDefault = false;
    TextEditingController oldKeyController = TextEditingController();
    TextEditingController newKeyController = TextEditingController();
    TextEditingController confirmKeyController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Container(
                width: 550, // Increased width
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Manager Key',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Old Key:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: oldKeyController,
                            decoration: InputDecoration(
                              hintText: 'Please input old key',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                            enabled: !useDefault,
                          ),
                        ),
                        SizedBox(width: 10),
                        Checkbox(
                          value: useDefault,
                          onChanged: (value) {
                            setState(() {
                              useDefault = value!;
                            });
                          },
                        ),
                        Text(
                          'Use Default',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'New Key:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: newKeyController,
                            decoration: InputDecoration(
                              hintText: 'Please input new key',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Confirm Key:',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: confirmKeyController,
                            decoration: InputDecoration(
                              hintText: 'Please input confirm key',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              isDense: true,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Implement Manager Key change logic here
                            if (newKeyController.text ==
                                confirmKeyController.text) {
                              _showSnackBar('Manager Key changed successfully');
                              Navigator.of(context).pop();
                            } else {
                              _showSnackBar(
                                  'New Key and Confirm Key do not match');
                            }
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
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
                SizedBox(height: 8),
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
            SizedBox(width: 10),
            ElevatedButton(
              child: Text(
                'Reset',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                // Implement PIN reset logic here
                _showSnackBar('PIN reset to default');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show the PIV management dialog
  Future<void> _showPIVManagementDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // Increased width
            constraints: BoxConstraints(maxWidth: 800), // Increased max width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PIN MANAGEMENT section
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIN MANAGEMENT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildPIVActionButton('Change PIN',
                                Icons.arrow_right, _showChangePINDialog),
                            _buildPIVActionButton('Change PUK',
                                Icons.arrow_right, _showChangePUKDialog),
                            _buildPIVActionButton('Change Manager Key',
                                Icons.arrow_right, _showChangeManagerKeyDialog),
                            _buildPIVActionButton(
                                'Reset', Icons.arrow_right, _showResetDialog),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // CERT MANAGEMENT section
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CERT MANAGEMENT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: isDarkMode
                                                ? Colors.grey[600]!
                                                : Colors.grey[400]!),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: 'Authentication (9a)',
                                        isExpanded: true,
                                        icon: Icon(Icons.arrow_drop_down),
                                        dropdownColor: isDarkMode
                                            ? Colors.grey[700]
                                            : null,
                                        style: TextStyle(
                                          color:
                                              isDarkMode ? Colors.white : null,
                                        ),
                                        items: <String>[
                                          'Authentication (9a)',
                                          'Digital Signature (9c)',
                                          'Key Manager (9d)',
                                          'Card Authentication (9e)'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text('Slot: $value'),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {},
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    color: isDarkMode
                                        ? Colors.grey[900]
                                        : Colors.grey[700],
                                    child: Text(
                                      'Policy Manager',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCertButton(
                                            'Export', Icons.arrow_upward),
                                      ),
                                      Expanded(
                                        child: _buildCertButton(
                                            'Delete', Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCertButton(
                                            'Import', Icons.arrow_downward),
                                      ),
                                      Expanded(
                                        child: _buildCertButton(
                                            'Generate', Icons.refresh),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CertInfo:',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.grey[800],
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'No certificate loaded.',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dialog buttons
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
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

  // Helper widget for PIN management buttons
  Widget _buildPIVActionButton(String label, IconData icon,
      [Function()? onTap]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for certificate management buttons
  Widget _buildCertButton(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[500],
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Function to show edit dialog with updated styling
  Future<void> _showEditDialog() async {
    TextEditingController textController =
        TextEditingController(text: securityKeyName);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[300], // Changed to light grey color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          // Adding constraints to reduce the width
          child: Container(
            constraints: BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Security Key Name',
                    style: TextStyle(
                      fontSize: 15, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800], // Match home page text color
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: 16),
                      TextButton(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.blue[700],
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
    return Scaffold(
      // Remove the AppBar completely to eliminate the hamburger icon
      body: Row(
        children: [
          Sidebar(
            isCollapsed: isCollapsed, // Sidebar width controlled dynamically
            onToggle: () {
              setState(() {
                isCollapsed = !isCollapsed; // Toggle sidebar collapse
              });
            },
          ),
          Expanded(
            child: Container(
              // Remove any height constraints to match sidebar height
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[350]!,
                    Colors.grey[400]!,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
              child: Padding(
                // Reduced top padding to move everything up
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                // Use LayoutBuilder to get the available height
                child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    // Set physics to allow scrolling only when content exceeds height
                    physics: constraints.maxHeight < 600
                        ? AlwaysScrollableScrollPhysics()
                        : NeverScrollableScrollPhysics(),
                    child: Container(
                      // Set minimum height to match available height
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add Home text at the top with reduced bottom padding
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800], // Dark grey color
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          _buildEmbossedCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    securityKeyName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: _showEditDialog,
                                  child: Icon(Icons.edit_outlined,
                                      color: Colors.black45, size: 20),
                                ),
                              ],
                            ),
                            bottomBorder: true,
                          ),
                          // Reduced spacing between elements
                          SizedBox(height: 10),
                          _buildDataRows(),
                          // Added more spacing before the animation
                          SizedBox(height: 24),
                          Center(
                            // Wrap image in AnimatedBuilder to animate it
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  // Apply both rotation and scaling animations
                                  transform: Matrix4.identity()
                                    ..rotateZ(_rotationAnimation.value)
                                    ..scale(_scaleAnimation.value),
                                  child: Container(
                                    // Add a soft glow animation around the key
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2 +
                                              0.1 * _animationController.value),
                                          blurRadius:
                                              20 * _animationController.value,
                                          spreadRadius:
                                              5 * _animationController.value,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: Image.asset(
                                'assets/usb_security_key.png',
                                height: 180,
                                width: 210,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRows() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildEmbossedCard(
                child: _buildInfoTile('PID & VID', '045D&6789E'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEmbossedCard(
                child: _buildInfoTile('CosVersion No', '1600'),
              ),
            ),
          ],
        ),
        // Reduced spacing between rows
        SizedBox(height: 10),
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
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Text('U2F',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8),
                      Text('FIDO2',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          overflow: TextOverflow.ellipsis),
                      // Add more dummy functions to increase the height
                      SizedBox(height: 8),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
                padding:
                    EdgeInsets.all(12), // Match padding with interfaces box
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEmbossedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applications',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildClickableChip('FIDO')),
                        SizedBox(width: 8),
                        Expanded(child: _buildClickableChip('PIV')),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildClickableChip('CCID')),
                        SizedBox(width: 8),
                        Expanded(child: _buildClickableChip('OTP')),
                      ],
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4),
            InkWell(
              onTap: () => _copyToClipboard(value, title),
              child: Icon(Icons.content_copy_outlined,
                  color: Colors.black45, size: 18),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmbossedCard({
    required Widget child,
    bool bottomBorder = false,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Light gray background like in the images
        borderRadius:
            BorderRadius.circular(16), // Increased radius for softer corners
        boxShadow: [
          // White glow on top-left (like in Image 1)
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: Offset(-3, -3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          // Darker shadow on bottom-right
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
        border: bottomBorder
            ? Border(
                bottom: BorderSide(color: Colors.blue.shade300, width: 1.5))
            : null,
      ),
      child: child,
    );
  }

  // New method to create clickable interface chips
  Widget _buildClickableChip(String label) {
    // Get the active state from the map
    bool isActive = interfaceButtonStates[label] ?? false;

    return GestureDetector(
      onTap: () => _toggleInterfaceButton(label),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.grey[500]
              : Colors.grey[300], // Medium grey when active
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            // Invert shadows when active to create "pressed" effect
            if (isActive)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 0.5,
              )
            else
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                offset: Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),

            if (isActive)
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0.5,
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: Offset(2, 2),
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
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Keep this old method for compatibility but don't use it for interface buttons
  Widget _buildChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Match the color with the cards
        borderRadius:
            BorderRadius.circular(12), // Increased radius like in Image 2
        boxShadow: [
          // White glow on top-left
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
          // Darker shadow on bottom-right
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(fontSize: 14, color: Colors.black54),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
