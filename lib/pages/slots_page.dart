import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SlotsPage extends StatefulWidget {
  const SlotsPage({super.key});

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  bool isCollapsed = false; // State to track sidebar collapse

  // List of options for the slots page
  final List<Map<String, String>> options = [
    {'number': '1', 'title': 'Short Touch'},
    {'number': '2', 'title': 'Long Touch'},
  ];

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode using Provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Define colors based on theme - using darker greys for both themes
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.grey[300]!;
    final gradientColors = isDarkMode
        ? [
            const Color.fromARGB(255, 22, 22, 22)!,
            const Color.fromARGB(255, 37, 37, 37)!,
            Colors.grey[800]!,
          ]
        : [
            Colors.grey[300]!,
            Colors.grey[400]!,
            Colors.grey[500]!,
          ];
    final textColor = isDarkMode ? Colors.grey[100]! : Colors.grey[900]!;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.grey[350]!;
    final cardShadowLight = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.white.withOpacity(0.9);
    final cardShadowDark = isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.2);
    final numberBgColor = isDarkMode ? Colors.grey[600]! : Colors.grey[700]!;
    final optionTextColor = isDarkMode ? Colors.grey[200]! : Colors.grey[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slots'),
      ),
      body: Row(
        children: [
          // Include the sidebar
          Sidebar(
            isCollapsed: isCollapsed,
            onToggle: () {
              setState(() {
                isCollapsed = !isCollapsed;
              });
            },
          ),
          // Content area
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with reduced bottom padding
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Slots',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Options in a row layout
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First option
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildOptionCard(
                                    number: options[0]['number']!,
                                    title: options[0]['title']!,
                                    onTap: () {
                                      print(
                                          'Selected option: ${options[0]['title']}');
                                    },
                                    cardColor: cardColor,
                                    cardShadowLight: cardShadowLight,
                                    cardShadowDark: cardShadowDark,
                                    numberBgColor: numberBgColor,
                                    optionTextColor: optionTextColor,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 24),

                            // Second option
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildOptionCard(
                                    number: options[1]['number']!,
                                    title: options[1]['title']!,
                                    onTap: () {
                                      print(
                                          'Selected option: ${options[1]['title']}');
                                    },
                                    cardColor: cardColor,
                                    cardShadowLight: cardShadowLight,
                                    cardShadowDark: cardShadowDark,
                                    numberBgColor: numberBgColor,
                                    optionTextColor: optionTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String number,
    required String title,
    required VoidCallback onTap,
    required Color cardColor,
    required Color cardShadowLight,
    required Color cardShadowDark,
    required Color numberBgColor,
    required Color optionTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: cardShadowLight,
              offset: const Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: cardShadowDark,
              offset: const Offset(2, 2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            children: [
              // Circular number indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: numberBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Option title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: optionTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
