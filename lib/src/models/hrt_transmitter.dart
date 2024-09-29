import 'dart:async';
import 'dart:math';

import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:hrtsimul/src/base_widget/transmitter_model.dart';
import 'hrt_storage.dart';
import 'hrt_type.dart';

class HrtTransmitter extends HrtStorage {
  final evaluator = const ExpressionEvaluator();
  final funcNotifier = ValueNotifier<Map<String, TransmitterModel>>({});

  double inputValue = 0.0;
  double rampValue = 0.0;
  double randomValue = 0.0;

  HrtTransmitter(super.selectedInstrument) {}

  Future<bool> init() async {
    var resp = await super.init();
    for (var variableName in keys()) {
      var func = getVariable(variableName) ?? "";
      if (func.substring(0, 1) == '@') {
        funcNotifier.value.addAll({variableName: TransmitterModel(this, func)});
      }
    }
    return resp;
  }

  void updateInputValue(double inpValue) {
    inputValue = inpValue;
    rampValue = rampValue > 1.0 ? 0.0 : rampValue + 0.01;
    randomValue = Random().nextDouble();
    for (var entrie in funcNotifier.value.entries) {
      funcNotifier.value[entrie.key]?.updateFunc();
    }
  }

  void insertFuncNotifier(String variableName, String func) {
    if (funcNotifier.value.containsKey(variableName))
      funcNotifier.value[variableName]?.updateFunc();
    else
      funcNotifier.value.addAll({variableName: TransmitterModel(this, func)});
  }

  bool deleteFuncNotifier(String key) {
    return funcNotifier.value.remove(key) == null ? false : true;
  }

  double? getTransmitterValue(String name, {bool isSubFunc = false}) {
    final String? func = super.getVariable(name);
    final resp = switch (name) {
      '@input_value' || 'input_value' => inputValue,
      '@ramp_value' || 'ramp_value' => rampValue,
      '@ramdom_value' || 'ramdom_value' => randomValue,
      _ => func == null
          ? null
          : switch (func.substring(0, 1)) {
              '@' => isSubFunc
                  ? funcNotifier.value[name]?.Value ?? 0.0
                  : hrtFunc2Double(func),
              _ => hrtTypeHexTo(func, 'FLOAT'),
            },
    };
    return resp;
  }

  double? hrtFunc2Double(String func) {
    //RegExp(r'(#\b\w+\b)|(\b\w+\b)'); // Regex para capturar palavras
    final iReg = RegExp(r'[A-Z_a-z]+');
    final matches = iReg.allMatches(func);
    Map<String, double?> context = {};
    for (var e in matches) {
      if (e.group(0) != null) {
        // variableName != null
        context[e.group(0)!] =
            getTransmitterValue(e.group(0)!, isSubFunc: true);
      }
    }
    Expression expression = Expression.parse((func.substring(1)));
    return (evaluator.eval(expression, context) as double);
  }
}
