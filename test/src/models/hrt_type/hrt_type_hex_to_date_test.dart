import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve calcular para 12/03/2024 o valor 0C037C', () {
    const valorHex = '0C037C';
    expect(hrtTypeHexTo(valorHex,'Date'), DateTime(2024,3,12));
  });
}