import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TransferFunction extends Disposable {
  ReceivePort? _receivePort;
  Isolate? _isolate;
  Stream? receiveStream;
  SendPort? _sendPort;

  final List<double> numerator; // Coeficientes do numerador
  final List<double> denominator; // Coeficientes do denominador
  final Duration samplingTime; // Tempo de amostragem

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
    var continuousModel = _transferFunctionToStateSpace(numerator, denominator);
    double Ts =
        samplingTime.inMilliseconds / 1000.0; // Convertendo para segundos

    // Obter a matriz A discreta como e^(A * Ts)
    List<List<double>> Ad = _matrixExponential(continuousModel['A']!, Ts);

    List<List<double>> I = List.generate(order, (i) => List.filled(order, 0.0));
    for (int i = 0; i < order; i++) {
      I[i][i] = 1.0;
    }

    List<List<double>> AdMinusI =
        _matrixAdd(Ad, _matrixScalarMultiply(I, -1.0));
    List<List<double>> AInv = _matrixInverse1x1(continuousModel['A']!);
    List<List<double>> Bd =
        _matrixMultiply(_matrixMultiply(AInv, AdMinusI), continuousModel['B']!);

    discreteA = Ad;
    discreteB = Bd;
    C = continuousModel['C']!;
    D = continuousModel['D']!;
  }

  start() => _sendPort?.send({'mode': 'start'});

  stop() => _sendPort?.send({'mode': 'stop'});

  close() {
    _sendPort?.send({'mode': 'close'});
    _receivePort?.close(); // Fecha o ReceivePort ao encerrar o widget
    _isolate?.kill(priority: Isolate.immediate);
  }

  reestart() => _sendPort?.send(
      {'mode': 'setState', 'state': List.filled(denominator.length - 1, 0.0)});

  setInputValue(double input) =>
      _sendPort?.send({'mode': 'input', 'input': input});

  // Função para iniciar a simulação usando uma Isolate
  Future<void> createIsolate(ValueNotifier<double> plantOutputValue) async {
    _receivePort = ReceivePort();
    receiveStream = _receivePort!.asBroadcastStream();
    // Iniciar a Isolate
    _isolate = await Isolate.spawn(_simulationIsolate, _receivePort!.sendPort);
    // Completer para obter o SendPort da Isolate
    Completer<SendPort> completer = Completer();
    // Ouve as mensagens da Isolate
    _receivePort!.listen((message) {
      if (message is SendPort && !completer.isCompleted) {
        _sendPort = message; // Recebe o SendPort da Isolate
        completer.complete(_sendPort);
        // Envia os dados iniciais para a Isolate
        _sendPort?.send({
          'mode': 'init',
          'discreteA': discreteA,
          'discreteB': discreteB,
          'C': C,
          'D': D,
          'state': state,
          'samplingTime': samplingTime.inMilliseconds,
        });
      } else if (message is Map) {
        state = message['state'];
        plantOutputValue.value = message['output'];
      }
    });
    // Aguarda até obter o SendPort da Isolate
    await completer.future;
  }

  // Função executada dentro da Isolate
  static void _simulationIsolate(SendPort isolateSendPort) {
    // Cria um ReceivePort para receber mensagens da thread principal
    ReceivePort isolateReceivePort = ReceivePort();
    // Envia o SendPort de volta para a thread principal
    isolateSendPort.send(isolateReceivePort.sendPort);

    Timer? timer;
    var input = ValueNotifier<double>(0.0);
    List<List<double>>? discreteA;
    List<List<double>>? discreteB;
    List<List<double>>? C;
    List<List<double>>? D;
    List<double>? state;
    int? samplingTime;
    ;

    isolateReceivePort.listen((message) {
      if (message['mode'] == 'stop') {
        timer?.cancel();
      } else if (message['mode'] == 'close') {
        timer?.cancel();
        isolateReceivePort.close();
      } else if (message['mode'] == 'setState') {
        state = List.from(message['state']);
      } else if (message['mode'] == 'init') {
        // Inicializa os dados recebidos
        discreteA = message['discreteA'];
        discreteB = message['discreteB'];
        C = message['C'];
        D = message['D'];
        state = List.from(message['state']);
        samplingTime = message['samplingTime'];
      } else if (message['mode'] == 'input') {
        input.value = message['input'];
      } else if (message['mode'] == 'start') {
        // Inicia o Timer.periodic dentro da Isolate
        timer = Timer.periodic(Duration(milliseconds: samplingTime!), (timer) {
          // Simulação com entrada zero (pode ser adaptado para receber entrada)
          int order = discreteA!.length;
          // Atualizar o vetor de estado
          List<double> nextState = List.filled(order, 0.0);
          for (int i = 0; i < order; i++) {
            double sumA = 0.0;
            for (int j = 0; j < order; j++) {
              sumA += discreteA![i][j] * state![j];
            }
            double sumB = discreteB![i][0] * input.value;
            nextState[i] = sumA + sumB;
          }

          // Calcular a saída do sistema
          double output = 0.0;
          for (int i = 0; i < C![0].length; i++) {
            output += C![0][i] * nextState[i];
          }
          output += D![0][0] * input.value;

          // Enviar o novo estado e a saída de volta para a thread principal
          isolateSendPort.send({'state': nextState, 'output': output});

          // Atualizar o estado
          state = nextState;
        });
      }
    });
  }

  // As funções auxiliares continuam as mesmas
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

    List<List<double>> currentPower = A.map((row) => row.toList()).toList();
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

  @override
  void dispose() {
    _receivePort?.close(); // Fecha o ReceivePort ao encerrar o widget
    _isolate?.kill(priority: Isolate.immediate);
  }
}
