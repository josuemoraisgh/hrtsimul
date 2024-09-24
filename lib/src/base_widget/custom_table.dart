import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hrtsimul/src/base_widget/custom_dropdown.dart';
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.0),
                1: FlexColumnWidth(2.0) /*FixedColumnWidth(300)*/
              },
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    _tableTextField('DESC', isHeader: true, color: Colors.blue),
                    _tableTextField('VALUE',
                        isHeader: true, color: Colors.blue),
                  ],
                ),
              ],
            ),
            // Adicionando um contêiner com altura fixa para permitir rolagem
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.0),
                    1: FlexColumnWidth(2.0)
                  },
                  border: TableBorder.all(),
                  children: [
                    for (var name in controller.hrtStorage.keys())
                      tableLinha(name),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow tableLinha(String name) {
    return TableRow(
      children: [
        _tableTextField(name, color: Colors.blue),
        _hrtType(
          hrtSettings[name]!.$2,
          name,
        ),
      ],
    );
  }

  // Widget _tableCell(String text, {bool isHeader = false, Color? color}) {
  //   return Container(
  //     color: color,
  //     padding: const EdgeInsets.all(8.0),
  //     child: Text(
  //       text,
  //       textAlign: TextAlign.center,
  //       style: TextStyle(
  //         fontSize: 16,
  //         fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
  //       ),
  //     ),
  //   );
  // }

  Widget _hrtType(String type, String name) {
    final String value = controller.hrtStorage.getVariable(name) ?? "NULL";
    return switch (type) {
      (String s) when s.contains('BIT_ENUM') =>
        _hrtTypeHex2BitEnum(int.parse(s.substring(s.length - 2)), name),
      (String s) when s.contains('ENUM') =>
        _hrtTypeHex2Enun(int.parse(s.substring(s.length - 2)), name),
      'SReal' ||
      'FLOAT' =>
        _tableTextField(controller.hrtStorage.hrtFunc2Hex(name) ?? ""),
      _ => _tableTextField(hrtTypeHexTo(value, type).toString()),
    };
  }

  Widget _hrtTypeHex2BitEnum(int enumId, String value) {
    return Container();
  }

  Widget _hrtTypeHex2Enun(int enumId, String name) {
    final String value = controller.hrtStorage.getVariable(name) ?? "NULL";
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth; // Obtém a largura atual
        return CustomDropdown(
            id: value.substring(value.length - 2),
            hrtEnum: hrtEnum[enumId],
            maxWidth: size - 24,
            onChanged: (id) {
              setState(() {
                if (id != null) {
                  controller.hrtStorage.setVariable(name, id);
                }
              });
            });
      },
    );
  }

  Widget _tableTextField(String text, {bool isHeader = false, Color? color}) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        // Controlador para armazenar o valor
        decoration: InputDecoration(
          hintText: text, // Mantém o texto como placeholder
          border: InputBorder.none,
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        onChanged: (newValue) {
          setState(() {});
        },
      ),
    );
  }
}
