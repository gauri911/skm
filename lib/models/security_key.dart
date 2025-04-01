class SecurityKey {
  final String name;
  final String serialNumber;
  final String firmwareVersion;
  final bool isConnected;
  final Map<String, bool> interfaceStates;

  SecurityKey({
    required this.name,
    required this.serialNumber,
    required this.firmwareVersion,
    this.isConnected = false,
    Map<String, bool>? interfaceStates,
  }) : interfaceStates = interfaceStates ?? {
          'FIDO': false,
          'PIV': false,
          'CCID': false,
          'OTP': false,
        };

  SecurityKey copyWith({
    String? name,
    String? serialNumber,
    String? firmwareVersion,
    bool? isConnected,
    Map<String, bool>? interfaceStates,
  }) {
    return SecurityKey(
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      isConnected: isConnected ?? this.isConnected,
      interfaceStates: interfaceStates ?? this.interfaceStates,
    );
  }
} 