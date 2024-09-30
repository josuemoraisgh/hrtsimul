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
    // Converte keys() para uma lista
    final hrtKeys = controller.hrtTransmitter.keys().toList();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            // Cabeçalho (header)
            _buildHeader(),
            // Adicionando um contêiner com altura fixa para permitir rolagem
            Expanded(
              child: ListView.builder(
                itemCount:
                    hrtKeys.length, // Usar o comprimento da lista correta
                itemBuilder: (context, index) {
                  final name = hrtKeys[index]; // Acessar pelo índice correto
                  return _buildListRow(name);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _tableTextField('DESC',
                isHeader: true, color: Colors.blue, txtColor: Colors.white),
          ),
          Expanded(
            flex: 2,
            child: _tableTextField('VALUE',
                isHeader: true, color: Colors.blue, txtColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(String name) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black), // Simula as linhas de grade
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _tableTextField(name,
                color: Colors.blue, txtColor: Colors.white),
          ),
          Expanded(
            flex: 2,
            child: _hrtType(hrtSettings[name]!.$2, name),
          ),
        ],
      ),
    );
  }

  Widget _tableTextField(
    String text, {
    bool isHeader = false,
    Color? color,
    Color? txtColor,
    void Function(String)? onChanged,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: TextEditingController(text: text),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: txtColor,
          fontSize: 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        readOnly: onChanged == null,
        onChanged: (newValue) {
          if (onChanged != null &&
              newValue.isNotEmpty &&
              double.tryParse(newValue) != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _hrtType(String type, String name) {
    final String func = controller.hrtTransmitter.getVariable(name) ?? "NULL";
    return switch (type) {
      (String s) when s.contains('BIT_ENUM') =>
        _tableTextField("", color: Colors.red),
      (String s) when s.contains('ENUM') =>
        _hrtTypeHex2Enun(int.parse(s.substring(s.length - 2)), name),
      'SReal' || 'FLOAT' => func.substring(0, 1) == '@'
          ? AnimatedBuilder(
              animation: controller.hrtTransmitter,
              builder: (context, child) =>
                  _tableTextField(controller.hrtTransmitter.funcValues[name]!.funcValue.toString()))
          : _tableTextField(
              controller.hrtTransmitter.getTransmitterValue(name, func).toString(),
              onChanged: (newValue) {
                controller.hrtTransmitter.setVariable(
                    name, hrtTypeHexFrom(double.parse(newValue), "FLOAT"));
              },
            ),
      _ => _tableTextField(hrtTypeHexTo(func, type).toString()),
    };
  }

  Widget _hrtTypeHex2Enun(int enumId, String name) {
    final String value = controller.hrtTransmitter.getVariable(name) ?? "NULL";
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth; // Obtém a largura atual
      return CustomDropdown(
          id: value.substring(value.length - 2),
          hrtEnum: hrtEnum[enumId],
          maxWidth: size - 24,
          onChanged: (id) {
            if (id != null) {
              controller.hrtTransmitter.setVariable(name, id);
            }
          });
    });
  }
}
