import 'package:flutter/services.dart';
import 'usb_communication_platform_interface.dart';

class MethodChannelUsbCommunication extends UsbCommunicationPlatform {
  final methodChannel = const MethodChannel('usb_communication');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
