// import 'package:flutter/material.dart';
// import '../widgets/settings_dialog.dart';

// class Sidebar extends StatefulWidget {
//   final bool isCollapsed;
//   final VoidCallback onToggle;

//   const Sidebar({super.key, required this.isCollapsed, required this.onToggle});

//   @override
//   _SidebarState createState() => _SidebarState();
// }

// class _SidebarState extends State<Sidebar> {
//   int selectedIndex = 3; // Home is selected by default

//   @override
//   void initState() {
//     super.initState();
//     // Check the current route to set the correct initial selection
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final currentRoute = ModalRoute.of(context)?.settings.name;
//       if (currentRoute == '/accounts') {
//         setState(() {
//           selectedIndex = 4; // Account
//         });
//       } else if (currentRoute == '/credentials') {
//         setState(() {
//           selectedIndex = 5; // Credentials
//         });
//       } else if (currentRoute == '/certificates') {
//         setState(() {
//           selectedIndex = 6; // Certificates
//         });
//       } else if (currentRoute == '/slots') {
//         setState(() {
//           selectedIndex = 7; // Slots
//         });
//       } else if (currentRoute == '/') {
//         setState(() {
//           selectedIndex = 3; // Home
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use completely different layouts for collapsed and expanded states
//     if (widget.isCollapsed) {
//       return _buildCollapsedSidebar();
//     } else {
//       return _buildExpandedSidebar();
//     }
//   }

//   // Navigation helper method
//   void _navigateToPage(int index) {
//     // Handle navigation based on selected index
//     switch (index) {
//       case 3: // Home
//         if (selectedIndex != index) {
//           Navigator.pushReplacementNamed(context, '/');
//         }
//         break;
//       case 4: // Account
//         if (selectedIndex != index) {
//           Navigator.pushReplacementNamed(context, '/accounts');
//         }
//         break;
//       case 5: // Credentials
//         if (selectedIndex != index) {
//           Navigator.pushReplacementNamed(context, '/credentials');
//         }
//         break;
//       case 6: // Certificates
//         if (selectedIndex != index) {
//           Navigator.pushReplacementNamed(context, '/certificates');
//         }
//         break;
//       case 7: // Slots
//         if (selectedIndex != index) {
//           Navigator.pushReplacementNamed(context, '/slots');
//         }
//         break;
//       // Add more cases for other pages as needed
//     }

//     // Update the selected index after navigation
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   // Completely separate implementation for collapsed sidebar
//   Widget _buildCollapsedSidebar() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 60,
//       color: const Color(0xFFE5E5E5),
//       child: Column(
//         children: [
//           // Header - just the menu icon
//           const SizedBox(height: 16),
//           IconButton(
//             icon: Icon(
//               Icons.menu,
//               color: Colors.grey[800],
//             ),
//             onPressed: widget.onToggle,
//             padding: EdgeInsets.zero,
//           ),
//           const SizedBox(height: 8),
//           Divider(color: Colors.grey[400], thickness: 1),
//           const SizedBox(height: 8),

//           // Menu items
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildCollapsedMenuItem(0, Icons.usb),
//                   _buildCollapsedMenuItem(1, Icons.wifi),
//                   _buildCollapsedMenuItem(2, Icons.business),
//                   const SizedBox(height: 8),
//                   Divider(color: Colors.grey[400], thickness: 1),
//                   const SizedBox(height: 8),
//                   _buildCollapsedMenuItem(3, Icons.home),
//                   _buildCollapsedMenuItem(4, Icons.person),
//                   _buildCollapsedMenuItem(5, Icons.key),
//                   _buildCollapsedMenuItem(6, Icons.description),
//                   _buildCollapsedMenuItem(7, Icons.grid_4x4),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom section
//           Divider(color: Colors.grey[400], thickness: 1),
//           const SizedBox(height: 8),
//           Icon(Icons.numbers, size: 20, color: Colors.grey[700]),
//           const SizedBox(height: 16),
//           IconButton(
//             icon: Icon(
//               Icons.settings,
//               size: 20,
//               color: selectedIndex == 8 ? Colors.black : Colors.grey[700],
//             ),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => const SettingsDialog(),
//               );
//             },
//             padding: EdgeInsets.zero,
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   // Collapsed menu item - just an icon
//   Widget _buildCollapsedMenuItem(int index, IconData icon) {
//     bool isSelected = selectedIndex == index;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFD0D0D0) : const Color(0xFFF0F0F0),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 2,
//                     offset: const Offset(0, 1),
//                   )
//                 ]
//               : null,
//         ),
//         child: IconButton(
//           icon: Icon(
//             icon,
//             size: 16,
//             color: isSelected ? Colors.black : Colors.grey[600],
//           ),
//           onPressed: () {
//             _navigateToPage(index);
//           },
//           padding: EdgeInsets.zero,
//         ),
//       ),
//     );
//   }

//   // Original expanded sidebar implementation
//   Widget _buildExpandedSidebar() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 250,
//       color: const Color(0xFFE5E5E5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 8),
//           // Header with toggle button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     "FEITIAN",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                       letterSpacing: 1.0,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.menu_open,
//                       color: Colors.grey[800],
//                       size: 20,
//                     ),
//                     onPressed: widget.onToggle,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 4),
//           _buildDivider("Menu"),
//           const SizedBox(height: 6),

//           // Main menu items in a scrollable area
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildMenuItem(0, Icons.usb, "USB"),
//                   _buildMenuItem(1, Icons.wifi, "NFC"),
//                   _buildMenuItem(2, Icons.business, "Hello Business"),
//                   const SizedBox(height: 8),
//                   _buildDivider("Dashboard"),
//                   const SizedBox(height: 6),
//                   _buildMenuItem(3, Icons.home, "Home"),
//                   _buildMenuItem(4, Icons.person, "Account"),
//                   _buildMenuItem(5, Icons.key, "Credentials"),
//                   _buildMenuItem(6, Icons.description, "Certificates"),
//                   _buildMenuItem(7, Icons.grid_4x4, "Slots"),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom section divider
//           Divider(color: Colors.grey[400], thickness: 1),

//           // Serial number display above settings
//           Padding(
//             padding: const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 8),
//             child: Row(
//               children: [
//                 Icon(Icons.numbers, size: 18, color: Colors.grey[700]),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     "Serial No.: 12345",
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => const SettingsDialog(),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Icon(
//                       Icons.settings,
//                       size: 18,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildDivider(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Divider(color: Colors.grey[400], thickness: 1),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Divider(color: Colors.grey[400], thickness: 1),
//           ),
//         ],
//       ),
//     );
//   }

//   class Sidebar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text(
//               'Dashboard',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.settings),
//             title: Text('Settings'),
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => SettingsDialog(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

//   Widget _buildMenuItem(int index, IconData icon, String title) {
//     bool isSelected = selectedIndex == index;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFD0D0D0) : const Color(0xFFF0F0F0),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 2,
//                     offset: const Offset(0, 1),
//                   )
//                 ]
//               : null,
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(8),
//             onTap: () {
//               _navigateToPage(index);
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//               child: Row(
//                 children: [
//                   Icon(
//                     icon,
//                     size: 16,
//                     color: isSelected ? Colors.black : Colors.grey[600],
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: isSelected ? Colors.black : Colors.grey[700],
//                         fontWeight:
//                             isSelected ? FontWeight.w500 : FontWeight.normal,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
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
        return 4;
      case '/credentials':
        return 5;
      case '/certificates':
        return 6;
      case '/slots':
        return 7;
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

  Widget _buildCollapsedSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
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
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.grey[800]),
            onPressed: widget.onToggle,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[400], thickness: 1),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCollapsedMenuItem(0, Icons.usb, '/usb'),
                  _buildCollapsedMenuItem(1, Icons.wifi, '/nfc'),
                  _buildCollapsedMenuItem(2, Icons.business, '/business'),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[400], thickness: 1),
                  const SizedBox(height: 8),
                  _buildCollapsedMenuItem(3, Icons.home, '/'),
                  _buildCollapsedMenuItem(4, Icons.person, '/accounts'),
                  _buildCollapsedMenuItem(5, Icons.key, '/credentials'),
                  _buildCollapsedMenuItem(
                      6, Icons.description, '/certificates'),
                  _buildCollapsedMenuItem(7, Icons.grid_4x4, '/slots'),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey[400], thickness: 1),
          const SizedBox(height: 8),
          _buildCollapsedMenuItem(8, Icons.settings, '/settings'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCollapsedMenuItem(int index, IconData icon, String route) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCCCCCC) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (index == 8) {
                showDialog(
                  context: context,
                  builder: (context) => const SettingsDialog(),
                );
              } else {
                _navigateToPage(index, route);
              }
            },
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.black : Colors.grey[600],
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
        color: const Color(0xFFF0F0F0),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "FEITIAN",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 1.0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.grey[800]),
                  onPressed: widget.onToggle,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCenteredDividerWithLabel("Menu"),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuItem(0, Icons.usb, "USB", '/usb'),
                  _buildMenuItem(1, Icons.wifi, "NFC", '/nfc'),
                  _buildMenuItem(
                      2, Icons.business, "Hello Business", '/business'),
                  const SizedBox(height: 20),
                  _buildCenteredDividerWithLabel("Dashboard"),
                  const SizedBox(height: 12),
                  _buildMenuItem(3, Icons.home, "Home", '/'),
                  _buildMenuItem(4, Icons.person, "Account", '/accounts'),
                  _buildMenuItem(5, Icons.key, "Credentials", '/credentials'),
                  _buildMenuItem(
                      6, Icons.description, "Certificates", '/certificates'),
                  _buildMenuItem(7, Icons.grid_4x4, "Slots", '/slots'),
                  const SizedBox(height: 16),
                  _buildMenuItem(8, Icons.settings, "Settings", '/settings'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredDividerWithLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCCCCCC) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (index == 8) {
                showDialog(
                  context: context,
                  builder: (context) => const SettingsDialog(),
                );
              } else {
                _navigateToPage(index, route);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.black : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey[700],
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
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
