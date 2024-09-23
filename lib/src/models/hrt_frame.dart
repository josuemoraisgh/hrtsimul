//Retorna a posição que termina o preamble
//PREAMBLE  DELIMITER  ADDRESS  COMMAND  NBBody  BODY   CheckSum
// xbytes    1bytes     1bytes   1bytes   1byte   xbytes 1byte
//                                         OU
// PREAMBLE DELIMITER MANUFACTERID DEVICETYPE ADDRESS  COMMAND  NBBody  BODY   CheckSum
// xbytes   1bytes    1bytes       1bytes     3bytes   1bytes   1byte   xbytes 1byte
import '../extension/bit_field_int.dart';
import '../extension/hex_extension_string.dart';

class HrtFrame {
  String log = "";
  int posIniFrame = 0;
  String preamble = "FFFFFFFFFF";
  bool addressType = false;
  String frameType = "02";
  bool masterAddress = true; // 1 - primary master; 0 - secondary master -> Pra quem ele esta mandando
  bool burstMode = false; // 1 - in Burst Mode; 0 - not Burst Mode or Slave
  String _manufacterId = "00";
  String _deviceType = "00";
  String _deviceId = "00";
  String _pollingAddress = "00";
  String command = "00";
  int _nBBody = 0;
  String _body = "";
  String checkSum = "00";

  HrtFrame([String? frame]) {
    if (frame != null) {
      extractFrame(frame);
    }
  }

  String calcCheckSum(String ck) {
    return ck
        .splitByLength(2)
        .reduce((value, element) =>
            (int.parse(value, radix: 16) ^ int.parse(element, radix: 16))
                .toRadixString(16))
        .toUpperCase()
        .padLeft(2, '0');
  }

  String get frame {
    try {
      log = "";
      final aux = _pacialFrame();
      final ck = calcCheckSum(aux);
      return '$preamble$aux$ck';
    } catch (e) {
      log = "Incorrect Value form Frame";
    }
    return "";
  }

  String _pacialFrame() {
    return "$delimiter$address$command"
        "${_nBBody.toRadixString(16).toUpperCase().padLeft(2, '0')}"
        "$_body";
  }

  set frame(String hrtFrame) {
    log = "";
    extractFrame(hrtFrame);
  }

  void extractFrame(String strFrame) {
    try {
      //Calcula a posIniFrame
      final listFrame = strFrame.splitByLength(2).join(" ");
      int iniFrameAux =
          listFrame.indexOf(RegExp(r'FF ([^F][A-F0-9]|[A-F0-9][^F])'));
      if (iniFrameAux == -1) {
        log = "Don't find Preamble in Frame";
        return;
      } else {
        posIniFrame = (2 * iniFrameAux + 6) ~/ 3;
      }
      ////////////////// Preamble ////////////////////////
      preamble = strFrame.substring(0, posIniFrame);

      ////////////////// Delimiter ////////////////////////
      delimiter = strFrame.substring(posIniFrame, posIniFrame + 2);

      if (addressType == false) {
        ////////////////// Address ////////////////////////
        address = strFrame.substring(posIniFrame + 2, posIniFrame + 4);
        ////////////////// Command ////////////////////////
        command = strFrame.substring(posIniFrame + 4, posIniFrame + 6);
        ////////////////// Nbbody e o Body ////////////////////////
        //Extrai o numero de bytes do body [nbbody] e o body
        _nBBody = int.parse(
            strFrame.substring(posIniFrame + 6, posIniFrame + 8),
            radix: 16);
        _body =
            strFrame.substring(posIniFrame + 8, posIniFrame + 8 + 2 * _nBBody);
      } else {
        ////////////////// Address ////////////////////////
        address = strFrame.substring(posIniFrame + 2, posIniFrame + 12);
        ////////////////// Command ////////////////////////
        command = strFrame.substring(posIniFrame + 12, posIniFrame + 14);
        ////////////////// Nbbody e o Body ////////////////////////
        //Extrai o numero de bytes do body [nbbody] e o body
        _nBBody = int.parse(
            strFrame.substring(posIniFrame + 14, posIniFrame + 16),
            radix: 16);
        _body = strFrame.substring(
            posIniFrame + 16, posIniFrame + 16 + 2 * _nBBody);
      }

      ////////////////// CheckSum ////////////////////////
      //Extrai o CheckSum e checa se ele esta correto.
      checkSum = strFrame.substring(strFrame.length - 2);
      if (calcCheckSum(_pacialFrame()) != checkSum) {
        log = "Incorrect CheckSum";
      }
    } catch (e) {
      log = "Incorrect hart Frame size";
    }
  }

  //O nBBody só pode ser lido não escrito
  int get nBBody => _nBBody;

  //Setando o body ja seta o nBBody
  String get body => _body;
  set body(String newBody) {
    _nBBody = newBody.length ~/ 2;
    _body = newBody;
  }

  //Alterando o delimiter tem que alterar o addressType e o frameType
  String get delimiter => 0
      .setBits(7, 1, addressType == true ? 1 : 0) // addressType
      .setBits(0, 3, int.parse(frameType, radix: 16)) //frameType
      .toRadixString(16)
      .padLeft(2, '0');

  set delimiter(String newDelimiter) {
    final valueAux = int.parse(newDelimiter, radix: 16);
    //Extrai o address type
    addressType = valueAux.getBits(7, 1) == 1 ? true : false;
    //Extrai o frame type
    frameType = valueAux.getBits(0, 3).toRadixString(16).padLeft(2, '0');
  }

  //Alterando o adress tem que alterar: _masterAddress, _burstMode, _pollingAddress, manufacterId, deviceType, deviceId
  String get address =>
      '${0.setBits(7, 1, masterAddress ? 1 : 0).setBits(6, 1, burstMode ? 1 : 0).setBits(0, 6, int.parse(addressType == false ? pollingAddress : manufacterId, radix: 16)).toRadixString(16).padLeft(2, '0')}${(addressType ? '$_deviceType$_deviceId' : "")}';
  set address(String newAddress) {
    final id = newAddress.substring(0, 2);
    final valueAux = int.parse(id, radix: 16);
    //Extrai o master_slave
    masterAddress = valueAux.getBits(7, 1) == 1 ? true : false;
    //Extrai o Burst Mode
    burstMode = valueAux.getBits(6, 1) == 1 ? true : false;
    if (addressType == false) {
      //Extrai o polling_address
      _pollingAddress =
          valueAux.getBits(0, 6).toRadixString(16).padLeft(2, '0');
      manufacterId = "";
      deviceType = "";
      deviceId = "";
    } else {
      //Extrai o manufacter_id
      _pollingAddress = "";
      manufacterId = valueAux.getBits(0, 6).toRadixString(16).padLeft(2, '0');
      deviceType = newAddress.substring(posIniFrame + 2, posIniFrame + 4);
      deviceId = newAddress.substring(posIniFrame + 4, posIniFrame + 10);
    }
  }

  String get pollingAddress => _pollingAddress;
  set pollingAddress(String newPollingAddress) {
    if (addressType == false && newPollingAddress.length == 2) {
      _pollingAddress = newPollingAddress;
    } else {
      log = "pollingAddress incoerent with addressType";
    }
  }

  String get manufacterId => _manufacterId;
  set manufacterId(String newManufacterId) {
    if (addressType == true && newManufacterId.length == 2) {
      _manufacterId = newManufacterId;
    } else {
      log = "manufacterId incoerent with addressType";
    }
  }

  String get deviceType => _deviceType;
  set deviceType(String newDeviceType) {
    if (addressType == true && deviceType.length == 2) {
      _deviceType = newDeviceType;
    } else {
      log = "deviceType incoerent with addressType";
    }
  }

  String get deviceId => _deviceId;
  set deviceId(String newDeviceId) {
    if (addressType == true && newDeviceId.length == 6) {
      _deviceId = newDeviceId;
    } else {
      log = "deviceId incoerent with addressType";
    }
  }
}
