import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_comm.dart';


void main() {
  test('Write Frame in COM3 and read the same data in COM4', () {
    final hrtComm0 = HrtComm('COM3');
    final hrtComm1 = HrtComm('COM4');
    expect(hrtComm0.writeFrame('FFF0A3EAF3DCAB970100AB'), true);
    expect(hrtComm1.readFrame(), 'FFF0A3EAF3DCAB970100AB');
    hrtComm0.disconnect();
    hrtComm1.disconnect();
  });

  test('Write in COM3 and read and write in COM4 and read in COM3', () {
    final hrtComm0 = HrtComm('COM3');
    final hrtComm1 = HrtComm('COM4');
    expect(hrtComm0.writeFrame('FFF0A3EAF3DCAB970100AB'), true);
    hrtComm1.writeFrame(hrtComm1.readFrame());
    expect(hrtComm0.readFrame(), 'FFF0A3EAF3DCAB970100AB');
    hrtComm0.disconnect();
    hrtComm1.disconnect();
  });

  test('Write in COM3 and read and write in COM4 and read in COM3 new',
      () async {
    final hrtComm0 = HrtComm('COM3');
    final hrtComm1 = HrtComm();
    hrtComm1.connect('COM4', hrtComm1.writeFrame);
    expect(hrtComm0.writeFrame('FFF0A3EAF3DCAB970100AB'), true);
    await Future.delayed(const Duration(seconds: 1)).then((value) {
      final aux = hrtComm0.readFrame();
      expect(aux, 'FFF0A3EAF3DCAB970100AB');
    });
    hrtComm0.disconnect();
    hrtComm1.disconnect();
  });
}
