import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final Map<String, String>? hrtEnum;
  final double maxWidth;
  final String id;
  final Function(String?)? onChanged;
  const CustomDropdown({
    super.key,
    required this.hrtEnum,
    required this.id,
    required this.maxWidth,
    this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String id;

  @override
  void initState() {
    id = widget.id;    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o hrtEnum é nulo ou vazio
    if (widget.hrtEnum == null || widget.hrtEnum!.isEmpty) {
      return const Text("No data available");
    }

    return Center(
      child: DropdownButton<String>(
        value: findValueFromMap(widget.hrtEnum!, id),
        onChanged: (String? novoItemSelecionado) {
          if (novoItemSelecionado != null) {
            if (widget.onChanged != null) {
              setState(() {
                id = widget.hrtEnum!.entries
                    .firstWhere(
                      (entry) => entry.value == novoItemSelecionado,
                      orElse: () => const MapEntry('', ''),
                    )
                    .key;
                widget.onChanged!(id);
              });
            }
          }
        },
        style: const TextStyle(
          color: Colors.black,
        ),
        underline: Container(),
        iconEnabledColor: Colors.black,
        dropdownColor: Theme.of(context).colorScheme.surface,
        focusColor: Theme.of(context).colorScheme.surface,
        selectedItemBuilder: (BuildContext context) {
          return widget.hrtEnum!.entries
              .map<DropdownMenuItem<String>>(
                (MapEntry<String, String> entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: widget.maxWidth,
                      ),
                      alignment: Alignment.center, // Centraliza o texto
                      child: Text(
                        entry.value,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center, // Centraliza o texto
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              )
              .toList()
              .cast<Widget>();
        },
        items: widget.hrtEnum!.entries
            .map((MapEntry<String, String> entry) {
              return DropdownMenuItem<String>(
                value: entry.value,
                child: Container(
                  alignment: Alignment.center, // Centraliza o texto
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center, // Centraliza o texto
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            })
            .toList()
            .cast<DropdownMenuItem<String>>(),
      ),
    );
  }

  String? findValueFromMap(Map<String, String> map, String keyValue) {
    // Função auxiliar para verificar se a chave está no intervalo (ex.: '25 - FF')
    bool isInRange(String range, int key) {
      if (range.contains('-')) {
        // Dividindo o range em dois valores (inicial e final)
        List<String> parts = range.split('-');
        int start = int.parse(parts[0], radix: 16);
        int end = int.parse(parts[1], radix: 16);
        return key >= start && key <= end;
      }
      return false;
    }

    // Conversão segura do valor da chave para hexadecimal
    int keyToTest;
    try {
      keyToTest = keyValue.contains('-') ? 0 : int.parse(keyValue, radix: 16);
    } catch (e) {
      keyToTest = 0; // Valor padrão em caso de erro
    }

    // Procurando a chave correspondente ao valor
    String? result;
    map.forEach((k, v) {
      if (k == keyValue.toUpperCase()) {
        result = v; // Chave exata encontrada
      } else if (isInRange(k, keyToTest)) {
        result = v; // Chave encontrada dentro de um intervalo
      }
    });

    return result;
  }
}
