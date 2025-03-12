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

  // Function to show snackbar for feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Function to handle copying text to clipboard
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label copied to clipboard');
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
                      fontSize: 18, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800], // Match home page text color
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 16),
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
                  SizedBox(height: 24),
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
                          SizedBox(height: 16),
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
          children: [
            Expanded(
              child: _buildEmbossedCard(
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
                    SizedBox(height: 8),
                    Text('U2F',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('FIDO2',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEmbossedCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildChip('FIDO2')),
                        SizedBox(width: 8),
                        Expanded(child: _buildChip('PIV')),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildChip('OATH')),
                        SizedBox(width: 8),
                        Expanded(child: _buildChip('OTP')),
                      ],
                    ),
                  ],
                ),
                padding: EdgeInsets.all(8),
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
