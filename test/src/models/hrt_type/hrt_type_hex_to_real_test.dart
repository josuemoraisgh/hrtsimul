import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve calcular para 3FBE3A80 o valor 1.4861602783203125', () {
    const String valorHex = '3FBE3A80';
    expect(hrtTypeHexTo(valorHex,'SReal'), 1.4861602783203125);
  });
}