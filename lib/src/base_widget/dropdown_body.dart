import 'package:flutter/material.dart';

class DropdownBody extends StatefulWidget {
  final Map<String, String>? hrtEnum;
  final String id;
  const DropdownBody({super.key, required this.hrtEnum, required this.id});

  @override
  State<DropdownBody> createState() => _DropdownBodyState();
}

class _DropdownBodyState extends State<DropdownBody> {
  String id = "";
  @override
  void initState() {
    id = widget.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: findValueFromMap(widget.hrtEnum!, id),
        onChanged: (String? novoItemSelecionado) {
          if (novoItemSelecionado != null) {
            setState(() {
              id = widget.hrtEnum!.entries
                  .firstWhere(
                    (entry) => entry.value == novoItemSelecionado,
                    orElse: () => const MapEntry('', ''),
                  )
                  .key;
            });
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
                        constraints: const BoxConstraints(maxWidth: 200), // Limita a largura
                        child: Text(
                          entry.value,
                          overflow: TextOverflow.ellipsis,
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
                child: Text(
                  entry.value,
                  // overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
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
        int start = int.parse(parts[0], radix: 16); // Converte '25' para 37
        int end = int.parse(parts[1], radix: 16); // Converte 'FF' para 255
        return key >= start && key <= end;
      }
      return false;
    }

    // Procurando a chave correspondente ao valor
    int keyToTest = keyValue.contains('-') ? 0 : int.parse(keyValue, radix: 16);    
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
