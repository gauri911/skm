import 'package:flutter/foundation.dart';
import 'package:usb_communication/src/usb_fido.dart';

class PivProvider extends ChangeNotifier {
  UsbFido? _usbFido;
  int _remainingPinTries = -1;
  bool _isPinBlocked = false;

  int get remainingPinTries => _remainingPinTries;
  bool get isPinBlocked => _isPinBlocked;

  // Error codes from C++ layer
  static const int ERR_PIN_TOO_SHORT = -1;
  static const int ERR_PIN_TOO_LONG = -2;
  static const int ERR_PIN_INVALID = -3;
  static const int ERR_PIN_BLOCKED = -4;
  static const int ERR_COMMUNICATION = -5;

  // PIN constraints
  static const int MIN_PIN_LENGTH = 4;
  static const int MAX_PIN_LENGTH = 8;
  static const int MAX_PIN_TRIES = 3;

  // Initialize UsbFido safely
  Future<UsbFido> _getUsbFido() async {
    if (_usbFido == null) {
      try {
        _usbFido = UsbFido();
      } catch (e) {
        print('Error initializing UsbFido: $e');
        throw Exception('Failed to initialize USB device: $e');
      }
    }
    return _usbFido!;
  }

  Future<bool> verifyPin(String pin) async {
    try {
      if (!_validatePinFormat(pin)) {
        return false;
      }
      final usbFido = await _getUsbFido();
      final result = await usbFido.verifyUserPin(pin);
      _updatePinStatus(result);
      return result >= 0;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      if (!_validatePinFormat(oldPin) || !_validatePinFormat(newPin)) {
        return false;
      }
      final usbFido = await _getUsbFido();
      final result = await usbFido.changePin(oldPin, newPin);
      _updatePinStatus(result);
      return result >= 0;
    } catch (e) {
      print('Error changing PIN: $e');
      return false;
    }
  }

  Future<bool> changePuk(String oldPuk, String newPuk) async {
    try {
      final usbFido = await _getUsbFido();
      final result = await usbFido.changePuk(oldPuk, newPuk);
      return result >= 0;
    } catch (e) {
      print('Error changing PUK: $e');
      return false;
    }
  }

  Future<bool> changeManagementKey(String oldKey, String newKey) async {
    try {
      final usbFido = await _getUsbFido();
      final result = await usbFido.changeManagementKey(oldKey, newKey);
      return result >= 0;
    } catch (e) {
      print('Error changing management key: $e');
      return false;
    }
  }

  Future<bool> resetToDefaultPin() async {
    try {
      final usbFido = await _getUsbFido();
      final result = await usbFido.resetToDefaultPin();
      if (result >= 0) {
        _remainingPinTries = MAX_PIN_TRIES;
        _isPinBlocked = false;
        notifyListeners();
      }
      return result >= 0;
    } catch (e) {
      print('Error resetting PIN: $e');
      return false;
    }
  }

  Future<int> getRemainingPinTries() async {
    try {
      final usbFido = await _getUsbFido();
      final tries = await usbFido.getRemainingPinTries();
      _remainingPinTries = tries;
      _isPinBlocked = tries == 0;
      notifyListeners();
      return tries;
    } catch (e) {
      print('Error getting remaining PIN tries: $e');
      return ERR_COMMUNICATION;
    }
  }

  void _updatePinStatus(int result) {
    if (result >= 0) {
      _remainingPinTries = MAX_PIN_TRIES;
      _isPinBlocked = false;
    } else if (result == ERR_PIN_BLOCKED) {
      _isPinBlocked = true;
      _remainingPinTries = 0;
    } else if (result > ERR_PIN_BLOCKED) {
      _remainingPinTries = result;
      _isPinBlocked = false;
    }
    notifyListeners();
  }

  bool _validatePinFormat(String pin) {
    if (pin.length < MIN_PIN_LENGTH || pin.length > MAX_PIN_LENGTH) {
      return false;
    }
    // Add additional PIN format validation if needed
    return true;
  }

  String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case ERR_PIN_TOO_SHORT:
        return 'PIN is too short (minimum $MIN_PIN_LENGTH digits)';
      case ERR_PIN_TOO_LONG:
        return 'PIN is too long (maximum $MAX_PIN_LENGTH digits)';
      case ERR_PIN_INVALID:
        return 'Invalid PIN format';
      case ERR_PIN_BLOCKED:
        return 'PIN is blocked. Please use PUK to unblock';
      case ERR_COMMUNICATION:
        return 'Communication error with device';
      default:
        if (errorCode >= 0) {
          return 'Incorrect PIN. $errorCode attempts remaining';
        }
        return 'Unknown error occurred';
    }
  }
}
