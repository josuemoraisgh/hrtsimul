import 'dart:async';
import 'dart:math';

import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

import 'hrt_settings.dart';
import 'hrt_storage.dart';
import 'hrt_type.dart';

class HrtTranslate {
  final updateValueFunc = ValueNotifier<bool>(true);
  final evaluator = const ExpressionEvaluator();
  final rampValueNotifier = ValueNotifier<double>(0.0);
  final randomValueNotifier = ValueNotifier<double>(0.0);
  var funcNotifier = ValueNotifier<Map<String, (String, double?)>>({});
  final HrtStorage hrtStorage;

  HrtTranslate(this.hrtStorage) {
    _init();
  }

  void _init() {
    for (var key in hrtStorage.keys()) {
      var func = hrtStorage.getVariable(key) ?? "";
      if (func.substring(0, 1) == '@' || func.substring(0, 1) == '#') {
        funcNotifier.value = {key: (func, hrtFunc2Double(func))};
      }
    }
    Timer.periodic(Duration(seconds: 1), (timer) {
      rampValueNotifier.value += 0.01;
      if (rampValueNotifier.value > 1.0) rampValueNotifier.value = 0.0;
      randomValueNotifier.value = Random().nextDouble();
      funcNotifier.value = funcNotifier.value.map(
          (key, func) => MapEntry(key, (func.$1, hrtFunc2Double(func.$1))));
      updateValueFunc.value = !updateValueFunc.value;
    });
  }

  void updateFuncNotifier(String key, String func) {
    if (funcNotifier.value.containsKey(key))
      funcNotifier.value[key] = (func, funcNotifier.value[key]!.$2);
    else
      funcNotifier.value[key] = (func, hrtFunc2Double(func));
  }

  bool deleteFuncNotifier(String key) {
    return funcNotifier.value.remove(key) == null ? false : true;
  }

  double? hrtVirtalVar(String idVariable) {
    return switch (idVariable) {
      '#ramp_value' || 'ramp_value' => rampValueNotifier.value,
      '#ramdom_value' || 'ramdom_value' => randomValueNotifier.value,
      _ => 0.0, //Valor padrão, substitui o default
    };
  }

  double? hrtFunc2Double(String idVariable1) {
    final value = hrtStorage.getVariable(idVariable1);
    if (value == null) return 0;
    if (value.substring(0, 1) == '#') return hrtVirtalVar(value);
    if (value.substring(0, 1) == '@') {
      final iReg = RegExp(
          r'[#_A-Z_a-z]+'); //RegExp(r'(#\b\w+\b)|(\b\w+\b)'); // Regex para capturar palavras
      final matches = iReg.allMatches(value);
      Map<String, double?> context = {};
      for (var e in matches) {
        if (e.group(0) != null) {
          final variableHex = hrtStorage.getVariable(e.group(0)!);
          if (variableHex == null) {
            return null;
          } else {
            context[e.group(0)!] = hrtFunc2Double(variableHex);
          }
        }
      }
      Expression expression = Expression.parse(value.substring(1));
      return (evaluator.eval(expression, context) as double);
    }
    return hrtTypeHexTo(value, hrtSettings[idVariable1]!.$2);
  }

  String? hrtFunc2Hex(String idVariable1) {
    String? value = hrtStorage.getVariable(idVariable1);
    if (value == null) return null;
    double? result = hrtFunc2Double(value);
    if (result == null) return null;
    return result
        .toInt()
        .toRadixString(16)
        .toUpperCase()
        .padLeft(hrtSettings[idVariable1]!.$1, '0');
  }
}
