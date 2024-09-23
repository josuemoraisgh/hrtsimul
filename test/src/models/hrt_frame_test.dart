import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_frame.dart';

void main() {
  //For a long Frame 3 bytes
  test('O frame "FFF0A3EAF3DCAB970100AB" esta correto', () {
    final frame = HrtFrame("FFF0A3EAF3DCAB970100AB");
    expect(frame.log, "");
    expect(frame.preamble, 'FF');
    expect(frame.delimiter, 'F0');
    expect(frame.addressType, true);
    expect(frame.manufacterId, 'A3');
    expect(frame.deviceType, 'EA');
    expect(frame.address, 'F3DCAB');
    expect(frame.command, '97');
    expect(frame.nBBody, 1);
    expect(frame.body, '00');
    expect(frame.checkSum, 'AB');
  });
  //For a short Frame 1 byte
  test('O frame "FF40A3CD0100AF" esta errado apenas o CheckSum', () {
    final frame = HrtFrame("FF40A3CD0100AF");
    expect(frame.log, "Incorrect CheckSum");
    expect(frame.preamble, 'FF');
    expect(frame.delimiter, '40');
    expect(frame.addressType, false);
    expect(frame.manufacterId, '');
    expect(frame.deviceType, '');
    expect(frame.address, 'A3');
    expect(frame.command, 'CD');
    expect(frame.nBBody, 1);
    expect(frame.body, '00');
    expect(frame.checkSum, 'AF');
  });

  test('O frame "40A3CD0100AF" esta errado falta preamble', () {
    final frame = HrtFrame("40A3CD0100AF");
    expect(frame.log, "Don't find Preamble in Frame");
    expect(frame.preamble, '');
    expect(frame.delimiter, '');
    expect(frame.addressType, false);
    expect(frame.manufacterId, '');
    expect(frame.deviceType, '');
    expect(frame.address, '');
    expect(frame.command, '');
    expect(frame.nBBody, 0);
    expect(frame.body, '');
    expect(frame.checkSum, '');
  });
}
