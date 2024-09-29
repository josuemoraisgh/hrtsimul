import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TransferFunction {
  final List<double> numerator; // Coeficientes do numerador
  final List<double> denominator; // Coeficientes do denominador
  final Duration samplingTime; // Tempo de amostragem

  var isStop = ValueNotifier<bool>(false);

  List<List<double>> discreteA = [];
  List<List<double>> discreteB = [];
  List<List<double>> C = [];
  List<List<double>> D = [];
  List<double> state; // Vetor de estados
  int order;

  TransferFunction(this.numerator, this.denominator, this.samplingTime)
      : order = denominator.length - 1,
        state = List.filled(denominator.length - 1, 0.0) {
    _discretize();
  }

  // Discretização usando a Transformada Bilinear (Tustin) para espaço de estado
  void _discretize() {
    // Converter a função de transferência para espaço de estado
    var continuousModel = _transferFunctionToStateSpace(numerator, denominator);
    double Ts =
        samplingTime.inMilliseconds / 1000.0; // Convertendo para segundos

    // Obter a matriz A discreta como e^(A * Ts)
    List<List<double>> Ad = _matrixExponential(continuousModel['A']!, Ts);

    // Calcular Bd usando a relação B_d = A^-1 * (A_d - I) * B
    List<List<double>> I = List.generate(order, (i) => List.filled(order, 0.0));
    for (int i = 0; i < order; i++) {
      I[i][i] = 1.0;
    }

    List<List<double>> AdMinusI =
        _matrixAdd(Ad, _matrixScalarMultiply(I, -1.0));
    List<List<double>> AInv = _matrixInverse1x1(continuousModel['A']!);
    List<List<double>> Bd =
        _matrixMultiply(_matrixMultiply(AInv, AdMinusI), continuousModel['B']!);

    // Atribuindo valores às matrizes discretas
    discreteA = Ad;
    discreteB = Bd;
    C = continuousModel['C']!;
    D = continuousModel['D']!;
  }

  // Função para parar a simulação
  void stop() {
    isStop.value = true;
  }

  // Simulação do sistema com entrada personalizada
  void start(ValueNotifier<double> input, void Function(double) outputFunc) {
    Timer.periodic(samplingTime, (timer) {
      if (isStop.value) {
        isStop.value = false;
        timer.cancel();
        return;
      }

      // Atualizar o vetor de estado
      List<double> nextState = List.filled(order, 0.0);
      for (int i = 0; i < order; i++) {
        double sumA = 0.0;
        for (int j = 0; j < order; j++) {
          sumA += discreteA[i][j] * state[j];
        }
        double sumB = discreteB[i][0] * input.value;
        nextState[i] = sumA + sumB;
      }

      // Atualizar o vetor de estado
      state = nextState;

      // Calcular a saída do sistema
      double _output = 0.0;
      for (int i = 0; i < C[0].length; i++) {
        _output += C[0][i] * state[i];
      }
      _output += D[0][0] * input.value;

      // Atualizar o valor da saída
      outputFunc(_output);     
    });
  }

  // Função para converter a função de transferência em espaço de estado
  Map<String, List<List<double>>> _transferFunctionToStateSpace(
      List<double> numerator, List<double> denominator) {
    int order = denominator.length - 1; // Ordem do sistema

    // Normalizar os coeficientes do numerador e denominador
    double a0 = denominator[0];
    numerator = numerator.map((c) => c / a0).toList();
    denominator = denominator.map((c) => c / a0).toList();

    // Matriz A (ordem x ordem)
    List<List<double>> A = List.generate(order, (i) => List.filled(order, 0.0));
    for (int i = 0; i < order - 1; i++) {
      A[i][i + 1] = 1.0;
    }
    for (int i = 0; i < order; i++) {
      A[order - 1][i] = -denominator[i + 1];
    }

    // Matriz B (ordem x 1)
    List<List<double>> B = List.generate(order, (i) => [0.0]);
    B[order - 1][0] = 1.0;

    // Matriz C (1 x ordem)
    List<List<double>> C = [List.filled(order, 0.0)];
    C[0][order - 1] = 1.0;

    // Matriz D (1 x 1)
    List<List<double>> D = [
      [0.0]
    ];

    return {'A': A, 'B': B, 'C': C, 'D': D};
  }

  // Função para calcular a exponencial de uma matriz (aproximação de e^(A * Ts))
  List<List<double>> _matrixExponential(List<List<double>> A, double Ts) {
    int n = A.length;
    List<List<double>> result = List.generate(n, (i) => List.filled(n, 0.0));

    // Inicializar result como matriz identidade
    for (int i = 0; i < n; i++) {
      result[i][i] = 1.0;
    }

    List<List<double>> currentPower = List.from(A);
    double factorial = 1.0;

    // Aproximar e^(A * Ts) usando série de Taylor
    for (int k = 1; k < 20; k++) {
      factorial *= k;
      List<List<double>> term =
          _matrixScalarMultiply(currentPower, pow(Ts, k) / factorial);
      result = _matrixAdd(result, term);
      currentPower = _matrixMultiply(currentPower, A);
    }

    return result;
  }

  // Função para calcular a inversa de uma matriz 1x1
  List<List<double>> _matrixInverse1x1(List<List<double>> A) {
    if (A.length == 1 && A[0].length == 1) {
      return [
        [1.0 / A[0][0]]
      ];
    } else {
      throw ArgumentError(
          "A matriz não é 1x1, não pode calcular a inversa usando esta função.");
    }
  }

  // Funções auxiliares para operações de matrizes
  List<List<double>> _matrixMultiply(
      List<List<double>> A, List<List<double>> B) {
    int rowsA = A.length;
    int colsA = A[0].length;
    int colsB = B[0].length;

    List<List<double>> result =
        List.generate(rowsA, (i) => List.filled(colsB, 0.0));

    for (int i = 0; i < rowsA; i++) {
      for (int j = 0; j < colsB; j++) {
        for (int k = 0; k < colsA; k++) {
          result[i][j] += A[i][k] * B[k][j];
        }
      }
    }

    return result;
  }

  List<List<double>> _matrixAdd(List<List<double>> A, List<List<double>> B) {
    int rows = A.length;
    int cols = A[0].length;

    List<List<double>> result =
        List.generate(rows, (i) => List.filled(cols, 0.0));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result[i][j] = A[i][j] + B[i][j];
      }
    }

    return result;
  }

  List<List<double>> _matrixScalarMultiply(
      List<List<double>> A, double scalar) {
    int rows = A.length;
    int cols = A[0].length;

    List<List<double>> result =
        List.generate(rows, (i) => List.filled(cols, 0.0));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result[i][j] = A[i][j] * scalar;
      }
    }

    return result;
  }
}
