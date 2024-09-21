import 'dart:typed_data';
import '../extension/comm_serial.dart';
import '../extension/hex_extension_string.dart';

class HrtComm {
  String? _port;
  void Function(String)? funcRead;
  final _commSerial = CommSerial();
  HrtComm([this._port, this.funcRead]) {
    connect(_port, funcRead);
  }

  String get port => _port ?? "";
  set port(String value) {
    _port = value;
  }

  List<String> get availablePorts => _commSerial.availablePorts;

  String readFrame() {
    final resp = _commSerial.readSerial();
    return resp
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  bool get isConnected => _commSerial.isOpen;

  bool writeFrame(String data) {
    List<int> aux = 
        data.splitByLength(2).map((e) => int.parse(e, radix: 16)).toList();
    Uint8List resp = Uint8List.fromList(aux);
    return _commSerial.writeSerial(resp);
  }

  bool connect([
    String? port,
    void Function(String)? funcRead,
  ]) {
    final funcReadAux = funcRead ?? this.funcRead;
    return (port ?? _port) != null
        ? _commSerial.openSerial(
            port ?? _port!,
            baudRate: 1200,
            bytesize: 8,
            parity: 1,
            stopbits: 1,
            funcRead: funcReadAux != null
                ? (data) {
                    funcReadAux(
                      data
                          .map((e) => e.toRadixString(16).padLeft(2, '0'))
                          .join()
                          .toUpperCase(),
                    );
                  }
                : null,
          )
        : false;
  }

  bool disconnect() {
    return _commSerial.closeSerial();
  }
}
