import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_comm.dart';
import 'package:hrtsimul/src/models/hrt_settings.dart';
import 'package:hrtsimul/src/models/hrt_storage.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  test("Correto", () async {
    Hive.init('C:');
    final hrtStorage = HrtStorage();
    const value =
        '@100 * (PROCESS_VARIABLE - lower_range_value) / (upper_range_value - lower_range_value)';
    final iReg = RegExp(r'[A-Z_a-z]+');
    final matches = iReg.allMatches(value);
    Map<String, double> context = {};
    for (var e in matches) {
      if (e.group(0) != null) {
        final variableHex = hrtStorage.getVariable(e.group(0)!);
        context[e.group(0)!] =
            hrtTypeHexTo(variableHex, hrtSettings[e.group(0)!]!.$2);
      }
    }
    Expression expression = Expression.parse(value.substring(1));
    const evaluator = ExpressionEvaluator();
    var r = (evaluator.eval(expression, context) as double);
    if (kDebugMode) {
      print(r.toInt().toRadixString(16));
    }
  });
}
