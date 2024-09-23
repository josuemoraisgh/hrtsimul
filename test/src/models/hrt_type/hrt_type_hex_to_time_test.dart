import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve dar 1900-01-01 00:23:18.526 quando valor em Hex for 02AADFC0', () {
    final valor = DateTime.parse('1900-01-01 00:23:18.526');
    expect(hrtTypeHexTo('02AADFC0','Time'), valor);
  });
}