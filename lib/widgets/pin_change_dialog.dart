import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class PINChangeDialog extends StatefulWidget {
  final Function(String oldPin, String newPin) onConfirm;
  final bool isLoading;

  const PINChangeDialog({
    Key? key,
    required this.onConfirm,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PINChangeDialog> createState() => _PINChangeDialogState();
}

class _PINChangeDialogState extends State<PINChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _useDefault = false;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change PIN',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildPINField(
                controller: _oldPinController,
                label: 'Old PIN',
                enabled: !_useDefault,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _useDefault,
                    onChanged: (value) {
                      setState(() {
                        _useDefault = value ?? false;
                      });
                    },
                  ),
                  const Text('Use Default PIN'),
                ],
              ),
              const SizedBox(height: 16),
              _buildPINField(
                controller: _newPinController,
                label: 'New PIN',
              ),
              const SizedBox(height: 16),
              _buildPINField(
                controller: _confirmPinController,
                label: 'Confirm PIN',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: widget.isLoading ? null : _handleSubmit,
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Change PIN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPINField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a PIN';
        }
        if (value.length < 4) {
          return 'PIN must be at least 4 characters';
        }
        return null;
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_newPinController.text != _confirmPinController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PINs do not match'),
          ),
        );
        return;
      }

      widget.onConfirm(
        _useDefault ? '123456' : _oldPinController.text,
        _newPinController.text,
      );
    }
  }
} 