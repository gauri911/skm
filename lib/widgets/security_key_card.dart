import 'package:flutter/material.dart';
import '../models/security_key.dart';

class SecurityKeyCard extends StatelessWidget {
  final SecurityKey securityKey;
  final VoidCallback? onCopySerial;
  final VoidCallback? onCopyFirmware;

  const SecurityKeyCard({
    super.key,
    required this.securityKey,
    this.onCopySerial,
    this.onCopyFirmware,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              securityKey.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Serial Number:',
              securityKey.serialNumber,
              onCopySerial,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              context,
              'Firmware Version:',
              securityKey.firmwareVersion,
              onCopyFirmware,
            ),
            const SizedBox(height: 8),
            _buildConnectionStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    VoidCallback? onCopy,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: securityKey.isConnected ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          securityKey.isConnected ? 'Connected' : 'Disconnected',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: securityKey.isConnected ? Colors.green : Colors.red,
              ),
        ),
      ],
    );
  }
} 