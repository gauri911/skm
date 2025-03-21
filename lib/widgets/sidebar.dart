import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feitian_authenticator/widgets/settings_dailog.dart';

class Sidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const Sidebar({super.key, required this.isCollapsed, required this.onToggle});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selectedIndex = 3; // Home is selected by default
  final String serialNumber = "12345"; // Serial number to display

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (mounted) {
        setState(() {
          selectedIndex = _getSelectedIndex(currentRoute);
        });
      }
    });
  }

  int _getSelectedIndex(String? route) {
    switch (route) {
      case '/accounts':
        return 6;
      case '/slots':
        return 7;
      case '/help':
        return 9;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isCollapsed
        ? _buildCollapsedSidebar()
        : _buildExpandedSidebar();
  }

  void _navigateToPage(int index, String route) {
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _copySerialNumber() {
    Clipboard.setData(ClipboardData(text: serialNumber)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Serial number copied to clipboard"),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  Widget _buildCollapsedSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - reduced padding
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, size: 22),
              color: Colors.grey[800],
              onPressed: widget.onToggle,
              padding: EdgeInsets.zero,
            ),
          ),

          // Main menu section - now in fixed column instead of scrollable
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 4), // Reduced spacing
                // Connection section
                _buildCollapsedSectionLabel(),
                _buildCollapsedMenuItem(0, Icons.usb, '/usb'),
                _buildCollapsedMenuItem(1, Icons.wifi, '/nfc'),
                _buildCollapsedMenuItem(2, Icons.business, '/business'),

                // Added more spacing between sections in collapsed state
                const SizedBox(height: 12), // Increased spacing
                _buildCollapsedSectionLabel(),

                // Dashboard section
                _buildCollapsedMenuItem(3, Icons.home, '/'),
                _buildCollapsedMenuItem(4, Icons.person, '/accounts'),
                _buildCollapsedMenuItem(7, Icons.grid_4x4, '/slots'),

                // Spacer to push footer to bottom
                const Spacer(),
              ],
            ),
          ),

          // Footer section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Serial number icon
                Tooltip(
                  message: "Serial No.: $serialNumber (Click to copy)",
                  child: InkWell(
                    onTap: _copySerialNumber,
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      child: const Icon(
                        Icons.numbers,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4), // Reduced spacing

                // Settings icon
                Tooltip(
                  message: "Settings",
                  child: InkWell(
                    onTap: _showSettings,
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      child: const Icon(
                        Icons.settings,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4), // Reduced spacing

                // Help icon
                Tooltip(
                  message: "Help",
                  child: InkWell(
                    onTap: () => _navigateToPage(9, '/help'),
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      child: const Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSectionLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 2), // Added vertical padding
      child: Divider(
        color: Colors.grey[400],
        thickness: 1,
      ),
    );
  }

  Widget _buildCollapsedMenuItem(int index, IconData icon, String route) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 1, horizontal: 8), // Reduced vertical margin
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE0E0E0) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _navigateToPage(index, route),
          child: Container(
            padding: const EdgeInsets.all(8), // Reduced padding
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.black : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - reduced padding and font size
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10), // Reduced vertical padding
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "FEITIAN",
                  style: TextStyle(
                    fontSize: 16, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 1.0,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, size: 22), // Reduced icon size
                  color: Colors.grey[800],
                  onPressed: widget.onToggle,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Main menu section - now using Expanded with Column instead of SingleChildScrollView
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6), // Reduced spacing
                // Connection section
                _buildSectionLabel("Menu"),
                const SizedBox(height: 2), // Reduced spacing
                _buildMenuItem(0, Icons.usb, "USB", '/usb'),
                _buildMenuItem(1, Icons.wifi, "NFC", '/nfc'),
                _buildMenuItem(
                    2, Icons.business, "Hello Business", '/business'),

                // Increased spacing between the Menu and Dashboard sections
                const SizedBox(height: 16), // Increased from 6 to 16
                _buildSectionLabel("Dashboard"),
                const SizedBox(height: 2), // Reduced spacing

                // Dashboard section
                _buildMenuItem(3, Icons.home, "Home", '/'),
                _buildMenuItem(4, Icons.person, "Account", '/accounts'),
                _buildMenuItem(7, Icons.grid_4x4, "Slots", '/slots'),

                // Spacer to push items to the top and footer to bottom
                const Spacer(),
              ],
            ),
          ),

          // Footer section - reduced padding
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Serial number row
                InkWell(
                  onTap: _copySerialNumber,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6), // Reduced padding
                    child: Row(
                      children: [
                        const Icon(
                          Icons.numbers,
                          size: 18, // Reduced icon size
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Serial No.: $serialNumber",
                          style: const TextStyle(
                            fontSize: 13, // Reduced font size
                            color: Color(0xFF666666),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.copy,
                          size: 14, // Reduced icon size
                          color: Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6), // Reduced spacing

                // Settings row
                InkWell(
                  onTap: _showSettings,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6), // Reduced padding
                    child: Row(
                      children: [
                        const Icon(
                          Icons.settings,
                          size: 18, // Reduced icon size
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 13, // Reduced font size
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6), // Reduced spacing

                // Help row
                InkWell(
                  onTap: () => _navigateToPage(9, '/help'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6), // Reduced padding
                    child: Row(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          size: 18, // Reduced icon size
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Help",
                          style: TextStyle(
                            fontSize: 13, // Reduced font size
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 2), // Added vertical padding
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6), // Reduced padding
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13, // Reduced font size
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, String route) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 1), // Reduced vertical margin
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE0E0E0) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _navigateToPage(index, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8), // Reduced vertical padding
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18, // Reduced icon size
                  color: isSelected ? Colors.black : const Color(0xFF666666),
                ),
                const SizedBox(width: 14), // Reduced spacing
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13, // Reduced font size
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected ? Colors.black : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
