import 'dart:convert';
import '../extension/hex_extension_string.dart';
import '../extension/bit_field_int.dart';
import 'dart:math';

dynamic hrtTypeHexTo(String valor, String type) {
  final result = switch (type) {
    'UInt' ||
    'UNSIGNED' =>
      valor.splitByLength(2).map((e) => _hrtTypeHex2UInt(e)).join(),
    'SReal' || 'FLOAT' => _hrtTypeHex2SReal(valor),
    'Date' || 'DATE' => _hrtTypeHex2Date(valor),
    'Int' || 'INT' => _hrtTypeHex2Int(valor),
    'PAscii' ||
    'PACKED_ASCII' =>
      valor.splitByLength(6).map((e) => _hrtTypeHex2PAscii(e)).join(),
    'Time' || 'TIME' => _hrtTypeHex2Time(valor),
    _ => 'Type Invalida', //Valor padrão, substitui o default
  };
  return result;
}

String hrtTypeHexFrom(dynamic valor, String type) {
  final result = switch (type) {
    'UInt' || 'UNSIGNED' => _hrtTypeUInt2Hex(valor),
    'SReal' || 'FLOAT' => _hrtTypeSReal2Hex(valor),
    'Date' || 'DATE' => _hrtTypeDate2Hex(valor),
    'Int' || 'INT' => _hrtTypeInt2Hex(valor),
    'PAscii' || 'PACKED_ASCII' => _hrtTypePAscii2Hex(valor),
    'Time' || 'TIME' => _hrtTypeTime2Hex(valor),
    _ => 'Type inválido', //Valor padrão, substitui o default
  };
  return result;
}

// Number.toRadixString(Tipo) -> Converte um numero em uma string conforme o tipo
//https://github.com/dart-lang/sdk/issues/38954
// int.parse(String, radix: Tipo) -> converte a string em um numero conforme o tipo
// https://www.learndartprogramming.com/fundamentals/errors-and-exceptions-in-dart-throw-catch-and-finally/
int _hrtTypeHex2UInt(String strUInt) {
  if (strUInt == '') {
    throw ArgumentError("Função hrtTypeHex2UInt recebeu string vazia");
  }
  if (strUInt.length > 4) {
    throw ArgumentError(
        "Função hrtTypeHex2UInt recebeu hexString com mais de dois termos");
  }
  if (strUInt
      .split('')
      .where((element) => int.parse(element, radix: 36) > 15)
      .isNotEmpty) {
    throw ArgumentError(
        "Função hrtTypeHex2UInt recebeu hexString com caracteres que não são hex");
  }
  return int.parse(strUInt, radix: 16);
}

int _hrtTypeHex2Int(String strUInt) {
  if (strUInt == '') {
    throw ArgumentError("Função hrtTypeHex2UInt recebeu string vazia");
  }
  if (strUInt.length > 4) {
    throw ArgumentError(
        "Função hrtTypeHex2UInt recebeu hexString com mais de dois termos");
  }
  if (strUInt
      .split('')
      .where((element) => int.parse(element, radix: 36) > 15)
      .isNotEmpty) {
    throw ArgumentError(
        "Função hrtTypeHex2UInt recebeu hexString com caracteres que não são hex");
  }
  return int.parse(strUInt, radix: 16).toSigned(16);
}

double _hrtTypeHex2SReal(String strFloat) {
  final int number = int.parse(strFloat, radix: 16);
  final int s = number.getBits(31, 1);
  final int e = number.getBits(23, 8);
  final double f = number.getBits(0, 23) / 8388608;
  return pow(-1, s) * pow(2, (e - 127)) * (1 + f);
}

String _hrtTypeHex2PAscii(String valor) {
  final List<String> numbers =
      int.parse(valor, radix: 16).toRadixString(2).splitByLength(6);
  return ascii.decode(numbers.map((e) {
    var resp = int.parse(e, radix: 2);
    return resp.getBits(5, 1) == 1
        ? resp.setBits(6, 1, 0)
        : resp.setBits(6, 1, 1);
  }).toList());
}

DateTime _hrtTypeHex2Date(String valor) {
  final aux =
      valor.splitByLength(2).map((e) => int.parse(e, radix: 16)).toList();
  if (aux.length < 3) {
    throw ArgumentError("Formato do HEX para formar data Incorreta");
  }
  return DateTime(1900 + aux[2], aux[1], aux[0]);
}

DateTime _hrtTypeHex2Time(String valor) {
  final aux =
      valor.splitByLength(2).map((e) => int.parse(e, radix: 16)).toList();
  final resp = aux[0] * 524288 + aux[1] * 2048 + aux[2] * 8 + aux[3] * 0.03125;
  return DateTime(1900, 1, 1, resp ~/ 3600000, (resp ~/ 60000) % 60,
      (resp ~/ 1000) % 60, (resp % 1000).toInt());
}

// Number.toRadixString(Tipo) -> Converte um numero em uma string conforme o tipo
//https://github.com/dart-lang/sdk/issues/38954
// int.parse(String, radix: Tipo) -> converte a string em um numero conforme o tipo
// https://www.learndartprogramming.com/fundamentals/errors-and-exceptions-in-dart-throw-catch-and-finally/
String _hrtTypeUInt2Hex(int uIntStr) {
  final String valor = uIntStr.toRadixString(16);
  if (uIntStr > 65535) {
    throw ArgumentError("Função hrtTypeUInt2Hex: valor acima do limite máximo");
  }
  final resp = valor.padLeft(4, '0');
  return resp.substring(resp.length - 4).toUpperCase();
}

String _hrtTypeInt2Hex(int uIntStr) {
  final String valor = BigInt.from(uIntStr).toUnsigned(64).toRadixString(16);
  if (uIntStr > 65535) {
    throw ArgumentError("Função hrtTypeUInt2Hex: valor acima do limite máximo");
  }
  final resp = valor.padLeft(4, '0');
  return resp.substring(resp.length - 4).toUpperCase();
}

String _hrtTypeSReal2Hex(double valorFloat) {
  int bitsArray = 0;
  if (valorFloat < 0) {
    bitsArray = bitsArray.setBits(31, 1, 1);
    valorFloat = -1 * valorFloat; //Seta os bits do sinal
  }
  final int e = 127 + (log(valorFloat) / log(2)).floor();
  bitsArray = bitsArray.setBits(23, 8, e); //Seta dos bits da Mantissa
  final int f = (((valorFloat / pow(2, e - 127)) - 1) * 8388608).floor();
  bitsArray = bitsArray.setBits(0, 23, f);
  return bitsArray.toRadixString(16).toUpperCase();
}

String _hrtTypePAscii2Hex(String valor) {
  final resp0 = ascii.encode(valor);
  final resp1 = resp0
      .map((e) => e.getBits(0, 6).toRadixString(2).padLeft(6, '0'))
      .join()
      .splitByLength(8);
  final resp2 = resp1
      .map((e) => int.parse(e, radix: 2).toRadixString(16).padLeft(2, '0'))
      .join();
  return resp2.toUpperCase();
}

String _hrtTypeDate2Hex(DateTime valor) {
  final resp = valor.day.toRadixString(16).padLeft(2, '0') +
      valor.month.toRadixString(16).padLeft(2, '0') +
      (valor.year.toInt() - 1900).toRadixString(16).padLeft(2, '0');
  return resp.toUpperCase();
}

String _hrtTypeTime2Hex(DateTime valor) {
  final aux = (valor.hour * 3600000 +
          valor.minute * 60000 +
          valor.second * 1000 +
          valor.millisecond) ~/
      0.03125;
  return "${aux.getBits(24, 8).toRadixString(16).padLeft(2, '0')}${aux.getBits(16, 8).toRadixString(16).padLeft(2, '0')}${aux.getBits(8, 8).toRadixString(16).padLeft(2, '0')}${aux.getBits(0, 8).toRadixString(16).padLeft(2, '0')}"
      .toUpperCase();
}
