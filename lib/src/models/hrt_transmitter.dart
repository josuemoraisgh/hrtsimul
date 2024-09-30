import 'dart:async';
import 'dart:math';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:hrtsimul/src/base_widget/hrt_variable_model.dart';
import 'hrt_storage.dart';
import 'hrt_type.dart';

class HrtTransmitter extends ChangeNotifier{
  final hrtStorage = HrtStorage();
  final evaluator = const ExpressionEvaluator();
  final funcValues = <String, HrtVariableModel>{};
  final ValueNotifier<String> selectedInstrument ;
  final ValueNotifier<double> inputValue;

  double rampValue = 0.0;
  double randomValue = 0.0;

  HrtTransmitter(this.selectedInstrument, this.inputValue) {
    hrtStorage.setSelectedInstrument(selectedInstrument);
    for (var variableName in keys()) {
      var func = getVariable(variableName) ?? "";
      if (func.substring(0, 1) == '@') {
        funcValues.addAll({variableName: HrtVariableModel(this,variableName, func)});
      }
    }
    Timer.periodic(Duration(seconds: 1), (timer) {
      updateInputValue();
    });
  }

  void updateInputValue() {
    rampValue = rampValue > 1.0 ? 0.0 : rampValue + 0.01;
    randomValue = Random().nextDouble();
    for (var entrie in funcValues.entries) {
      funcValues[entrie.key]!.updateFunc();
    }
    notifyListeners();
  }

  void insertFuncNotifier(String variableName, String func) {
    if (funcValues.containsKey(variableName))
      funcValues[variableName]!.updateFunc();
    else
      funcValues.addAll({variableName: HrtVariableModel(this,variableName, func)});
  }

  bool deleteFuncNotifier(String key) {
    return funcValues.remove(key) == null ? false : true;
  }

  double? getTransmitterValue(String name, String func,
      {bool isSubFunc = false}) {
    final resp = switch (name) {
      '@input_value' || 'input_value' => inputValue.value,
      '@ramp_value' || 'ramp_value' => rampValue,
      '@ramdom_value' || 'ramdom_value' => randomValue,
      _ => switch (func.substring(0, 1)) {
          '@' => isSubFunc
              ? funcValues[name]?.funcValue ?? 0.0
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
        context[e.group(0)!] = getTransmitterValue(
            e.group(0)!, getVariable(e.group(0)!)!,
            isSubFunc: true);
      }
    }
    Expression expression = Expression.parse((func.substring(1)));
    return (evaluator.eval(expression, context) as double);
  }

  Iterable<dynamic> keys() {
    return hrtStorage.keys(); 
  }

  String? getVariable(String idVariable) {
    return hrtStorage.getVariable(idVariable);
  }

  void setVariable(String idVariable, String value) {
    hrtStorage.setVariable(idVariable, value);
  }
}
