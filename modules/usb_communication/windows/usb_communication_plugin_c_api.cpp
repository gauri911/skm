#include "include/usb_communication/usb_communication_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "usb_communication_plugin.h"

void UsbCommunicationPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  usb_communication::UsbCommunicationPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
