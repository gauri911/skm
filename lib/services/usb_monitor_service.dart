import 'dart:async';
import 'package:usb_communication/usb_fido.dart';
import '../models/feitian_security_key.dart';

class UsbMonitorService {
  final UsbFido _usbFido = UsbFido();
  Timer? _monitorTimer;
  final _deviceStatusController = StreamController<bool>.broadcast();
  bool _lastDeviceStatus = false;

  Stream<bool> get deviceStatus => _deviceStatusController.stream;

  void startMonitoring() {
    // Check every 1 second for more responsive detection
    _monitorTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkDeviceStatus();
    });
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  void _checkDeviceStatus() {
    bool deviceFound = false;

    // Check for any of the supported Feitian security keys
    for (final securityKey in feitianSecurityKeys) {
      final path = _usbFido.findUsbDevice(securityKey.vid, securityKey.pid);
      if (path != null) {
        deviceFound = true;
        break;
      }
    }

    // Always emit the current status to ensure we catch all changes
    if (deviceFound != _lastDeviceStatus) {
      _lastDeviceStatus = deviceFound;
      _deviceStatusController.add(deviceFound);
      print(
        'Device status changed: ${deviceFound ? 'Connected' : 'Disconnected'}',
      );
    }
  }

  Future<void> sendCommand(List<int> command) async {
    // TODO: Implement actual USB communication
    // This is a placeholder implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void dispose() {
    stopMonitoring();
    _deviceStatusController.close();
  }
}
