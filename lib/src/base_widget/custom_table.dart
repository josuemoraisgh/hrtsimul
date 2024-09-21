import 'package:flutter/widgets.dart';
import 'package:hrtsimul/src/base_widget/dropdown_body.dart';
import '../extension/hex_extension_string.dart';
import '../models/hrt_enum.dart';
import '../models/hrt_type.dart';

class CustomTable extends StatelessWidget {
//NAME:(BYTE_SIZE, TYPE, (DEFAULT_VALUE | @FUNCTION) )
  final Map<String, (int, String, String)> hrtSettings;
  const CustomTable({super.key, required this.hrtSettings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FixedColumnWidth(300), // Fixa a segunda coluna (Idade)
            },
            border: TableBorder.all(),
            children: [
              // Cabeçalho da tabela
              TableRow(
                children: [
                  tableCell('DESC', isHeader: true),
                  tableCell('VALUE', isHeader: true),
                ],
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Expanded(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FixedColumnWidth(300), // Fixa a segunda coluna (Idade)
                  },
                  children: [
                    // Preencher linhas da tabela com dados do Map
                    for (var entry in hrtSettings.entries)
                      tableLinha(entry) // Profissão (String)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função auxiliar para criar uma célula com estilo e padding
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

  // Função auxiliar para criar uma célula com estilo e padding
  TableRow tableLinha(MapEntry<String, (int, String, String)> entry) {
    return TableRow(
      children: [
        tableCell(entry.key),
        hrtType(entry.value),
      ],
    );
  }

  Widget hrtType((int, String, String) value) {
    final Widget result = switch (value.$2) {
      'UNSIGNED' => tableCell(value.$3
          .splitByLength(2)
          .map((e) => hrtTypeHexTo(e, 'UInt').toString())
          .join()),
      (String s) when s.contains('BIT_ENUM') => _hrtTypeHex2BitEnum(value),          
      (String s) when s.contains('ENUM') => _hrtTypeHex2Enun(value),
      'PACKED_ASCII' => tableCell(value.$3
          .splitByLength(6)
          .map((e) => hrtTypeHexTo(e, 'PAscii').toString())
          .join()),
      'DATE' => tableCell(hrtTypeHexTo(value.$3, 'Date').toString()),
      'TIME' => tableCell(hrtTypeHexTo(value.$3, 'Time').toString()),
      'FLOAT' => _hrtTypeHex2Float(value),
      _ => Container(), //Valor padrão, substitui o default
    };
    return result;
  }

  Widget _hrtTypeHex2Enun((int, String, String) value) {
    return DropdownBody(
        id: value.$3.substring(value.$3.length - 2),
        hrtEnum: hrtEnum[int.parse(value.$2.substring(value.$2.length - 2))]);
  }

  Widget _hrtTypeHex2BitEnum(value) {
    return Container();
  }

  Widget _hrtTypeHex2Float(value) {
    //return tableCell(hrtTypeHexTo(value.$3, 'SReal').toString())
    return Container();
  }
}
