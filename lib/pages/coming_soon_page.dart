import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/sidebar.dart';

class ComingSoonPage extends StatefulWidget {
  final String feature;

  const ComingSoonPage({super.key, required this.feature});

  @override
  State<ComingSoonPage> createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Setup animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        // Define colors based on theme
        final backgroundColor =
            isDarkMode
                ? const Color.fromARGB(221, 31, 32, 31)
                : Colors.grey[200];
        final cardColor =
            isDarkMode ? const Color.fromARGB(255, 46, 46, 46) : Colors.white;
        final textColor = isDarkMode ? Colors.white70 : Colors.black87;
        final accentColor = isDarkMode ? Colors.blue[300] : Colors.blue[700];

        return Scaffold(
          appBar: AppBar(title: Text(widget.feature)),
          body: Row(
            children: [
              // Sidebar component
              Sidebar(
                isCollapsed: isCollapsed,
                onToggle: () {
                  setState(() {
                    isCollapsed = !isCollapsed;
                  });
                },
              ),

              // Main content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors:
                          isDarkMode
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
                  child: Center(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDarkMode
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated icon
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Icon(
                                  _getFeatureIcon(widget.feature),
                                  size: 80,
                                  color: accentColor,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Feature name
                          Text(
                            widget.feature,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Coming soon text
                          Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: accentColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'We\'re working hard to bring you this feature. Stay tuned for updates!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Return button
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Return to Home'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  isDarkMode ? Colors.black : Colors.white,
                              backgroundColor: accentColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  IconData _getFeatureIcon(String feature) {
    switch (feature.toLowerCase()) {
      case 'usb':
        return Icons.usb;
      case 'nfc':
        return Icons.wifi;
      case 'hello business':
        return Icons.business;
      default:
        return Icons.construction;
    }
  }
}
