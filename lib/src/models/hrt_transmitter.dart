import 'dart:async';
import 'dart:math';

import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

import 'hrt_settings.dart';
import 'hrt_storage.dart';
import 'hrt_type.dart';

class HrtTransmitter extends HrtStorage {
  final updateValueFunc = ValueNotifier<bool>(true);
  final evaluator = const ExpressionEvaluator();
  final rampValueNotifier = ValueNotifier<double>(0.0);
  final randomValueNotifier = ValueNotifier<double>(0.0);
  var funcNotifier = ValueNotifier<Map<String, (String, double?)>>({});

  HrtTransmitter(super.selectedInstrument) {}

  Future<bool> init() async {
    await super.init();
    for (var key in super.keys()) {
      var func = super.getVariable(key) ?? "";
      if (func.substring(0, 1) == '@' || func.substring(0, 1) == '#') {
        funcNotifier.value.addAll({key: (func, getValue(func))});
      }
    }
    Timer.periodic(Duration(seconds: 1), (timer) {
      rampValueNotifier.value += 0.01;
      if (rampValueNotifier.value > 1.0) rampValueNotifier.value = 0.0;
      randomValueNotifier.value = Random().nextDouble();
      for (var entrie in funcNotifier.value.entries) {
        funcNotifier.value[entrie.key] =
            (entrie.value.$1, getValue(entrie.value.$1));
      }
      updateValueFunc.value = !updateValueFunc.value;
    });
    return true;
  }

  void updateFuncNotifier(String variableName, String func) {
    if (funcNotifier.value.containsKey(variableName))
      funcNotifier.value[variableName] = (func, getValue(func));
    else
      funcNotifier.value.addAll({variableName: (func, getValue(func))});
  }

  bool deleteFuncNotifier(String key) {
    return funcNotifier.value.remove(key) == null ? false : true;
  }

  double? hrtVirtalVar(String func) {
    return switch (func) {
      '#ramp_value' => rampValueNotifier.value,
      '#ramdom_value' => randomValueNotifier.value,
      _ => 0.0, //Valor padrão, substitui o default
    };
  }

  double? getValue(String func) {
    return switch (func.substring(0, 1)) {
      '#' => hrtVirtalVar(func),
      '@' => hrtFunc2Double(func),
      _ => hrtTypeHexTo(func, 'FLOAT'),
    };
  }

  double? hrtFunc2Double(String func) {
    //RegExp(r'(#\b\w+\b)|(\b\w+\b)'); // Regex para capturar palavras
    final iReg = RegExp(r'[#A-Z_a-z]+');
    final matches = iReg.allMatches(func);
    Map<String, double?> context = {};
    for (var e in matches) {
      if (e.group(0) != null) {
        final variableName = e.group(0)!;
        final variableFunc = super.getVariable(variableName) ?? variableName;
        context[variableName] = variableFunc.substring(0, 1) == '@'
            ? funcNotifier.value[variableName]?.$2
            : getValue(variableFunc);
      }
    }
    Expression expression = Expression.parse((func.substring(1)));
    return (evaluator.eval(expression, context) as double);
  }

  String? hrtFunc2Hex(String variableName) {
    String? value = super.getVariable(variableName);
    if (value == null) return null;
    double? result = hrtFunc2Double(value);
    if (result == null) return null;
    return result
        .toInt()
        .toRadixString(16)
        .toUpperCase()
        .padLeft(hrtSettings[variableName]!.$1, '0');
  }
}
