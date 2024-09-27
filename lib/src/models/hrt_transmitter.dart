import 'dart:async';
import 'dart:math';

import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

import 'hrt_storage.dart';
import 'hrt_type.dart';

class HrtTransmitter extends HrtStorage {
  final updateValueFunc = ValueNotifier<bool>(true);
  final evaluator = const ExpressionEvaluator();
  final rampValueNotifier = ValueNotifier<double>(0.0);
  final randomValueNotifier = ValueNotifier<double>(0.0);
  var funcNotifier = ValueNotifier<Map<String, (String, double?)>>({});
  ValueNotifier<double> inputValue;

  HrtTransmitter(super.selectedInstrument, this.inputValue) {}

  Future<bool> init() async {
    await super.init();
    for (var key in super.keys()) {
      var func = super.getVariable(key) ?? "";
      if (func.substring(0, 1) == '@' || func.substring(0, 1) == '#') {
        funcNotifier.value.addAll({key: (func, 0.0)});
      }
    }
    Timer.periodic(Duration(seconds: 1), (timer) {
      rampValueNotifier.value += 0.01;
      if (rampValueNotifier.value > 1.0) rampValueNotifier.value = 0.0;
      randomValueNotifier.value = Random().nextDouble();
      for (var entrie in funcNotifier.value.entries) {
        funcNotifier.value[entrie.key] =
            (entrie.value.$1, getTransmitterValue(entrie.value.$1));
      }
      updateValueFunc.value = !updateValueFunc.value;
    });
    return true;
  }

  void updateFuncNotifier(String variableName, String func) {
    if (funcNotifier.value.containsKey(variableName))
      funcNotifier.value[variableName] = (func, 0.0);
    else
      funcNotifier.value.addAll({variableName: (func, 0.0)});
  }

  bool deleteFuncNotifier(String key) {
    return funcNotifier.value.remove(key) == null ? false : true;
  }

  double? getTransmitterValue(String name, {bool isSubFunc = false}) {
    final String? func = super.getVariable(name);
    return switch (name) {
      'input_value' => inputValue.value,
      'ramp_value' => rampValueNotifier.value,
      'ramdom_value' => randomValueNotifier.value,
      _ => func == null
          ? null
          : switch (func.substring(0, 1)) {
              '@' =>
                isSubFunc ? funcNotifier.value[name]?.$2 : hrtFunc2Double(func),
              _ => hrtTypeHexTo(func, 'FLOAT'),
            },
    };
  }

  double? hrtFunc2Double(String func) {
    //RegExp(r'(#\b\w+\b)|(\b\w+\b)'); // Regex para capturar palavras
    final iReg = RegExp(r'[#A-Z_a-z]+');
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
