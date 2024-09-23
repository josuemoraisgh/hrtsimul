import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {

  test('Deve calcular para 1.4861602783203125 o valor 3fbe3a80', () {
    const double valorHex = 1.4861602783203125;
    expect(hrtTypeHexFrom(valorHex,'SReal'), '3fbe3a80');
  });
}
