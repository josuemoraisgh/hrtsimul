import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hrtsimul/src/base_widget/dropdown_body.dart';
import '../extension/hex_extension_string.dart';
import '../models/hrt_enum.dart';
import '../models/hrt_settings.dart';
import '../models/hrt_type.dart';
import '../modules/home/home_controller.dart';

class CustomTable extends StatefulWidget {
  const CustomTable({super.key});

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  final controller = Modular.get<HomeController>();
  final GlobalKey _columnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FixedColumnWidth(300),
            },
            border: TableBorder.all(),
            children: [
              TableRow(
                children: [
                  tableCell('DESC', isHeader: true),
                  Container(
                    key: _columnKey,
                    child: tableCell('VALUE', isHeader: true),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FixedColumnWidth(300),
                },
                children: [
                  for (var name in controller.hrtStorage.keys())
                    tableLinha(name),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  TableRow tableLinha(String name) {
    return TableRow(
      children: [
        tableCell(name),
        hrtType(hrtSettings[name]!.$2,
            controller.hrtStorage.getVariable(name) ?? "NULL"),
      ],
    );
  }

  Widget hrtType(String type, String value) {
    final Widget result = switch (type) {
      'UNSIGNED' => tableCell(value
          .splitByLength(2)
          .map((e) => hrtTypeHexTo(e, 'UInt').toString())
          .join()),
      (String s) when s.contains('BIT_ENUM') =>
        _hrtTypeHex2BitEnum(int.parse(s.substring(s.length - 2)), value),
      (String s) when s.contains('ENUM') =>
        _hrtTypeHex2Enun(int.parse(s.substring(s.length - 2)), value),
      'PACKED_ASCII' => tableCell(value
          .splitByLength(6)
          .map((e) => hrtTypeHexTo(e, 'PAscii').toString())
          .join()),
      'DATE' => tableCell(hrtTypeHexTo(value, 'Date').toString()),
      'TIME' => tableCell(hrtTypeHexTo(value, 'Time').toString()),
      'FLOAT' =>
        tableCell(controller.hrtStorage.hrtFunc2Double(value).toString()),
      _ => Container(),
    };
    return result;
  }

  Widget _hrtTypeHex2Enun(int enumId, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth; // Obtém a largura atual
        return DropdownBody(
          id: value.substring(value.length - 2),
          hrtEnum: hrtEnum[enumId],
          maxWidth: size - 24,
        );
      },
    );
  }

  Widget _hrtTypeHex2BitEnum(int enumId, String value) {
    return Container();
  }
}
