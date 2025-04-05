// Class to represent Feitian Security Key VID/PID pairs
class FeitianSecurityKey {
  final String vid;
  final String pid;
  final String name;
  final String imagePath;

  const FeitianSecurityKey({
    required this.vid,
    required this.pid,
    required this.name,
    required this.imagePath,
  });
}

// RLA, List of supported Feitian Security Keys with their VID/PID pairs
const List<FeitianSecurityKey> feitianSecurityKeys = [
  FeitianSecurityKey(
    vid: "096e",
    pid: "086e",
    name: "Feitian K9",
    imagePath: "assets/usb_security_key.png"
  ),
  FeitianSecurityKey(
    vid: "096e",
    pid: "0867",
    name: "Feitian K9-B",
    imagePath: "assets/usb_security_key1.png"
  ),

  // Add more Feitian keys here with their respective VID/PID pairs
  FeitianSecurityKey(
    vid: "096e",
    pid: "085d",
    name: "Feitian ePass FIDO",
    imagePath: "assets/usb_security_key.png"
  ),
  FeitianSecurityKey(
    vid: "096e",
    pid: "0850",
    name: "Feitian MultiPass FIDO",
    imagePath: "assets/usb_security_key.png"
  ),
  FeitianSecurityKey(
    vid: "096e",
    pid: "0852",
    name: "Feitian AllinPass FIDO",
    imagePath: "assets/usb_security_key.png"
  ),
  FeitianSecurityKey(
    vid: "096e",
    pid: "0858",
    name: "Feitian BioPass FIDO2",
    imagePath: "assets/usb_security_key.png"
  ),
  // Add any other Feitian keys as needed
];
