import 'package:flutter/material.dart';
import '../models/hrt_transmitter.dart';

class HrtVariableModel {
  final HrtTransmitter hrtTransmitter;
  final String name; // Especificando o tipo
  final _funcValue = ValueNotifier<double>(0.0);
  final _func = ValueNotifier<String>("");

  HrtVariableModel(this.hrtTransmitter, this.name, func) {
    _func.value = func;
    updateFunc();
  }

  // Atualizar o valor de _value e notificar os listeners
  void updateFunc({double? value}) {
    if (value == null)
      _funcValue.value =
          hrtTransmitter.getTransmitterValue(name, _func.value) ?? 0.0;
    else
      _funcValue.value = value;
  }

  // Getter para acessar o valor de _value
  double get funcValue {
    return _funcValue.value;
  }

  set func(String fnc) {
    _func.value = fnc;
  }
}
