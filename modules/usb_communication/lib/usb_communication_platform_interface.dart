import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'usb_communication_method_channel.dart';

abstract class UsbCommunicationPlatform extends PlatformInterface {
  UsbCommunicationPlatform() : super(token: _token);

  static final Object _token = Object();

  static UsbCommunicationPlatform _instance = MethodChannelUsbCommunication();

  static UsbCommunicationPlatform get instance => _instance;

  static set instance(UsbCommunicationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }
}
