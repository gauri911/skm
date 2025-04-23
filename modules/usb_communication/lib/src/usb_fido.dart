import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// FFI type definitions
typedef FindDeviceNative = Pointer<Utf8> Function(Pointer<Utf8> vid,
    Pointer<Utf8> pid, Pointer<Utf8> devicePath, Uint32 devicePathSize);
typedef FindDeviceDart = Pointer<Utf8> Function(Pointer<Utf8> vid,
    Pointer<Utf8> pid, Pointer<Utf8> devicePath, int devicePathSize);

typedef VerifyPinNative = Int32 Function(Pointer<Utf8> pin);
typedef VerifyPinDart = int Function(Pointer<Utf8> pin);

typedef ChangePinNative = Int32 Function(
    Pointer<Utf8> oldPin, Pointer<Utf8> newPin);
typedef ChangePinDart = int Function(
    Pointer<Utf8> oldPin, Pointer<Utf8> newPin);

typedef GetPinTriesNative = Int32 Function();
typedef GetPinTriesDart = int Function();

typedef ChangePukNative = Int32 Function(Pointer<Utf8> oldPuk, Pointer<Utf8> newPuk);
typedef ChangePukDart = int Function(Pointer<Utf8> oldPuk, Pointer<Utf8> newPuk);

typedef ChangeManagementKeyNative = Int32 Function(Pointer<Utf8> oldKey, Pointer<Utf8> newKey);
typedef ChangeManagementKeyDart = int Function(Pointer<Utf8> oldKey, Pointer<Utf8> newKey);

typedef ResetToDefaultPinNative = Int32 Function();
typedef ResetToDefaultPinDart = int Function();

class UsbFido {
  static final DynamicLibrary _lib = _loadLibrary();

  // Native functions
  late final FindDeviceDart _findDevice;
  late final VerifyPinDart _verifyPin;
  late final ChangePinDart _changePin;
  late final GetPinTriesDart _getPinTries;
  late final ChangePukDart _changePuk;
  late final ChangeManagementKeyDart _changeManagementKey;
  late final ResetToDefaultPinDart _resetToDefaultPin;

  UsbFido() {
    _findDevice =
        _lib.lookupFunction<FindDeviceNative, FindDeviceDart>('FindUsbDevice');
    _verifyPin =
        _lib.lookupFunction<VerifyPinNative, VerifyPinDart>('verifyUserPin');
    _changePin =
        _lib.lookupFunction<ChangePinNative, ChangePinDart>('changePin');
    _getPinTries = _lib.lookupFunction<GetPinTriesNative, GetPinTriesDart>(
        'getRemainingPinTries');
    _changePuk = _lib.lookupFunction<ChangePukNative, ChangePukDart>('changePuk');
    _changeManagementKey = _lib.lookupFunction<ChangeManagementKeyNative, ChangeManagementKeyDart>('changeManagementKey');
    _resetToDefaultPin = _lib.lookupFunction<ResetToDefaultPinNative, ResetToDefaultPinDart>('resetToDefaultPin');
  }

  static DynamicLibrary _loadLibrary() {
    if (Platform.isWindows) {
      final libraryPath = path.join(
        Directory.current.path,
        'windows',
        'usb_hid_plugin.dll',
      );
      return DynamicLibrary.open(libraryPath);
    }
    throw UnsupportedError('Unsupported platform');
  }

  String? findUsbDevice(String vid, String pid) {
    final vidPtr = vid.toNativeUtf8();
    final pidPtr = pid.toNativeUtf8();
    final pathPtr = calloc<Uint8>(256); // Changed from Utf8 to Uint8
    final pathUtf8 = pathPtr.cast<Utf8>();

    try {
      final result = _findDevice(vidPtr, pidPtr, pathUtf8, 256);
      if (result != nullptr) {
        return pathUtf8.toDartString();
      }
      return null;
    } finally {
      calloc.free(vidPtr);
      calloc.free(pidPtr);
      calloc.free(pathPtr);
    }
  }

  Future<int> verifyUserPin(String pin) async {
    final pinPointer = pin.toNativeUtf8();
    try {
      return _verifyPin(pinPointer);
    } finally {
      calloc.free(pinPointer);
    }
  }

  Future<int> changePin(String oldPin, String newPin) async {
    final oldPinPointer = oldPin.toNativeUtf8();
    final newPinPointer = newPin.toNativeUtf8();
    try {
      return _changePin(oldPinPointer, newPinPointer);
    } finally {
      calloc.free(oldPinPointer);
      calloc.free(newPinPointer);
    }
  }

  Future<int> getRemainingPinTries() async {
    return _getPinTries();
  }

  Future<int> changePuk(String oldPuk, String newPuk) async {
    final oldPukPointer = oldPuk.toNativeUtf8();
    final newPukPointer = newPuk.toNativeUtf8();
    try {
      return _changePuk(oldPukPointer, newPukPointer);
    } finally {
      calloc.free(oldPukPointer);
      calloc.free(newPukPointer);
    }
  }

  Future<int> changeManagementKey(String oldKey, String newKey) async {
    final oldKeyPointer = oldKey.toNativeUtf8();
    final newKeyPointer = newKey.toNativeUtf8();
    try {
      return _changeManagementKey(oldKeyPointer, newKeyPointer);
    } finally {
      calloc.free(oldKeyPointer);
      calloc.free(newKeyPointer);
    }
  }

  Future<int> resetToDefaultPin() async {
    return _resetToDefaultPin();
  }
}
