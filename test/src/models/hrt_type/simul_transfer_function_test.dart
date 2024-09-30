import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:hrtsimul/src/models/simul_transfer_function.dart';

void main() async {
  // Definir os coeficientes do numerador e denominador da função de transferência
  double input = 1.0;
  List<double> numerator = [
    1.0
  ]; // Exemplo: Numerador de um sistema de primeira ordem
  List<double> denominator = [1.0, 1.0]; // Exemplo: Denominador
  final plantOutputValue = ValueNotifier<double>(0.0);
  // Criar uma instância da classe TransferFunction
  Duration samplingTime =
      Duration(milliseconds: 100); // Tempo de amostragem de 100 ms
  TransferFunction tf = TransferFunction(numerator, denominator, samplingTime);

  // Iniciar a simulação e obter o ReceivePort para os outputs
  await tf.createIsolate(plantOutputValue);
  //SendPort sendPort;

  // Ouvir os outputs da simulação
  tf.receiveStream?.listen((message) {
    if (message is SendPort) {
      // Receber o SendPort da Isolate
      //sendPort = message;
      message.send({'input': input});
    } else if (message is Map && message.containsKey('output')) {
      double output = message['output'];
      print('Saída do sistema: $output');
    }
  });
  // Executar a simulação por um tempo e depois parar
  await Future.delayed(Duration(seconds: 5));
  // Aqui você pode adicionar código para enviar uma mensagem de parada para a Isolate, se necessário
}
