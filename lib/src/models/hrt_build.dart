import '../models/hrt_frame.dart';
import '../models/hrt_storage.dart';
import '../extension/hex_extension_string.dart';

class HrtBuild {
  final _hrtFrameWrite = HrtFrame();

  HrtBuild(HrtStorage hrtStorage, HrtFrame hrtFrameRead) {
    _hrtFrameWrite.command = hrtFrameRead.command;
    _hrtFrameWrite.addressType =
        hrtStorage.getVariable('address_type') == "00" ? false : true;
    _hrtFrameWrite.frameType = hrtStorage.getVariable('frame_type')!;
    _hrtFrameWrite.masterAddress =
        hrtStorage.getVariable('master_address') == "00" ? false : true;
    if (_hrtFrameWrite.addressType) {
      _hrtFrameWrite.manufacterId = hrtStorage.getVariable('manufacter_id')!;
      _hrtFrameWrite.deviceType = hrtStorage.getVariable('device_type')!;
      _hrtFrameWrite.deviceId = hrtStorage.getVariable('device_id')!;
    } else {
      _hrtFrameWrite.pollingAddress = hrtStorage.getVariable('polling_address')!;
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
        _hrtFrameWrite.body = "00" //error_code
            "FE"
            "${hrtStorage.getVariable('master_address')! & hrtStorage.getVariable('manufacturer_id')!}"
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
        _hrtFrameWrite.body = "00" //error_code
            "${hrtStorage.getVariable('unit_code')}"
            "${hrtStorage.getVariable('PROCESS_VARIABLE')}";
        break;
      case '02': //Read Loop Current And Percent Of Range
        _hrtFrameWrite.body = "00" //error_code
            "${hrtStorage.getVariable('loop_current')}"
            "${hrtStorage.getVariable('percent_of_range')}";
        break;
      case '03': //Read Dynamic Variables And Loop Current
        _hrtFrameWrite.body = "00" //error_code
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
      case '06': //Write Polling Address
        final pollingAddress = hrtFrameRead.body.substring(0, 2);
        final loopCurrentMode = hrtFrameRead.body.substring(2);
        hrtStorage.setVariable('polling_address', pollingAddress);
        hrtStorage.setVariable('loop_current_mode', loopCurrentMode);
        _hrtFrameWrite.body = "00" //error_code
            "$pollingAddress"
            "$loopCurrentMode";
        break;
      case '07': //Read Loop Configuration
        _hrtFrameWrite.body = "00" //error_code
            "${hrtStorage.getVariable('polling_address')}"
            "${hrtStorage.getVariable('loop_current_mode')}";
        break;
      case '08': //Read Dynamic Variable Classifications
        _hrtFrameWrite.body = "00" //error_code
            "${hrtStorage.getVariable('primary_variable_classification')}"
            "${hrtStorage.getVariable('secondary_variable_classification')}"
            "${hrtStorage.getVariable('tertiary_variable_classification')}"
            "${hrtStorage.getVariable('quaternary_variable_classification')}";
        break;
      case '09': //Read Device Variables with Status
        _hrtFrameWrite.body = "";
        break;
      case '11': //Read Unique Identifier Associated With Tag
        _hrtFrameWrite.body =
            "${(hrtFrameRead.body == hrtStorage.getVariable('tag')) ? '00' : '01'}" //error_code 00 - ok | 01 - undefined
            "FE"
            "${hrtStorage.getVariable('master_slave')! & hrtStorage.getVariable('manufacturer_id')!}"
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
        _hrtFrameWrite.body = "00" //error_code
            "${hrtStorage.getVariable('Message')}";
        break;
      case '0D': //Read Tag, Descriptor, Date (13)
        _hrtFrameWrite.body = "00" //error_code
            "${hrtStorage.getVariable('tag')}"
            "${hrtStorage.getVariable('descriptor')}"
            "${hrtStorage.getVariable('date')}";
        break;
      case '21': //Read Device Variables (33)
        _hrtFrameWrite.body = switch (hrtFrameRead.body) {
          '00' => '08 00 00 00 27 40 EE 2D 42',
          '01' => '08 00 00 01 39 41 AC 26 AA',
          '02' => '08 00 00 02 20 41 CF 95 40',
          '03' => '08 00 00 03 20 41 C8 D9 90',
          '04' => '08 00 00 04 39 41 AC 26 21',
          '05' => '08 00 00 05 39 00 00 00 00',
          '0C' => '08 00 00 0C 33 3F 80 00 00',
          '19' => '08 00 40 19 00 42 DD 26 1B',
          _ => '08 00 00 00 00 7F A0 00 00',
        };
    }
  }
}
