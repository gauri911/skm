import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef ChangePinNative = Int32 Function(Pointer<Utf8> oldPin, Pointer<Utf8> newPin);
typedef ChangePinDart = int Function(Pointer<Utf8> oldPin, Pointer<Utf8> newPin);

class UsbCommunication {
  final DynamicLibrary _usbLib = DynamicLibrary.open('usb_hid_plugin.dll');

  Future<String?> getPlatformVersion() async {
  // Return a hardcoded or dynamically fetched platform version
  // Example: Returning hardcoded value for demonstration
  return 'Windows 10';
  }


  int changePin(Pointer<Utf8> oldPin, Pointer<Utf8> newPin) {
    final changePinFunction = _usbLib
        .lookupFunction<ChangePinNative, ChangePinDart>('changePin');
    return changePinFunction(oldPin, newPin);
  }

  // FFI Binding for FindUsbDevice
  late final _findUsbDevice = _usbLib.lookupFunction<
      Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, Uint32),
      int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, int)>('FindUsbDevice');

  // FFI Binding for OpenDeviceByPath
  late final _openDeviceByPath = _usbLib.lookupFunction<
      IntPtr Function(Pointer<Utf8>),
      int Function(Pointer<Utf8>)>('OpenDeviceByPath');

  // FFI Binding for CloseDevice
  late final _closeDevice = _usbLib.lookupFunction<
      Void Function(IntPtr),
      void Function(int)>('CloseDevice');

  // FFI Binding for WriteDevice
  late final _writeDevice = _usbLib.lookupFunction<
      Int32 Function(IntPtr, Pointer<Uint8>, Uint32, Pointer<Uint32>),
      int Function(int, Pointer<Uint8>, int, Pointer<Uint32>)>('WriteDevice');

  // FFI Binding for ReadDevice
  late final _readDevice = _usbLib.lookupFunction<
      Int32 Function(IntPtr, Pointer<Uint8>, Uint32, Pointer<Uint32>),
      int Function(int, Pointer<Uint8>, int, Pointer<Uint32>)>('ReadDevice');

  /// Finds the USB device by VID and PID and returns the device path if found.
  String? findUsbDevice(String vid, String pid) {
    final vidPtr = vid.toNativeUtf8();
    final pidPtr = pid.toNativeUtf8();
    final pathPtr = calloc<Uint8>(256); // Buffer to store device path

    final found = _findUsbDevice(vidPtr, pidPtr, pathPtr, 256);
    calloc.free(vidPtr);
    calloc.free(pidPtr);

    if (found == 1) {
      final devicePath = pathPtr.cast<Utf8>().toDartString();
      calloc.free(pathPtr);
      return devicePath;
    } else {
      calloc.free(pathPtr);
      return null;
    }
  }

  /// Opens a device by its path and returns a handle to the device.
  int openDeviceByPath(String path) {
    final pathPtr = path.toNativeUtf8();
    final handle = _openDeviceByPath(pathPtr);
    calloc.free(pathPtr);
    if (handle == 0) {
      throw Exception("Failed to open device at path: $path");
    }
    return handle;
  }

  /// Closes the device handle.
  void closeDevice(int handle) {
    _closeDevice(handle);
  }

  /// Sends a command to the USB device.
  void sendCommand(int handle, List<int> command) {
    final commandPtr = calloc<Uint8>(command.length);
    final bytesWritten = calloc<Uint32>();

    for (var i = 0; i < command.length; i++) {
      commandPtr[i] = command[i];
    }

    final result = _writeDevice(handle, commandPtr, command.length, bytesWritten);
    if (result != -1) { // -1 indicates success; anything else is an error code
      calloc.free(commandPtr);
      calloc.free(bytesWritten);
      throw Exception('Failed to write to USB device. Error code: $result');
    }

    calloc.free(commandPtr);
    calloc.free(bytesWritten);
  }

  /// Receives a response from the USB device.
  List<int> receiveResponse(int handle, int responseLength) {
    final responsePtr = calloc<Uint8>(responseLength);
    final bytesRead = calloc<Uint32>();

    final success = _readDevice(handle, responsePtr, responseLength, bytesRead);
    if (success == 0) {
      calloc.free(responsePtr);
      calloc.free(bytesRead);
      throw Exception('Failed to read from USB device.');
    }

    final response = <int>[];
    for (var i = 0; i < bytesRead.value; i++) {
      response.add(responsePtr[i]);
    }

    calloc.free(responsePtr);
    calloc.free(bytesRead);
    return response;
  }
}
