import 'package:flutter/foundation.dart';
import '../models/security_key.dart';
import '../services/security_key_service.dart';

class SecurityKeyProvider extends ChangeNotifier {
  final SecurityKeyService _service;
  SecurityKey? _securityKey;
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;

  SecurityKeyProvider(this._service);

  SecurityKey? get securityKey => _securityKey;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  Future<void> loadSecurityKey() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _securityKey = await _service.getSecurityKeyInfo();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _securityKey = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleInterface(String interface) async {
    if (_securityKey == null) return;

    try {
      await _service.toggleInterface(interface);
      _securityKey = _securityKey!.copyWith(
        interfaceStates: Map.from(_securityKey!.interfaceStates)
          ..[interface] = !_securityKey!.interfaceStates[interface]!,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> changePIN(String oldPin, String newPin) async {
    try {
      await _service.changePIN(oldPin, newPin);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> verifyKey() async {
    try {
      final result = await _service.verifyKey();
      _error = null;
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> checkConnection() async {
    _isConnected = await _service.isConnected();
    notifyListeners();
  }

  Future<void> connect() async {
    await _service.connect();
    _isConnected = true;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    _isConnected = false;
    notifyListeners();
  }
} 