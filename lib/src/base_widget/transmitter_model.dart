import 'package:flutter/material.dart';

import '../models/hrt_transmitter.dart';

class TransmitterModel {
  final HrtTransmitter hrtTransmitter;
  String func;
  final funcValueNotifier = ValueNotifier<double>(0.0);

  TransmitterModel(this.hrtTransmitter, this.func) {
    updateFunc();
  }

  updateFunc() {
    funcValueNotifier.value = hrtTransmitter.getTransmitterValue(func) ?? 0.0;
  }

  set Value(double? fv) {
    funcValueNotifier.value = fv ?? 0.0;
  }

  double get Value => funcValueNotifier.value;
}
