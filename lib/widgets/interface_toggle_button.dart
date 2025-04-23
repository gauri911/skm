import 'package:flutter/material.dart';

class InterfaceToggleButton extends StatelessWidget {
  final String interface;
  final bool isEnabled;
  final VoidCallback onToggle;
  final bool isLoading;

  const InterfaceToggleButton({
    super.key,
    required this.interface,
    required this.isEnabled,
    required this.onToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isLoading ? null : onToggle,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interface,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnabled ? 'Enabled' : 'Disabled',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isEnabled ? Colors.green : Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Switch(
                  value: isEnabled,
                  onChanged: (_) => onToggle(),
                  activeColor: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 