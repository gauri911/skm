import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool isCollapsed = false; // State to track sidebar collapse

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: constraints.maxHeight < 600
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
                              'Accounts',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Get Started Card
                          _buildGetStartedCard(),
                          const SizedBox(height: 24),

                          // Action Buttons in a Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                    'Create Account', Icons.add),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                    'Edit Account', Icons.edit_outlined),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                    'View All', Icons.visibility_outlined),
                              ),
                            ],
                          ),
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

  Widget _buildGetStartedCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-3, -3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade300, width: 1.5),
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
                  'Get Started with your accounts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Add accounts to your Security key supporting OATH / PIV / FIDO2',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      height: 48, // Fixed height for all buttons
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-2, -2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
          onTap: () {
            // Action when button is tapped
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.grey[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
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
}
