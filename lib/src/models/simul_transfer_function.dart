import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class TransferFunction {
  final List<double> numerator;
  final List<double> denominator;
  final ({
    int seconds,
    int milliseconds,
    int microseconds
  }) samplingTime; //Tempo

  var isStop = ValueNotifier<bool>(false);

  List<double> discreteNumerator = [];
  List<double> discreteDenominator = [];
  List<double> inputHistory = [];
  List<double> outputHistory = [];

  TransferFunction(this.numerator, this.denominator, this.samplingTime) {
    _discretize();
    _initializeHistories();
  }

  // Discretização usando Tustin para sistemas de ordem arbitrária
  void _discretize() {
    int numOrder = numerator.length - 1;
    int denOrder = denominator.length - 1;
    double _samplingTime = samplingTime.seconds +
        samplingTime.milliseconds * 1000 +
        samplingTime.microseconds * 1000000;
    // Discretizar os coeficientes de acordo com a Transformada Bilinear
    discreteNumerator = List.filled(numOrder + 1, 0);
    discreteDenominator = List.filled(denOrder + 1, 0);

    for (int i = 0; i <= numOrder; i++) {
      discreteNumerator[i] = numerator[i] * (2 / _samplingTime);
    }

    for (int i = 0; i <= denOrder; i++) {
      discreteDenominator[i] = denominator[i] * (2 / _samplingTime);
    }

    // Normalizar pelo primeiro coeficiente do denominador
    double den0 = discreteDenominator[0];
    for (int i = 0; i <= numOrder; i++) {
      discreteNumerator[i] /= den0;
    }
    for (int i = 0; i <= denOrder; i++) {
      discreteDenominator[i] /= den0;
    }

    print('Discretized Numerator: $discreteNumerator');
    print('Discretized Denominator: $discreteDenominator');
  }

  // Inicializar o histórico de entradas e saídas baseado na ordem do sistema
  void _initializeHistories() {
    int maxOrder = max(discreteNumerator.length, discreteDenominator.length);

    // Inicializar com zeros
    inputHistory = List.filled(maxOrder, 0, growable: true);
    outputHistory = List.filled(maxOrder, 0, growable: true);
  }

  void stop() {}

  // Simulação do sistema com entrada personalizada para sistemas de ordem arbitrária
  void start(
    final ValueNotifier<double> input,
    final ValueNotifier<double> output,
  ) {
    Timer.periodic(
        Duration(
            seconds: samplingTime.seconds,
            milliseconds: samplingTime.milliseconds,
            microseconds: samplingTime.microseconds), (timer) {
      if (isStop.value) {
        timer.cancel();
        return;
      }

      // Atualizar o histórico de entradas
      inputHistory.insert(0, input.value);
      inputHistory.removeLast();

      // Calcular a saída usando a equação das diferenças generalizada
      double _output = 0.0;

      // Parte relacionada aos coeficientes do numerador (entrada)
      for (int i = 0; i < discreteNumerator.length; i++) {
        _output += discreteNumerator[i] * inputHistory[i];
      }

      // Parte relacionada aos coeficientes do denominador (saída anterior)
      for (int i = 1; i < discreteDenominator.length; i++) {
        _output -= discreteDenominator[i] * outputHistory[i - 1];
      }

      // Atualizar o histórico de saídas
      outputHistory.insert(0, _output);
      outputHistory.removeLast();

      // Chama a função de atualização com o tempo e a saída atual
      output.value = _output;
    });
  }
}
