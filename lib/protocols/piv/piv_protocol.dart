import 'dart:typed_data';
import '../base_protocol.dart';
import 'piv_constants.dart';
import '../../services/usb_monitor_service.dart';

class PIVProtocol extends BaseProtocol {
  final UsbMonitorService _usbService;
  bool _initialized = false;

  PIVProtocol(this._usbService);

  @override
  Future<bool> initialize() async {
    try {
      // Select PIV application
      final response = await sendCommand(PIVConstants.PIV_AID);
      _initialized = _checkResponse(response);
      return _initialized;
    } catch (e) {
      print('Failed to initialize PIV protocol: $e');
      return false;
    }
  }

  @override
  Future<bool> isSupported() async {
    if (!_initialized) {
      return false;
    }
    try {
      final response = await sendCommand(PIVConstants.PIV_AID);
      return _checkResponse(response);
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePIN(String currentPin, String newPin) async {
    if (!_initialized) throw Exception('PIV not initialized');

    final command = [
      PIVConstants.INS_CHANGE_REFERENCE,
      0x00, // P1
      PIVConstants.KEY_REF_PIV_PIN, // P2
      ...Uint8List.fromList(currentPin.codeUnits),
      ...Uint8List.fromList(newPin.codeUnits),
    ];

    final response = await sendCommand(command);
    return _checkResponse(response);
  }

  Future<bool> changePUK(String currentPuk, String newPuk) async {
    if (!_initialized) throw Exception('PIV not initialized');

    final command = [
      PIVConstants.INS_CHANGE_REFERENCE,
      0x00, // P1
      PIVConstants.KEY_REF_PUK, // P2
      ...Uint8List.fromList(currentPuk.codeUnits),
      ...Uint8List.fromList(newPuk.codeUnits),
    ];

    final response = await sendCommand(command);
    return _checkResponse(response);
  }

  Future<bool> resetPin(String puk, String newPin) async {
    try {
      // First verify PUK
      final pukResult = await verifyPUK(puk);
      if (!pukResult) {
        return false;
      }

      // Then set the new PIN using direct command
      final command = [
        PIVConstants.INS_RESET_RETRY,
        0x00, // P1
        PIVConstants.KEY_REF_PIV_PIN, // P2
        ...Uint8List.fromList(newPin.codeUnits),
      ];

      final response = await sendCommand(command);
      return _checkResponse(response);
    } catch (e) {
      print('Error in resetPin: $e');
      return false;
    }
  }

  Future<bool> verifyPIN(String pin) async {
    if (!_initialized) throw Exception('PIV not initialized');

    final command = [
      PIVConstants.INS_VERIFY,
      0x00, // P1
      PIVConstants.KEY_REF_PIV_PIN, // P2
      ...Uint8List.fromList(pin.codeUnits),
    ];

    final response = await sendCommand(command);
    return _checkResponse(response);
  }

  Future<bool> verifyPUK(String puk) async {
    if (!_initialized) throw Exception('PIV not initialized');

    final command = [
      PIVConstants.INS_VERIFY,
      0x00, // P1
      PIVConstants.KEY_REF_PUK, // P2
      ...Uint8List.fromList(puk.codeUnits),
    ];

    final response = await sendCommand(command);
    return _checkResponse(response);
  }

  Future<bool> changeManagementKey(String currentKey, String newKey) async {
    if (!_initialized) throw Exception('PIV not initialized');

    final command = [
      PIVConstants.INS_CHANGE_REFERENCE,
      0x00, // P1
      PIVConstants
          .KEY_REF_MANAGEMENT, // P2 - need to add this constant to PIVConstants
      ...Uint8List.fromList(currentKey.codeUnits),
      ...Uint8List.fromList(newKey.codeUnits),
    ];

    final response = await sendCommand(command);
    return _checkResponse(response);
  }

  @override
  Future<Uint8List> sendCommand(List<int> command) async {
    await _usbService.sendCommand(command);
    // TODO: Add proper response reading from USB service
    // For now return simulated success response
    return Uint8List.fromList([0x90, 0x00]);
  }

  bool _checkResponse(Uint8List response) {
    if (response.length < 2) return false;
    final sw =
        (response[response.length - 2] << 8) | response[response.length - 1];
    return sw == PIVConstants.SW_SUCCESS;
  }

  @override
  Future<String> getVersion() async {
    // TODO: Implement version retrieval by sending appropriate command
    return '1.0.0';
  }

  @override
  Future<bool> reset() async {
    // Reset PIV application by reselecting AID
    final response = await sendCommand(PIVConstants.PIV_AID);
    return _checkResponse(response);
  }

  @override
  Future<void> close() async {
    _initialized = false;
  }
}
