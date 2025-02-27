import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        title: Text('Home',
            style: TextStyle(
                fontSize: 22,
                color: Colors.black54,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[200],
        iconTheme: IconThemeData(color: Colors.black54),
        elevation: 0,
      ),
      body: Container(
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Card
              _buildEmbossedCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FEITIAN iePass K44 USB Security Key',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.black45,
                      size: 20,
                    ),
                  ],
                ),
                bottomBorder: true,
              ),
              SizedBox(height: 12),

              // Row 1: Serial Number and Version Number
              Row(
                children: [
                  Expanded(
                    child: _buildEmbossedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Serial No',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.content_copy_outlined,
                                color: Colors.black45,
                                size: 18,
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '123456789',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildEmbossedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Version No',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.content_copy_outlined,
                                color: Colors.black45,
                                size: 18,
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'v1.0.3',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Row 2: Support Functions and Categories
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
                          ),
                          SizedBox(height: 8),
                          Text(
                            'U2F',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'FIDO2',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
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

              Spacer(),
              // USB Security Key Image
              Center(
                child: Image.asset(
                  'assets/usb_security_key.png',
                  height: 70,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          // Enhanced white inner shadow on top and left (creating stronger highlight)
          BoxShadow(
            color: Colors.white.withOpacity(1.0),
            offset: Offset(-2, -2),
            blurRadius: 3,
            spreadRadius: 0.5,
          ),
          // Enhanced dark shadow on bottom and right
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(3, 3),
            blurRadius: 4,
            spreadRadius: 0.5,
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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          // Enhanced inner shadow for embossed effect
          BoxShadow(
            color: Colors.white.withOpacity(1.0),
            offset: Offset(-1.5, -1.5),
            blurRadius: 2,
            spreadRadius: 0.3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1.5, 1.5),
            blurRadius: 2,
            spreadRadius: 0.3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }
}
