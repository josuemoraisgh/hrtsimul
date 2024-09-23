import 'package:flutter_test/flutter_test.dart';
import 'package:hrtsimul/src/models/hrt_type.dart';

void main() {
  test('Deve dar 02AADFC0 quando valor for 1900-01-01 00:23:18.526', () {
    final valor = DateTime.parse('1900-01-01 00:23:18.526');
    expect(hrtTypeHexFrom(valor,'Time'), '02AADFC0');
  });
}