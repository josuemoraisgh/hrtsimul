import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class CommSerial {
  SerialPort? _sp;
  SerialPortReader? _reader;


  List<String> get availablePorts => SerialPort.availablePorts;

  bool get isOpen => _sp!.isOpen;

  void listenReader(void Function(Uint8List) dataFunc) {
    if (_reader != null) {
      _reader!.stream.listen(dataFunc);
    }
  }

  // baudrate The baudrate to set.
  // bits The number of data bits to use (5, 6, 7 or 8).
  // parity The parity setting to use (0 = none, 1 = even, 2 = odd).
  // stopbits The number of stop bits to use (1 or 2).
  // flowcontrol The flow control settings to use (0 = none,
  // rts Status of RTS line (0 or 1; required by some interfaces).
  // dtr Status of DTR line (0 or 1; required by some interfaces).
  bool openSerial(String port,
      {int? baudRate,
      int? bytesize,
      int? parity,
      int? stopbits,
      void Function(Uint8List)? funcRead}) {
    try {
      if (_sp != null) if (_sp!.isOpen) _sp!.close();
      _sp = SerialPort(port);
      if (funcRead != null) {
        _reader = SerialPortReader(_sp!);
        if (_reader != null) {
          _reader!.stream.listen(funcRead);
        }
      }
      _sp!.openReadWrite();
      SerialPortConfig config = _sp!.config;
      //config.setFlowControl(SerialPortFlowControl.rtsCts);
      //config.cts = SerialPortCts.flowControl;
      //config.rts = SerialPortRts.flowControl;
      //config.xonXoff = SerialPortXonXoff.inOut;      
      if (baudRate != null) {
        config.baudRate = baudRate;
      }
      if (bytesize != null) {
        config.bits = bytesize;
      }
      if (parity != null) {
        config.parity = parity;
      }
      if (stopbits != null) {
        config.stopBits = stopbits;
      }
      _sp!.config = config;
      return true;
    } on SerialPortError catch (err, _) {
      if (kDebugMode) {
        print(SerialPort.lastError);
      }
    }
    return false;
  }

  bool closeSerial() {
    bool resp = false;
    if (_sp != null) {
      if (_sp!.isOpen) {
        resp = _sp!.close();
        if (_reader != null) _reader!.close();
      }
    }
    return resp;
  }

  Uint8List readSerial() {
    if (_sp != null) {
      if (_sp!.isOpen) {
        return _sp!.read(_sp!.bytesAvailable);
      }
    }
    return Uint8List(0);
  }

  bool writeSerial(Uint8List write) {
    int tam = 0;
    if (_sp != null) {
      if (_sp!.isOpen) {
        if (write.isNotEmpty) {
          try {
            tam = _sp!.write(write, timeout: 0);
          } on SerialPortError catch (err, _) {
            if (kDebugMode) {
              print(SerialPort.lastError);
            }
          }
        }
        if (tam >= write.length) return true;
      }
    }
    return false;
  }
}
