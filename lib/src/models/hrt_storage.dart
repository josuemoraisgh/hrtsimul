import 'dart:async';
import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import '../models/hrt_settings.dart';
import '../models/hrt_type.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HrtStorage {
  final evaluator = const ExpressionEvaluator();
  final ValueNotifier<String> selectedInstrument;
  Box<dynamic>? box;

  HrtStorage(this.selectedInstrument) {
    init();
  }

  Future<bool> init() async {
    box ??= await Hive.openBox<String>('HRTSTORAGE');
    return true;
  }

  Iterable<dynamic> keys() {
    return box?.keys ?? hrtSettings.keys;
  }

  ValueListenable<Box<dynamic>>? listenable(){
    return box?.listenable();
  }

  String? getVariable(String idVariable) {
    dynamic resp = box?.get(idVariable) ?? hrtSettings[idVariable]?.$3;
    return resp is Map ? resp[selectedInstrument.value] : resp;
  }

  void setVariable(String idVariable, String value) {
    if (box != null) {
      dynamic resp = box?.get(idVariable) ?? hrtSettings[idVariable]?.$3;
      if (resp is Map) {
        resp[selectedInstrument.value] = value;
      } else {
        resp = value;
      }
      box!.put(idVariable, resp);
    }
  }

  double? hrtFunc2Double(String idVariable1) {
    final value = getVariable(idVariable1);
    if(value == null) return 0;    
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
