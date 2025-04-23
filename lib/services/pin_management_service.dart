import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart'; // Added import for Utf8 type
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_communication/usb_fido.dart';
import '../models/feitian_security_key.dart';

// FFI signatures for native methods
typedef SetInitialPinNative = Int32 Function(Pointer<Utf8> newPin);
typedef SetInitialPinDart = int Function(Pointer<Utf8> newPin);

typedef ChangePinNative =
    Int32 Function(Pointer<Utf8> oldPin, Pointer<Utf8> newPin);
typedef ChangePinDart =
    int Function(Pointer<Utf8> oldPin, Pointer<Utf8> newPin);

typedef VerifyPinNative = Int32 Function(Pointer<Utf8> pin);
typedef VerifyPinDart = int Function(Pointer<Utf8> pin);

class PinManagementService {
  static const String PIN_SET_KEY = 'security_key_pin_set';
  final UsbFido _usbFido = UsbFido();

  // Check if PIN has been set on the USB security key
  Future<bool> isPinSet() async {
    try {
      // First check if we have a record of PIN being set
      final prefs = await SharedPreferences.getInstance();
      final isPinSetValue = prefs.getBool(PIN_SET_KEY);

      if (isPinSetValue == true) {
        return true;
      }

      // If we don't have a local record, we could also try to verify default PIN
      // If default PIN fails, it might mean a PIN has been set

      return false;
    } catch (e) {
      print('Error checking PIN status: $e');
      return false;
    }
  }

  // Set an initial PIN on the USB security key
  Future<bool> setInitialPin(String newPin) async {
    try {
      // Validate the PIN first
      if (!_isValidPin(newPin)) {
        print('Invalid PIN format');
        return false;
      }

      // Find the connected USB device
      final devicePath = _findConnectedDevice();
      if (devicePath == null) {
        print('No USB security key found');
        return false;
      }

      // Call the native method to set the initial PIN
      // In a real implementation this would be properly connected to the native code
      bool success = await _nativeSetInitialPin(newPin);

      if (success) {
        // Store PIN status locally only if the operation was successful
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(PIN_SET_KEY, true);
        return true;
      }

      return false;
    } catch (e) {
      print('Error setting initial PIN: $e');
      return false;
    }
  }

  // Change an existing PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      // Validate the PINs
      if (!_isValidPin(oldPin) || !_isValidPin(newPin)) {
        print('Invalid PIN format');
        return false;
      }

      // Find the connected USB device
      final devicePath = _findConnectedDevice();
      if (devicePath == null) {
        print('No USB security key found');
        return false;
      }

      // Call the native method to change the PIN
      bool success = await _nativeChangePin(oldPin, newPin);

      return success;
    } catch (e) {
      print('Error changing PIN: $e');
      return false;
    }
  }

  // Validate a PIN against the USB key
  Future<bool> validatePin(String pin) async {
    try {
      if (!_isValidPin(pin)) {
        print('Invalid PIN format');
        return false;
      }

      // Find the connected USB device
      final devicePath = _findConnectedDevice();
      if (devicePath == null) {
        print('No USB security key found');
        return false;
      }

      // Call the native method to verify the PIN
      bool success = await _nativeVerifyPin(pin);

      return success;
    } catch (e) {
      print('Error validating PIN: $e');
      return false;
    }
  }

  // Validate PIN format
  bool _isValidPin(String pin) {
    // PIN must be numeric and between MIN_PIN_LENGTH and MAX_PIN_LENGTH digits
    final RegExp numericRegex = RegExp(r'^\d+$');
    return pin.length >= 6 && pin.length <= 8 && numericRegex.hasMatch(pin);
  }

  // Find connected security key
  String? _findConnectedDevice() {
    for (final securityKey in feitianSecurityKeys) {
      final path = _usbFido.findUsbDevice(securityKey.vid, securityKey.pid);
      if (path != null) {
        return path;
      }
    }
    return null;
  }

  // These methods would be implemented to call the actual native functions
  // For now, we're simulating success but these should call FFI functions

  Future<bool> _nativeSetInitialPin(String newPin) async {
    // Simulate communication delay
    await Future.delayed(Duration(milliseconds: 500));

    // In a real implementation, this would call the native function
    // Example of calling native function (not implemented here):
    // final result = _nativeLib.setInitialPin(newPin.toNativeUtf8());
    // return result == 0; // 0 usually means success in C

    // For testing purposes, always return success
    // TODO: Replace with actual native call
    return true;
  }

  Future<bool> _nativeChangePin(String oldPin, String newPin) async {
    // Simulate communication delay
    await Future.delayed(Duration(milliseconds: 500));

    // In a real implementation, would call native function:
    // final result = _nativeLib.changePin(oldPin.toNativeUtf8(), newPin.toNativeUtf8());
    // return result == 0;

    // TODO: Replace with actual native call
    return true;
  }

  Future<bool> _nativeVerifyPin(String pin) async {
    // Simulate communication delay
    await Future.delayed(Duration(milliseconds: 300));

    // In a real implementation:
    // final result = _nativeLib.verifyPin(pin.toNativeUtf8());
    // return result > 0; // Positive result often indicates remaining tries

    // TODO: Replace with actual native call
    return true;
  }
}
