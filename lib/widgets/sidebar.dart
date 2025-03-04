import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const Sidebar({super.key, required this.isCollapsed, required this.onToggle});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selectedIndex = 3; // Home is selected by default

  @override
  void initState() {
    super.initState();
    // Check the current route to set the correct initial selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == '/accounts') {
        setState(() {
          selectedIndex = 4; // Account
        });
      } else if (currentRoute == '/credentials') {
        setState(() {
          selectedIndex = 5; // Credentials
        });
      } else if (currentRoute == '/certificates') {
        setState(() {
          selectedIndex = 6; // Certificates
        });
      } else if (currentRoute == '/slots') {
        setState(() {
          selectedIndex = 7; // Slots
        });
      } else if (currentRoute == '/') {
        setState(() {
          selectedIndex = 3; // Home
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use completely different layouts for collapsed and expanded states
    if (widget.isCollapsed) {
      return _buildCollapsedSidebar();
    } else {
      return _buildExpandedSidebar();
    }
  }

  // Navigation helper method
  void _navigateToPage(int index) {
    // Handle navigation based on selected index
    switch (index) {
      case 3: // Home
        if (selectedIndex != index) {
          Navigator.pushReplacementNamed(context, '/');
        }
        break;
      case 4: // Account
        if (selectedIndex != index) {
          Navigator.pushReplacementNamed(context, '/accounts');
        }
        break;
      case 5: // Credentials
        if (selectedIndex != index) {
          Navigator.pushReplacementNamed(context, '/credentials');
        }
        break;
      case 6: // Certificates
        if (selectedIndex != index) {
          Navigator.pushReplacementNamed(context, '/certificates');
        }
        break;
      case 7: // Slots
        if (selectedIndex != index) {
          Navigator.pushReplacementNamed(context, '/slots');
        }
        break;
      // Add more cases for other pages as needed
    }

    // Update the selected index after navigation
    setState(() {
      selectedIndex = index;
    });
  }

  // Completely separate implementation for collapsed sidebar
  Widget _buildCollapsedSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      color: const Color(0xFFE5E5E5),
      child: Column(
        children: [
          // Header - just the menu icon
          SizedBox(height: 16),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.grey[800]),
            onPressed: widget.onToggle,
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 8),
          Divider(color: Colors.grey[400], thickness: 1),
          SizedBox(height: 8),

          // Menu items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCollapsedMenuItem(0, Icons.usb),
                  _buildCollapsedMenuItem(1, Icons.wifi),
                  _buildCollapsedMenuItem(2, Icons.business),
                  SizedBox(height: 8),
                  Divider(color: Colors.grey[400], thickness: 1),
                  SizedBox(height: 8),
                  _buildCollapsedMenuItem(3, Icons.home),
                  _buildCollapsedMenuItem(4, Icons.person),
                  _buildCollapsedMenuItem(5, Icons.key),
                  _buildCollapsedMenuItem(6, Icons.description),
                  _buildCollapsedMenuItem(7, Icons.grid_4x4),
                ],
              ),
            ),
          ),

          // Bottom section
          Divider(color: Colors.grey[400], thickness: 1),
          SizedBox(height: 8),
          Icon(Icons.numbers, size: 20, color: Colors.grey[700]),
          SizedBox(height: 16),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 20,
              color: selectedIndex == 8 ? Colors.black : Colors.grey[700],
            ),
            onPressed: () {
              setState(() {
                selectedIndex = 8;
              });
            },
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  // Collapsed menu item - just an icon
  Widget _buildCollapsedMenuItem(int index, IconData icon) {
    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD0D0D0) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: IconButton(
          icon: Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
          onPressed: () {
            _navigateToPage(index);
          },
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // Original expanded sidebar implementation
  Widget _buildExpandedSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 250,
      color: const Color(0xFFE5E5E5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Header with toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "FEITIAN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    icon: Icon(
                      Icons.menu_open,
                      color: Colors.grey[800],
                      size: 20,
                    ),
                    onPressed: widget.onToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildDivider("Menu"),
          const SizedBox(height: 6),

          // Main menu items in a scrollable area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(0, Icons.usb, "USB"),
                  _buildMenuItem(1, Icons.wifi, "NFC"),
                  _buildMenuItem(2, Icons.business, "Hello Business"),
                  const SizedBox(height: 8),
                  _buildDivider("Dashboard"),
                  const SizedBox(height: 6),
                  _buildMenuItem(3, Icons.home, "Home"),
                  _buildMenuItem(4, Icons.person, "Account"),
                  _buildMenuItem(5, Icons.key, "Credentials"),
                  _buildMenuItem(6, Icons.description, "Certificates"),
                  _buildMenuItem(7, Icons.grid_4x4, "Slots"),
                ],
              ),
            ),
          ),

          // Bottom section divider
          Divider(color: Colors.grey[400], thickness: 1),

          // Serial number display above settings
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.numbers, size: 18, color: Colors.grey[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Serial No.: 12345",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Add copy functionality here
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.content_copy_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Settings at the bottom
          InkWell(
            onTap: () {
              setState(() {
                selectedIndex = 8;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    size: 18,
                    color: selectedIndex == 8 ? Colors.black : Colors.grey[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedIndex == 8
                            ? Colors.black
                            : Colors.grey[800],
                        fontWeight: selectedIndex == 8
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDivider(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.grey[400], thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: Colors.grey[400], thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD0D0D0) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              _navigateToPage(index);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.black : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.black : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
