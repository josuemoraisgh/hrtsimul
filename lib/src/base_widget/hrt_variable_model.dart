import 'package:flutter/material.dart';

import '../models/hrt_transmitter.dart';

class HrtVariableModel extends ValueNotifier<double> {
  final HrtTransmitter hrtTransmitter;
  String func;

  HrtVariableModel(this.hrtTransmitter, this.func) : super(0.0) { 
    updateFunc();
  }

  updateFunc() {
    value = hrtTransmitter.getTransmitterValue(func) ?? 0.0; 
  }

  double get funcValue => value;
}
