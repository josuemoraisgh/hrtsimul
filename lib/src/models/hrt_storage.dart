import 'dart:async';
import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hrt_settings.dart';

class HrtStorage {
  final evaluator = const ExpressionEvaluator();
  final rampLevelNotifier = ValueNotifier<double>(0.0);
  final randomLevelNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> selectedInstrument;
  Box<dynamic>? box;

  HrtStorage(this.selectedInstrument) {
    init();
  }

  Future<bool> init() async {
    if (!Hive.isBoxOpen('HRTSTORAGE'))
      box ??= await Hive.openBox<dynamic>('HRTSTORAGE');
    return true;
  }

  Iterable<dynamic> keys() {
    return box?.keys ?? hrtSettings.keys;
  }

  String? getVariable(String idVariable) {
    dynamic resp = box?.get(idVariable) ?? hrtSettings[idVariable]?.$3;
    return resp is Map ? resp[selectedInstrument.value] : resp;
  }

  void setVariable(String idVariable, String value) {
    if (box != null) {
      dynamic resp = box?.get(idVariable) ?? hrtSettings[idVariable]?.$3;
      if (resp is Map) {
        box!.put(
            idVariable,
            (resp.map((key, val) => resp[selectedInstrument.value] == key
                ? MapEntry<String, String>(key, value)
                : MapEntry<String, String>(key, val))) as dynamic);
      } else {
        box!.put(idVariable, value);
      }
    }
  }
}
