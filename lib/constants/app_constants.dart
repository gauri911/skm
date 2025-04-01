class AppConstants {
  static const String appName = 'Feitian Authenticator';
  static const String defaultSecurityKeyName = 'FEITIAN iePass K44 USB Security Key';
  
  // Interface names
  static const String interfaceFIDO = 'FIDO';
  static const String interfacePIV = 'PIV';
  static const String interfaceCCID = 'CCID';
  static const String interfaceOTP = 'OTP';

  // Method channel names
  static const String securityKeyChannel = 'com.feitian.security_key';

  // Shared preferences keys
  static const String keyVerifiedKey = 'key_verified';
  static const String themeKey = 'theme';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 2);

  // Error messages
  static const String errorDeviceNotFound = 'Security key not found';
  static const String errorConnectionFailed = 'Failed to connect to security key';
  static const String errorPINChangeFailed = 'Failed to change PIN';
  static const String errorVerificationFailed = 'Failed to verify security key';
} 