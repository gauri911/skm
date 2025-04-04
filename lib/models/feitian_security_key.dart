// Class to represent Feitian Security Key VID/PID pairs
class FeitianSecurityKey {
  final String vid;
  final String pid;
  final String name;

  const FeitianSecurityKey({
    required this.vid,
    required this.pid,
    required this.name,
  });
}

// RLA, List of supported Feitian Security Keys with their VID/PID pairs
const List<FeitianSecurityKey> feitianSecurityKeys = [
  FeitianSecurityKey(vid: "096e", pid: "086e", name: "Feitian K9"),
  // Add more Feitian keys here with their respective VID/PID pairs
  FeitianSecurityKey(vid: "096e", pid: "085d", name: "Feitian ePass FIDO"),
  FeitianSecurityKey(vid: "096e", pid: "0850", name: "Feitian MultiPass FIDO"),
  FeitianSecurityKey(vid: "096e", pid: "0852", name: "Feitian AllinPass FIDO"),
  FeitianSecurityKey(vid: "096e", pid: "0858", name: "Feitian BioPass FIDO2"),
  FeitianSecurityKey(
    vid: "096e",
    pid: "0867",
    name: "Feitian BioPass PLUS FIDO2",
  ),
  // Add any other Feitian keys as needed
];
