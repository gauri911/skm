import 'dart:async';

class UsbDetectionService {
  // Stream controller to broadcast USB connection events
  final _usbConnectionController = StreamController<bool>.broadcast();

  // Stream that components can listen to for USB connection events
  Stream<bool> get onUsbConnectionChanged => _usbConnectionController.stream;

  // Flag to track if we've already notified about a connection
  bool _hasNotifiedConnection = false;

  UsbDetectionService() {
    // Initialize USB detection
    _initUsbDetection();
  }

  void _initUsbDetection() {
    // In a real implementation, this would hook into native code or a plugin
    // that detects USB devices connecting/disconnecting

    // For simulation purposes, we'll just emit a single event on startup
    // to simulate a device being already connected
    if (!_hasNotifiedConnection) {
      // Small delay to ensure subscribers are registered
      Future.delayed(const Duration(seconds: 1), () {
        _usbConnectionController.add(true);
        _hasNotifiedConnection = true;
      });
    }

    // Real implementation would monitor USB events here instead of using a timer
    // This commented code is kept for reference only
    // Timer.periodic(const Duration(seconds: 5), (timer) {
    //   _usbConnectionController.add(true);
    // });
  }

  // Method to manually trigger a connection event (for testing)
  void simulateDeviceConnection() {
    _usbConnectionController.add(true);
  }

  // Method to manually trigger a disconnection event (for testing)
  void simulateDeviceDisconnection() {
    _usbConnectionController.add(false);
  }

  void dispose() {
    _usbConnectionController.close();
  }
}
