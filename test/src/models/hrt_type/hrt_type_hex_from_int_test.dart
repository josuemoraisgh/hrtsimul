import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve dar erro quando valor em int for maior 65535', () {
    const int valorInt = 65536;
    expect(() => hrtTypeHexFrom(valorInt,'Int'), throwsA(const TypeMatcher<ArgumentError>()));
  });

  test('Deve calcular para -32513 o valor 80ff', () {
    const int valorInt = -32513;
    expect(hrtTypeHexFrom(valorInt,'Int'), '80ff');
  });
}
