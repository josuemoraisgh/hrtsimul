import 'package:flutter/material.dart';
import '../models/hrt_transmitter.dart';

class HrtVariableModel extends ChangeNotifier {
  final HrtTransmitter hrtTransmitter;
  final String name; // Especificando o tipo
  double _value = 0.0;
  String func; // Especificando o tipo

  HrtVariableModel(this.hrtTransmitter, this.name, this.func) {
    updateFunc();
  }

  // Atualizar o valor de _value e notificar os listeners
  void updateFunc({double? value}) {
    if(value == null) _value = hrtTransmitter.getTransmitterValue(name, func) ?? 0.0;
    else _value = value;
    notifyListeners();
  }

  // Getter para acessar o valor de _value
  double get funcValue {
    return _value;
  }
}
