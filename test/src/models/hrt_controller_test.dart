import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/extension/bit_field_int.dart';
import 'package:hrtsimul/src/extension/hex_extension_string.dart';

void main() {
  test('Test 01', () {
    final sp = SerialPort("COM3");
    final reader = SerialPortReader(sp);
    sp.openReadWrite();
    reader.stream.listen(
      (Uint8List data) {
        final aux = data
            .map((e) => e.toRadixString(16).padLeft(2, '0'))
            .join()
            .toUpperCase()
            .splitByLength(2)
            .join(" ");
        if (kDebugMode) {
          print(aux);
        }
      },
    );
    final value = 0
        .setBits(7, 1, 0)
        .setBits(6, 1, 0)
        .setBits(0, 6, int.parse("02", radix: 16))
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, '0');
    final resp = Uint8List.fromList('FFFFFFFFFF${value}80000082'
        .splitByLength(2)
        .map((e) => int.parse(e, radix: 16))
        .toList());
    expect(sp.write(resp, timeout: 0), 10);
    reader.close();
    sp.close();
  });
  /*test('Test 01', () {
    final hrtComm = HrtComm();
    hrtComm.port = "COM3";
    hrtComm.funcRead = (String data) {
      final hrtResponse = HrtFrame(data);
      final aux = '${hrtResponse.frame.splitByLength(2).join(" ")}\n';
      if (kDebugMode) {
        print(aux);
      }
    };
    expect(hrtComm.connect(), true);
    final value = 0
        .setBits(7, 1, 1)
        .setBits(6, 1, 1)
        .setBits(0, 6, int.parse('02', radix: 16))
        .toRadixString(16)
        .padLeft(2, '0');
    //expect(hrtComm.writeFrame(value), true);
    expect(hrtComm.writeFrame('FFFFFFFFFF0280000082'), true);
    Future.delayed(const Duration(seconds: 2)).then((value) {
      //final aux1 = hrtComm0.readFrame();
      //expect(aux1, 'FFFFFFFFFF0680000E0000FE3E02050504300100001E6607');
    });
    hrtComm.disconnect();
  });
*/
  /*  test('Test 01', () async {
    Hive.init("C:\\SourceCode\\");
    final controller = HomeController(HrtComm());    
    await controller.completer.future;
    controller.hrtComm.port = "COM3";
    controller.hrtComm.funcRead = (String data) {
      final hrtResponse = HrtFrame(data);
      final aux = '${hrtResponse.frame.splitByLength(2).join(" ")}\n';
      if (kDebugMode) {
        print(aux);
      }
    };
    final hrtFrameRead = HrtFrame()..command = "00";
    final hrtRequest = HrtBuild(controller.hrtStorage, hrtFrameRead);
    final valueAux = hrtRequest.frame;    
    expect(controller.hrtComm.connect(), true);    
    expect(controller.hrtComm.writeFrame(valueAux), true);
    //expect(controller.hrtComm.writeFrame('FFFFFFFFFF0280000082'), true);
    Future.delayed(const Duration(seconds: 2)).then((value) {
      //final aux1 = hrtComm0.readFrame();
      //expect(aux1, 'FFFFFFFFFF0680000E0000FE3E02050504300100001E6607');
    });
    controller.hrtComm.disconnect();
  });*/
}
