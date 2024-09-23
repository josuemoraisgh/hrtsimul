import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve dar ABACATE quando valor em hex for 0010810C1505', () {
    const valorHex = '0010810C1505';
    expect(hrtTypeHexTo(valorHex,'PAscii'), 'ABACATE');
  });
}