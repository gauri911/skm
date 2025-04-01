#ifndef FLUTTER_PLUGIN_USB_COMMUNICATION_PLUGIN_H_
#define FLUTTER_PLUGIN_USB_COMMUNICATION_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace usb_communication {

class UsbCommunicationPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  UsbCommunicationPlugin();

  virtual ~UsbCommunicationPlugin();

  // Disallow copy and assign.
  UsbCommunicationPlugin(const UsbCommunicationPlugin&) = delete;
  UsbCommunicationPlugin& operator=(const UsbCommunicationPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace usb_communication

#endif  // FLUTTER_PLUGIN_USB_COMMUNICATION_PLUGIN_H_
