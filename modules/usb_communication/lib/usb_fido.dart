import 'package:ffi/ffi.dart';
import 'usb_communication.dart';

class UsbFido {
  final UsbCommunication _usbCommunication = UsbCommunication();

  // Finds the USB device by VID and PID
  String? findUsbDevice(String vid, String pid) {
    return _usbCommunication.findUsbDevice(vid, pid);
  }

  // Opens a connection to the USB device by its path
  int openDeviceByPath(String path) {
    return _usbCommunication.openDeviceByPath(path);
  }

  // Opens a FIDO connection based on VID and PID
  Future<int?> openFidoConnection(String vid, String pid) async {
    final devicePath = findUsbDevice(vid, pid);
    if (devicePath != null) {
      return openDeviceByPath(devicePath);
    } else {
      throw Exception('USB FIDO device not found');
    }
  }

  // Registers the FIDO device with a specific command
  Future<void> registerFido(int handle, List<int> command) async {
    _usbCommunication.sendCommand(handle, command);
    final response = _usbCommunication.receiveResponse(handle, 64);
    print("FIDO Registration Response: $response");
  }

  // Sets a PIN on the FIDO device
  Future<void> setPin(int handle, String pin) async {
    final pinCommand = buildPinCommand(pin);
    _usbCommunication.sendCommand(handle, pinCommand);
    final response = _usbCommunication.receiveResponse(handle, 64);
    print("Set PIN Response: $response");
  }

  // Verifies the PIN on the FIDO device
  Future<void> verifyPin(int handle, String pin) async {
    final pinCommand = buildPinCommand(pin, forVerification: true);
    _usbCommunication.sendCommand(handle, pinCommand);
    final response = _usbCommunication.receiveResponse(handle, 64);
    print("Verify PIN Response: $response");
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    // Convert strings to Utf8 pointers
    final oldPinPtr = oldPin.toNativeUtf8();
    final newPinPtr = newPin.toNativeUtf8();

    try {
      final result = _usbCommunication.changePin(oldPinPtr.cast(), newPinPtr.cast());
      return result == 0; // Assuming 0 indicates success
    } finally {
      // Free memory
      calloc.free(oldPinPtr);
      calloc.free(newPinPtr);
    }
  }

  // Helper method to build a command for setting or verifying the PIN
  List<int> buildPinCommand(String pin, {bool forVerification = false}) {
    final commandPrefix = forVerification ? [0x10, 0x11] : [0x00, 0x01];
    return [...commandPrefix, ...pin.codeUnits];
  }

  // Closes the FIDO device connection
  Future<void> closeConnection(int handle) async {
    _usbCommunication.closeDevice(handle);
  }
}
