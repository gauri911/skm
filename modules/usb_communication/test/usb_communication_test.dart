import 'package:flutter_test/flutter_test.dart';
import 'package:usb_communication/usb_communication.dart';
import 'package:usb_communication/usb_communication_platform_interface.dart';
import 'package:usb_communication/usb_communication_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUsbCommunicationPlatform
    with MockPlatformInterfaceMixin
    implements UsbCommunicationPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UsbCommunicationPlatform initialPlatform = UsbCommunicationPlatform.instance;

  test('$MethodChannelUsbCommunication is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUsbCommunication>());
  });

  test('getPlatformVersion', () async {
    UsbCommunication usbCommunicationPlugin = UsbCommunication();
    MockUsbCommunicationPlatform fakePlatform = MockUsbCommunicationPlatform();
    UsbCommunicationPlatform.instance = fakePlatform;

    expect(await usbCommunicationPlugin.getPlatformVersion(), '42');
  });
}
