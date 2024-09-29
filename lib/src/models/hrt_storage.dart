
import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import '../../main.dart';
import '../models/hrt_settings.dart';

class HrtStorage {
  final evaluator = const ExpressionEvaluator();
  final rampLevelNotifier = ValueNotifier<double>(0.0);
  final randomLevelNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> selectedInstrument;

  HrtStorage(this.selectedInstrument);

  // Future<bool> init() async {
  //   if (!Hive.isBoxOpen('HRTSTORAGE'))
  //     box ??= await Hive.openBox<dynamic>('HRTSTORAGE');
  //   return true;
  // }

  Iterable<dynamic> keys() {
    return hrtSettings.keys;
  }

  String? getVariable(String idVariable) {
    dynamic resp = boxHrtStorage?.get(idVariable) ?? hrtSettings[idVariable]?.$3;
    return resp is Map ? resp[selectedInstrument.value] : resp;
  }

  void setVariable(String idVariable, String value) {
    if (boxHrtStorage != null) {
      dynamic resp = boxHrtStorage?.get(idVariable) ?? hrtSettings[idVariable]?.$3;
      if (resp is Map) {
        boxHrtStorage!.put(
            idVariable,
            (resp.map((key, val) => resp[selectedInstrument.value] == key
                ? MapEntry<String, String>(key, value)
                : MapEntry<String, String>(key, val))) as dynamic);
      } else {
        boxHrtStorage!.put(idVariable, value);
      }
    }
  }
}
