import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve dar erro quando valor em hex for vazio', () {
    const String valorHex = '';
    expect(
        () => hrtTypeHexTo(valorHex,'Int'), throwsA(const TypeMatcher<ArgumentError>()));
  });

  test('Deve dar erro quando valor em hex for maior que 4 caracteres', () {
    const String valorHex = '00FFF';
    expect(
        () => hrtTypeHexTo(valorHex,'Int'), throwsA(const TypeMatcher<ArgumentError>()));
  });

  test('Deve dar erro quando valor em hex receber caracteres que não são hex',
      () {
    const String valorHex = 'AZF';
    expect(
        () => hrtTypeHexTo(valorHex,'Int'), throwsA(const TypeMatcher<ArgumentError>()));
  });

  test('Deve calcular para 00FF o valor 255', () {
    const String valorHex = '00FF';
    expect(hrtTypeHexTo(valorHex,'Int'), 255);
  });
  test('Deve calcular para 80FF o valor -32513', () {
    const String valorHex = '80FF';
    expect(hrtTypeHexTo(valorHex,'Int'), -32513);
  });
  test('Deve calcular para 0BCD o valor 3021', () {
    const String valorHex = '0BCD';
    expect(hrtTypeHexTo(valorHex,'Int'), 3021);
  });
}
