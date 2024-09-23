import 'dart:async';
import 'package:expressions/expressions.dart';
import '../models/hrt_settings.dart';
import '../models/hrt_type.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HrtStorage {
  final evaluator = const ExpressionEvaluator();
  Box<String>? box;

  HrtStorage() {
    init();
  }

  Future<bool> init() async {
    box ??= await Hive.openBox<String>('HRTSTORAGE');
    return true;
  }

  Iterable<dynamic> keys() {
    return box?.keys ?? hrtSettings.keys;
  }

  String? getVariable(String idVariable1) {
    return box?.get(idVariable1) ?? hrtSettings[idVariable1]?.$3;
  }

  void setVariable(String idVariable, String value) {
    if (box != null) {
      box!.put(idVariable, value);
    }
  }

  double? hrtFunc2Double(String value) {
    if (value.substring(0, 1) != '@') return hrtTypeHexTo(value, 'FLOAT');
    final iReg = RegExp(
        r'[A-Z_a-z]+'); //RegExp(r'\b\w+\b'); // Regex para capturar palavras
    final matches = iReg.allMatches(value);
    Map<String, double?> context = {};
    for (var e in matches) {
      if (e.group(0) != null) {
        final variableHex = getVariable(e.group(0)!);
        if (variableHex == null) {
          return null;
        } else {
          context[e.group(0)!] = (variableHex.substring(0, 1) == '@')
              ? hrtFunc2Double(variableHex)
              : hrtTypeHexTo(variableHex, hrtSettings[e.group(0)!]!.$2);
        }
      }
    }
    Expression expression = Expression.parse(value.substring(1));
    return (evaluator.eval(expression, context) as double);
  }

  String? hrtFunc2Hex(String idVariable1) {
    String? value = getVariable(idVariable1);
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
