import 'package:flutter/material.dart';

import '../models/hrt_transmitter.dart';

class HrtVariableModel {
  final HrtTransmitter hrtTransmitter;
  String func;
  final funcValueNotifier = ValueNotifier<double>(0.0);

  HrtVariableModel(this.hrtTransmitter, this.func) {
    updateFunc();
  }

  updateFunc() {
    funcValueNotifier.value = hrtTransmitter.getTransmitterValue(func) ?? 0.0;
  }

  // set value(double? fv) {
  //   func_value_notifier.value = fv ?? 0.0;
  // }

  double get Value => funcValueNotifier.value;
}
