import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hrtsimul/src/models/simul_transfer_function.dart';

Future<void> main() async {
  // Definindo um sistema de transferência de até segunda ordem
  const List<double> numeratorTF = [1.0]; // Coeficientes do numerador
  const List<double> denominatorTF = [1.0, 1.0]; // Coeficientes do denominador
  const samplingTime = Duration(milliseconds: 100); // Tempo de amostragem

  final plantInputValue = ValueNotifier<double>(100.0); // Entrada inicial
  final plantOutputValue = ValueNotifier<double>(0.0); // Saída inicial

  final transferFunction = TransferFunction(numeratorTF, denominatorTF, samplingTime);

  // Iniciar a simulação
  transferFunction.start(plantInputValue, plantOutputValue);

  await Future.delayed(Duration(seconds: 10)); // Dura 10 segundos antes de parar
  transferFunction.stop(); // Parar a simulação após 10 segundos
}