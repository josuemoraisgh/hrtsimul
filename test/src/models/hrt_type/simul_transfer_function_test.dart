import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/simul_transfer_function.dart';

void main() async {
  const listResult = [
    0.10000001937626736,
    0.200000038738249,
    0.30000005808594493,
    0.4000000774193551,
    0.5000000967384796,
    0.6000001160433183,
    0.7000001353338713,
    0.8000001546101386,
    0.9000001738721202,
    1.0000001931198161,
    1.1000002123532262,
    1.2000002315723506,
    1.3000002507771893,
    1.4000002699677423
  ];
  int count = 0;
  // Definindo um sistema de transferência de primeira ordem
  const List<double> numeratorTF = [1.0]; // Coeficientes do numerador
  const List<double> denominatorTF = [
    0.07,
    0.0000000001
  ]; // Coeficientes do denominador
  const samplingTime = Duration(milliseconds: 100); // Tempo de amostragem

  final plantInputValue =
      ValueNotifier<double>(1.0); // Entrada inicial constante

  // Criar o sistema de função de transferência
  final transferFunction =
      TransferFunction(numeratorTF, denominatorTF, samplingTime);

  // Iniciar a simulação
  // transferFunction.start(plantInputValue, (double value) {
  //   test('Testa os valores da planta', () {
  //     expect(value, listResult[count]);
  //     if (++count == listResult.length) transferFunction.stop();
  //   });
  // });

  // Parar a simulação após 10 segundos
  await Future.delayed(Duration(seconds: 10));
  transferFunction.stop();
}
