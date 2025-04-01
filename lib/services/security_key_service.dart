import 'package:flutter/services.dart';
import '../models/security_key.dart';

class SecurityKeyService {
  static const platform = MethodChannel('com.feitian.security_key');
  
  bool _isConnected = false;

  Future<bool> isConnected() async {
    return _isConnected;
  }

  Future<void> connect() async {
    _isConnected = true;
  }

  Future<void> disconnect() async {
    _isConnected = false;
  }

  Future<SecurityKey> getSecurityKeyInfo() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getSecurityKeyInfo');
      return SecurityKey(
        name: result['name'] ?? 'Unknown Device',
        serialNumber: result['serialNumber'] ?? 'Unknown',
        firmwareVersion: result['firmwareVersion'] ?? 'Unknown',
        isConnected: result['isConnected'] ?? false,
      );
    } on PlatformException catch (e) {
      throw Exception('Failed to get security key info: ${e.message}');
    }
  }

  Future<void> toggleInterface(String interface) async {
    try {
      await platform.invokeMethod('toggleInterface', {'interface': interface});
    } on PlatformException catch (e) {
      throw Exception('Failed to toggle interface: ${e.message}');
    }
  }

  Future<void> changePIN(String oldPin, String newPin) async {
    try {
      await platform.invokeMethod('changePIN', {
        'oldPin': oldPin,
        'newPin': newPin,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to change PIN: ${e.message}');
    }
  }

  Future<bool> verifyKey() async {
    try {
      final bool result = await platform.invokeMethod('verifyKey');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to verify key: ${e.message}');
    }
  }
} 