import 'package:flutter/foundation.dart';

class VerificationProvider extends ChangeNotifier {
  bool _isVerified = false;
  bool _wasVerified = false;

  bool get isVerified => _isVerified;
  bool get wasVerified => _wasVerified;

  void updateVerificationStatus(bool verified) {
    print('Updating verification status from $_isVerified to $verified');
    _wasVerified = _isVerified;
    _isVerified = verified;
    notifyListeners();
  }

  void clearVerification() {
    print('Clearing verification status from $_isVerified to false');
    _wasVerified = _isVerified;
    _isVerified = false;
    notifyListeners();
  }
} 