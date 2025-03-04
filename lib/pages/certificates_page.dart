import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({Key? key}) : super(key: key);

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  bool isCollapsed = false; // State to track sidebar collapse

  // List of options for the dashboard
  final List<Map<String, String>> options = [
    {'number': '1', 'title': 'Authentication'},
    {'number': '2', 'title': 'Digital Signature'},
    {'number': '3', 'title': 'Key Management'},
    {'number': '4', 'title': 'Card Authentication'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[350]!,
                    Colors.grey[400]!,
                  ],
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
                      padding: const EdgeInsets.only(
                          bottom: 8.0), // Reduced from 24.0 to 8.0
                      child: Text(
                        'Certificates',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Options in a grid layout
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0), // Added small top padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First column (options 1 and 2)
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
                                  ),
                                  const SizedBox(height: 16),
                                  _buildOptionCard(
                                    number: options[1]['number']!,
                                    title: options[1]['title']!,
                                    onTap: () {
                                      print(
                                          'Selected option: ${options[1]['title']}');
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 24),

                            // Second column (options 3 and 4)
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildOptionCard(
                                    number: options[2]['number']!,
                                    title: options[2]['title']!,
                                    onTap: () {
                                      print(
                                          'Selected option: ${options[2]['title']}');
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildOptionCard(
                                    number: options[3]['number']!,
                                    title: options[3]['title']!,
                                    onTap: () {
                                      print(
                                          'Selected option: ${options[3]['title']}');
                                    },
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                  color: Colors.grey[600],
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
                    color: Colors.grey[700],
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
