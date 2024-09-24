import '../models/hrt_frame.dart';
import '../models/hrt_storage.dart';
import '../extension/hex_extension_string.dart';

class HrtBuild {
  final _hrtFrameWrite = HrtFrame();

  HrtBuild(HrtStorage hrtStorage, HrtFrame hrtFrameRead) {
    _hrtFrameWrite.command = hrtFrameRead.command;
    _hrtFrameWrite.addressType = hrtFrameRead.addressType;
    hrtStorage.setVariable(
        'address_type', hrtFrameRead.addressType == false ? '00' : '80');
    _hrtFrameWrite.frameType = hrtStorage.getVariable('frame_type')!;
    _hrtFrameWrite.masterAddress =
        hrtStorage.getVariable('master_address') == "00" ? false : true;
    if (_hrtFrameWrite.addressType) {
      _hrtFrameWrite.manufacterId = hrtStorage.getVariable('manufacturer_id')!;
      _hrtFrameWrite.deviceType = hrtStorage.getVariable('device_type')!;
      _hrtFrameWrite.deviceId = hrtStorage.getVariable('device_id')!;
    } else {
      _hrtFrameWrite.pollingAddress =
          hrtStorage.getVariable('polling_address')!;
    }
    if (_hrtFrameWrite.frameType == "02") {
      _request(hrtStorage, hrtFrameRead);
    } else {
      _response(hrtStorage, hrtFrameRead);
    }
  }

  String get frame => _hrtFrameWrite.frame;

  void _request(final HrtStorage hrtStorage, final HrtFrame hrtFrameRead) {
    switch (hrtFrameRead.command) {
      case '00': //Identity Command
        _hrtFrameWrite.body = "";
        break;
      case '01': //Read Primary Variable
        _hrtFrameWrite.body = "";
        break;
      case '02': //Read Loop Current And Percent Of Range
        _hrtFrameWrite.body = "";
        break;
      case '03': //Read Dynamic Variables And Loop Current
        _hrtFrameWrite.body = "";
        break;
      case '04': 
        _hrtFrameWrite.body = "";
        break;
      case '05': 
        _hrtFrameWrite.body = "";
        break;                
      case '06': //Write Polling Address
        _hrtFrameWrite.body = "${hrtStorage.getVariable('polling_address')}"
            "${hrtStorage.getVariable('loop_current_mode')}";
        break;
      case '07': //Read Loop Configuration
        _hrtFrameWrite.body = "";
        break;
      case '08': //Read Dynamic Variable Classifications
        _hrtFrameWrite.body = "";
        break;
      case '09': //Read Device Variables with Status
        _hrtFrameWrite.body = "";
        break;
      case '10': //
        _hrtFrameWrite.body = "";
        break;        
      case '11': //Read Unique Identifier Associated With Tag
        _hrtFrameWrite.body = hrtStorage.getVariable('tag')!;
        break;
      case '0C': //Read Message (12)
        _hrtFrameWrite.body = "";
        break;
      case '0D': //Read Tag, Descriptor, Date (13)
        _hrtFrameWrite.body = "";
        break;
      case '21': //Read Device Variables (33)
        _hrtFrameWrite.body = "";     
    }
  }

  void _response(final HrtStorage hrtStorage, final HrtFrame hrtFrameRead) {
    switch (hrtFrameRead.command) {
      case '00': //Identity Command
        _hrtFrameWrite.body = "0000" //error_code
            "FE"
            "${hrtStorage.getVariable('master_address')! | hrtStorage.getVariable('manufacturer_id')!}"
            "${hrtStorage.getVariable('device_type')!}"
            "${hrtStorage.getVariable('request_preambles')!}"
            "${hrtStorage.getVariable('hart_revision')!}"
            "${hrtStorage.getVariable('software_revision')!}"
            "${hrtStorage.getVariable('transmitter_revision')!}"
            "${hrtStorage.getVariable('hardware_revision')!}"
            "${hrtStorage.getVariable('device_flags')!}"
            "${hrtStorage.getVariable('device_id')!}";
        break;
      case '01': //Read Primary Variable
        _hrtFrameWrite.body = "0000" //error_code
            "${hrtStorage.getVariable('unit_code')}"
            "${hrtStorage.getVariable('PROCESS_VARIABLE')}";
        break;
      case '02': //Read Loop Current And Percent Of Range
        _hrtFrameWrite.body = "0000" //error_code
            "${hrtStorage.getVariable('loop_current')}"
            "${hrtStorage.getVariable('percent_of_range')}";
        break;
      case '03': //Read Dynamic Variables And Loop Current
        _hrtFrameWrite.body = "0000" //error_code
            "${hrtStorage.getVariable('loop_current')}"
            "${hrtStorage.getVariable('unit_code')}"
            "${hrtStorage.getVariable('PROCESS_VARIABLE')}"
            "${hrtStorage.getVariable('unit_code')}"
            "${hrtStorage.getVariable('PROCESS_VARIABLE')}"
            "${hrtStorage.getVariable('unit_code')}"
            "${hrtStorage.getVariable('PROCESS_VARIABLE')}"
            "${hrtStorage.getVariable('unit_code')}"
            "${hrtStorage.getVariable('PROCESS_VARIABLE')}";
        break;
      case '04': //
        _hrtFrameWrite.body = "0000";
        break;
      case '05': //
        _hrtFrameWrite.body = "0000";
        break;
      case '06': //Write Polling Address
        final pollingAddress = hrtFrameRead.body.substring(0, 2);
        final loopCurrentMode = hrtFrameRead.body.substring(2);
        hrtStorage.setVariable('polling_address', pollingAddress);
        hrtStorage.setVariable('loop_current_mode', loopCurrentMode);
        _hrtFrameWrite.body = "0000" //error_code
            "$pollingAddress"
            "$loopCurrentMode";
        break;
      case '07': //Read Loop Configuration
        _hrtFrameWrite.body = "0000" //error_code
            "${hrtStorage.getVariable('polling_address')}"
            "${hrtStorage.getVariable('loop_current_mode')}";
        break;
      case '08': //Read Dynamic Variable Classifications
        _hrtFrameWrite.body = "0000" //error_code
            "${hrtStorage.getVariable('primary_variable_classification')}"
            "${hrtStorage.getVariable('secondary_variable_classification')}"
            "${hrtStorage.getVariable('tertiary_variable_classification')}"
            "${hrtStorage.getVariable('quaternary_variable_classification')}";
        break;
      case '09': //Read Device Variables with Status
        _hrtFrameWrite.body = "0000";
        break;
      case '0A': // (10)
        _hrtFrameWrite.body = "0000";
        break;
      case '0B': //Read Unique Identifier Associated With Tag (11)
        _hrtFrameWrite.body =
            "${(hrtFrameRead.body == hrtStorage.getVariable('tag')) ? '00' : '01'}"
            "FE"
            "${hrtStorage.getVariable('master_slave')! | hrtStorage.getVariable('manufacturer_id')!}"
            "${hrtStorage.getVariable('device_type')}"
            "${hrtStorage.getVariable('request_preambles')}"
            "${hrtStorage.getVariable('hart_revision')}"
            "${hrtStorage.getVariable('software_revision')}"
            "${hrtStorage.getVariable('transmitter_revision')}"
            "${hrtStorage.getVariable('hardware_revision')}"
            "${hrtStorage.getVariable('device_flags')}"
            "${hrtStorage.getVariable('device_id')}";
        break;
      case '0C': //Read Message (12)
        _hrtFrameWrite.body = "0000" //error_code
            "${hrtStorage.getVariable('message')}";
        break;
      case '0D': //Read Tag, Descriptor, Date (13)
        _hrtFrameWrite.body = "0000" //error_code
            "${hrtStorage.getVariable('tag')}"
            "${hrtStorage.getVariable('descriptor')}"
            "${hrtStorage.getVariable('date')}";
        break;
      case '0E': //Read Primary Variable Transducer Information (14)
        _hrtFrameWrite.body =
            '00000000002044548000C348000041200000';
        break;
      case '0F': //Read Device Information (15)
        _hrtFrameWrite.body =
            '01002343BA933342924CCC3F800000013E';
        break;
      case '10': //Read Final Assembly Number (16)
        _hrtFrameWrite.body = '000000FBC6';
        break;
      case '11': //Write Message (17)
        _hrtFrameWrite.body = '';
        break;
      case '12': //Write Tag, Descriptor, Date (18)
        _hrtFrameWrite.body = '';
        break;
      case '13': //Comand 13 - Write Final Assembly Number (19)
        _hrtFrameWrite.body = '';
        break;
      case '21': //Read Device Variables (33)
        _hrtFrameWrite.body = switch (hrtFrameRead.body) {
          '00' => '0000002740EE2D42',
          '01' => '0000013941AC26AA',
          '02' => '0000022041CF9540',
          '03' => '0000032041C8D990',
          '04' => '0000043941AC2621',
          '05' => '0000053900000000',
          '0C' => '00000C333F800000',
          '19' => '0040190042DD261B',
          _ =>    '000000007FA00000',
        };
        break;
      case '26': //Resetar as Flags de Erro (38)
        _hrtFrameWrite.body = '020000E63F3F';
        break;
      case '28': //Enter/Exit Fixed Current Mode (40)
        _hrtFrameWrite.body = '2806004000000000';
        break;
      case '29': //Perform Self Test (41)
        _hrtFrameWrite.body = '4020';
        break;
      case '2A': //Perform Device Reset (42)
        _hrtFrameWrite.body = '0000';
        break;
      case '2D': //Trim/Adjusting the 4 mA (45)
        _hrtFrameWrite.body = '0900';
        break;
      case '2E': //Trim/Adjusting the 20 mA (46)
        _hrtFrameWrite.body = '0900';
        break;
      case '50': //Read Dynamic Variable Assignments (80)
        _hrtFrameWrite.body = '5000';
        break;
      case '82': //Write Device Variable Trim Point (130)
        _hrtFrameWrite.body = '00000201020101';
        break;
      case '84': //Comando 132 -
        _hrtFrameWrite.body = '000002012543D2000040A99999';
        break;
      case '87': //Write I/O System Master Mode (135)
        _hrtFrameWrite.body = '00400201';
        break;
      case '88': //Comando 136 -
        _hrtFrameWrite.body = '700002FFFFFF';
        break;
      case '8A': //Comando 8A -
        _hrtFrameWrite.body = '000002FF';
        break;
      case '8C': //Comando 8C -
        _hrtFrameWrite.body =
            '7000023941AC33E939000000003942480000FFFF3900000000';
        break;
      case '98': //Comando 98 -
        _hrtFrameWrite.body = '';
        break;
      case 'A2': //Comando A2 -
        _hrtFrameWrite.body = '00000201';
        break;
      case 'A4': //Comando A4 -
        _hrtFrameWrite.body = '0000020200';
        break;
      case 'A6': //Comando A6 -
        _hrtFrameWrite.body = '00000222040000130A270000010B00';
        break;
      case 'A8': //Comando A8 -
        _hrtFrameWrite.body = '00000201FF';
        break;
      case 'AD': //Comando AD -
        _hrtFrameWrite.body =
            '0000025454333031313131302D425549314C335030543459';
        break;
      case 'B9': //Comando B9 -
        _hrtFrameWrite.body = '004002';
        break;
      case 'BB': //Comando BB -
        _hrtFrameWrite.body = '000002FF';
        break;
      case 'C6': //Comando C6 -
        _hrtFrameWrite.body = '00000242480000';
        break;
      case 'DF': //Comando DF -
        _hrtFrameWrite.body =
            '00000242C800003B801132B51B057FAC932D1D';
        break;
    }
  }
}
