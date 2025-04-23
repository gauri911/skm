import 'dart:typed_data';

abstract class BaseProtocol {
  Future<bool> initialize();
  Future<bool> isSupported();
  Future<String> getVersion();
  Future<bool> reset();
  Future<void> close();
  Future<Uint8List> sendCommand(List<int> command);
}
