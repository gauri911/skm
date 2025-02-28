// // import 'package:flutter/material.dart'
// //     show
// //         Alignment,
// //         AnimatedContainer,
// //         Border,
// //         BorderRadius,
// //         BoxDecoration,
// //         BoxShadow,
// //         BuildContext,
// //         Color,
// //         Colors,
// //         Column,
// //         Container,
// //         CrossAxisAlignment,
// //         Curves,
// //         Divider,
// //         Drawer,
// //         EdgeInsets,
// //         Expanded,
// //         FontStyle,
// //         FontWeight,
// //         GestureDetector,
// //         Icon,
// //         IconData,
// //         Icons,
// //         LinearGradient,
// //         Matrix4,
// //         MouseRegion,
// //         Navigator,
// //         Offset,
// //         Padding,
// //         Row,
// //         SizedBox,
// //         Spacer,
// //         State,
// //         StatefulWidget,
// //         Text,
// //         TextStyle,
// //         Widget;

// // class Sidebar extends StatefulWidget {
// //   const Sidebar({super.key});

// //   @override
// //   State<Sidebar> createState() => _SidebarState();
// // }

// // //
// // class _SidebarState extends State<Sidebar> {
// //   int? hoveredIndex;
// //   int selectedIndex = -1; // Home is selected by default

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             const Color(0xFFF0F0F0),
// //             const Color(0xFFE5E5E5),
// //             const Color(0xFFDDDDDD),
// //           ],
// //           stops: const [0.0, 0.6, 1.0],
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.15),
// //             blurRadius: 8,
// //             offset: const Offset(2, 0),
// //           ),
// //         ],
// //       ),
// //       child: Drawer(
// //         width: 250,
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Padding(
// //                 padding:
// //                     const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 16.0),
// //                 child: Text(
// //                   'FEITIAN',
// //                   style: const TextStyle(
// //                     fontSize: 30,
// //                     fontWeight: FontWeight.bold,
// //                     fontStyle: FontStyle.italic,
// //                     color: Color(0xFF333333),
// //                   ),
// //                 ),
// //               ),
// //               _buildSectionLabel('Menu'),
// //               _buildMenuItem(0, Icons.usb, 'USB'),
// //               _buildMenuItem(1, Icons.wifi, 'NFC'),
// //               _buildMenuItem(2, Icons.business, 'Hello Business'),
// //               const SizedBox(height: 16),
// //               _buildSectionLabel('Dashboard'),
// //               _buildMenuItem(3, Icons.home, 'Home'),
// //               _buildMenuItem(4, Icons.person, 'Account'),
// //               _buildMenuItem(5, Icons.key, 'Credentials'),
// //               _buildMenuItem(6, Icons.description, 'Certificates'),
// //               _buildMenuItem(7, Icons.grid_4x4, 'Slots'),
// //               const Spacer(flex: 6),
// //               _buildSimpleMenuItem(Icons.tag, 'Serial No.: 123456789'),
// //               _buildSimpleMenuItem(Icons.settings, 'Settings'),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSectionLabel(String label) {
// //     return Column(
// //       children: [
// //         Row(
// //           children: [
// //             Expanded(
// //               child: Divider(color: Colors.grey[500], thickness: 1),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
// //               child: Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w500,
// //                   color: Colors.grey[600],
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               child: Divider(color: Colors.grey[500], thickness: 1),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 8),
// //       ],
// //     );
// //   }

// //   Widget _buildMenuItem(int index, IconData icon, String title,
// //       {bool isSelected = false}) {
// //     final bool isHovered = hoveredIndex == index;
// //     final bool isActive = selectedIndex == index || isSelected;

// //     return MouseRegion(
// //       onEnter: (_) => setState(() => hoveredIndex = index),
// //       onExit: (_) => setState(() => hoveredIndex = null),
// //       child: GestureDetector(
// //         onTap: () {
// //           setState(() {
// //             selectedIndex = index;
// //           });
// //           Navigator.pop(context);
// //         },
// //         child: AnimatedContainer(
// //           duration: const Duration(milliseconds: 200),
// //           curve: Curves.easeInOut,
// //           margin: const EdgeInsets.only(bottom: 6.0),
// //           decoration: BoxDecoration(
// //             color: isActive
// //                 ? const Color(0xFFA0A0A0)
// //                 : (isHovered
// //                     ? const Color(0xFFB0B0B0)
// //                     : const Color(0xFFF5F5F5)),
// //             borderRadius: BorderRadius.circular(4),
// //             border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
// //             boxShadow: isActive || isHovered
// //                 ? [
// //                     BoxShadow(
// //                         color: Colors.black.withOpacity(0.15),
// //                         offset: const Offset(2, 2),
// //                         blurRadius: 3),
// //                     BoxShadow(
// //                         color: Colors.white.withOpacity(0.9),
// //                         offset: const Offset(-1, -1),
// //                         blurRadius: 3),
// //                   ]
// //                 : [],
// //           ),
// //           transform: isHovered || isActive
// //               ? Matrix4.translationValues(-2.0, -2.0, 0.0)
// //               : Matrix4.identity(),
// //           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
// //           child: Row(
// //             children: [
// //               Icon(icon,
// //                   size: 18, color: isActive ? Colors.white : Colors.grey[600]),
// //               const SizedBox(width: 12),
// //               Text(
// //                 title,
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
// //                   color: isActive ? Colors.white : Colors.grey[700],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSimpleMenuItem(IconData icon, String title) {
// //     return Padding(
// //       padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
// //       child: Row(
// //         children: [
// //           Icon(icon, size: 16, color: Colors.grey[600]),
// //           const SizedBox(width: 12),
// //           Text(
// //             title,
// //             style: TextStyle(
// //                 fontSize: 12,
// //                 fontWeight: FontWeight.w400,
// //                 color: Colors.grey[700]),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// class Sidebar extends StatefulWidget {
//   final bool isCollapsed;

//   const Sidebar({Key? key, required this.isCollapsed}) : super(key: key);

//   @override
//   _SidebarState createState() => _SidebarState();
// }

// class _SidebarState extends State<Sidebar> {
//   late bool isCollapsed;
//   int? hoveredIndex;
//   int selectedIndex = -1;

//   @override
//   void initState() {
//     super.initState();
//     isCollapsed = widget.isCollapsed; // Initialize from widget
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: isCollapsed ? 60 : 250,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFFF0F0F0),
//             Color(0xFFE5E5E5),
//             Color(0xFFDDDDDD),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 8,
//             offset: const Offset(2, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           IconButton(
//             icon: Icon(isCollapsed ? Icons.menu : Icons.close),
//             onPressed: () {
//               setState(() {
//                 isCollapsed = !isCollapsed;
//               });
//             },
//           ),
//           _buildMenuItem(0, Icons.usb, 'USB'),
//           _buildMenuItem(1, Icons.wifi, 'NFC'),
//           _buildMenuItem(2, Icons.business, 'Hello Business'),
//           _buildMenuItem(3, Icons.home, 'Home'),
//           _buildMenuItem(4, Icons.person, 'Account'),
//           _buildMenuItem(5, Icons.key, 'Credentials'),
//           _buildMenuItem(6, Icons.description, 'Certificates'),
//           _buildMenuItem(7, Icons.grid_4x4, 'Slots'),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuItem(int index, IconData icon, String title) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => hoveredIndex = index),
//       onExit: (_) => setState(() => hoveredIndex = null),
//       child: GestureDetector(
//         onTap: () => setState(() => selectedIndex = index),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
//           decoration: BoxDecoration(
//             color:
//                 selectedIndex == index ? Colors.grey[400] : Colors.transparent,
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: Colors.black),
//               if (!isCollapsed) ...[
//                 const SizedBox(width: 12),
//                 Text(title, style: const TextStyle(color: Colors.black)),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isCollapsed ? 60 : 250, // Increased width to 250
      color: const Color(0xFFE5E5E5), // Light gray background
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
                Flexible(
                  child: Text(
                    widget.isCollapsed ? "F" : "FEITIAN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.isCollapsed ? Icons.menu : Icons.menu_open,
                    color: Colors.grey[800],
                  ),
                  onPressed: widget.onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildSectionHeader("Menu", false),
          const SizedBox(height: 6),

          // Wrap the menu items in an Expanded to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(0, Icons.usb, "USB"),
                  _buildMenuItem(1, Icons.wifi, "NFC"),
                  _buildMenuItem(2, Icons.business, "Hello Business"),
                  const SizedBox(height: 8),
                  _buildSectionHeader("Dashboard", false),
                  const SizedBox(height: 6),
                  _buildMenuItem(3, Icons.home, "Home"),
                  _buildMenuItem(4, Icons.person, "Account"),
                  _buildMenuItem(5, Icons.key, "Credentials"),
                  _buildMenuItem(6, Icons.description, "Certificates"),
                  _buildMenuItem(7, Icons.grid_4x4, "Slots"),
                  const SizedBox(height: 8),
                  _buildMenuItem(8, Icons.settings, "Settings"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool showDivider) {
    if (widget.isCollapsed) {
      return Divider(color: Colors.grey[400], thickness: 1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDivider) Divider(color: Colors.grey[400], thickness: 1),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (showDivider) Divider(color: Colors.grey[400], thickness: 1),
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
              setState(() {
                selectedIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: Colors.grey[600]),
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
