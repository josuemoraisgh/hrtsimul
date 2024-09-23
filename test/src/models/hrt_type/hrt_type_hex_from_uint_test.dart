import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve dar erro quando valor em int for maior 65535', () {
    const int valorInt = 65536;
    expect(() => hrtTypeHexFrom(valorInt,'UInt'), throwsA(const TypeMatcher<ArgumentError>()));
  });

  test('Deve calcular para 255 o valor 00FF', () {
    const int valorInt = 255;
    expect(hrtTypeHexFrom(valorInt,'UInt'), '00FF');
  });
}
