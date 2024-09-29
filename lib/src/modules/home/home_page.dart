import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../base_widget/custom_table.dart';
import '../../base_widget/custom_tanque.dart';
import '../../models/hrt_settings.dart';
import './home_controller.dart';
import '../../base_widget/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Modular.get<HomeController>();
  bool connected = false;

  @override
  void initState() {
    super.initState();
    controller.hrtComm.port = controller.hrtComm.availablePorts[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: controller.init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) =>
            !snapshot.hasData
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(children: [
                          CustomTank('percent_of_range'),
                          const CustomTable(),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _buildLogContainer(),
                      const SizedBox(height: 10),
                      _buildControls(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.only(
          left: 10, right: 10, bottom: 5), // Espaço interno
      decoration: BoxDecoration(
        color: Colors.blue, // Cor de fundo azul
        borderRadius: BorderRadius.circular(12), // Bordas arredondadas
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // Sombra
            blurRadius: 8, // Intensidade da sombra
            offset: Offset(0, 4), // Posição da sombra
          ),
        ],
      ),
      child: const Text(
        "Hart Simulate 1.0",
        style: TextStyle(
          fontSize: 28,
          color: Colors.white, // Cor do texto em branco
          fontWeight: FontWeight.bold, // Texto em negrito
        ),
      ),
    );
  }

  // Widget para exibir o log de eventos
  Widget _buildLogContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 200,
      child: TextField(
        readOnly: true,
        controller: controller.textController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Log de Eventos',
          filled: true,
        ),
      ),
    );
  }

  // Widget principal que contém os controles (Dropdown, Radio, Botões)
  Widget _buildControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildTransmiterSelection(),
        const SizedBox(width: 10),
        _buildPortSelection(),
        const SizedBox(width: 10),
        _buildMasterSlaveSelection(),
        const SizedBox(width: 10),
        _buildConnectButton(),
        const SizedBox(width: 10),
        _buildCommandField(),
      ],
    );
  }

  // Widget para selecionar o modelo do transmissor que será simulado
  Widget _buildTransmiterSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        isExpanded: false,
        value: controller.selectedInstrument.value,
        onChanged: controller.connectNotifier.value == "CONNECTED"
            ? null
            : (String? novoItemSelecionado) {
                if (novoItemSelecionado != null) {
                  setState(() {
                    controller.selectedInstrument.value = novoItemSelecionado;
                  });
                }
              },
        underline: Container(),
        iconEnabledColor: Colors.black,
        items: instrumentType.map((String dropDownStringItem) {
          return DropdownMenuItem<String>(
            value: dropDownStringItem,
            child: Text(
              dropDownStringItem,
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget para selecionar a porta de comunicação
  Widget _buildPortSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        isExpanded: false,
        value: controller.hrtComm.port,
        onChanged: controller.connectNotifier.value == "CONNECTED"
            ? null
            : (String? novoItemSelecionado) {
                if (novoItemSelecionado != null) {
                  setState(() {
                    controller.hrtComm.port = novoItemSelecionado;
                  });
                }
              },
        underline: Container(),
        iconEnabledColor: Colors.black,
        items:
            controller.hrtComm.availablePorts.map((String dropDownStringItem) {
          return DropdownMenuItem<String>(
            value: dropDownStringItem,
            child: Text(
              dropDownStringItem,
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget para selecionar o modo (Master/Slave)
  Widget _buildMasterSlaveSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<String>(
              value: '02',
              groupValue: controller.frameType.value,
              onChanged: (String? value) {
                setState(() {
                  controller.frameType.value = value!;
                });
              },
            ),
            const Text('Master', style: TextStyle(fontSize: 14)),
          ],
        ),
        Row(
          children: [
            Radio<String>(
              value: '06',
              groupValue: controller.frameType.value,
              onChanged: (String? value) {
                setState(() {
                  controller.frameType.value = value!;
                });
              },
            ),
            const Text('Slave', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // Widget para conectar e desconectar
  Widget _buildConnectButton() {
    return CustomButton(
        title: "CONNECTED",
        titleOff: "DISCONNECTED",
        initialValue: "DISCONNECTED",
        groupValue: controller.connectNotifier,
        colorOn: Colors.red,
        colorOff: Colors.green,
        onChanged: (e) {
          setState(() {
            controller.hrtButtonConnect(e);
          });
        });
  }

  Widget _buildCommandField() {
    return ValueListenableBuilder(
      valueListenable: controller.connectNotifier,
      builder: (BuildContext context, dynamic connectNotifier, Widget? child) {
        return ValueListenableBuilder(
          valueListenable: controller.frameType,
          builder: (BuildContext context, dynamic frameType, Widget? child) {
            bool isEnabled =
                connectNotifier == "CONNECTED" && frameType == '02';
            return Row(
              children: [
                // Texto "Command" com mudança de aparência
                Text(
                  "Command: ",
                  style: TextStyle(
                    color:
                        isEnabled ? Colors.black : Colors.grey, // Cor do texto
                    fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 10),
                // TextField com aparência alterada
                SizedBox(
                  width: 80,
                  height: 35,
                  child: TextField(
                    enabled: isEnabled, // Habilita/desabilita o campo
                    controller: controller.commandController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isEnabled
                          ? Colors.black
                          : Colors.grey, // Cor do texto
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isEnabled
                              ? Colors.black
                              : Colors.grey, // Cor da borda
                        ),
                      ),
                      fillColor: isEnabled
                          ? Colors.white
                          : Colors.grey[200], // Cor de fundo
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // ElevatedButton com aparência alterada
                ElevatedButton(
                  onPressed: isEnabled
                      ? () async {
                          controller
                              .masterMode(controller.commandController.text);
                          await Future.delayed(const Duration(seconds: 1)).then(
                            (value) {
                              controller.commandController.clear();
                            },
                          );
                        }
                      : null, // Desabilita o botão se não for permitido
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isEnabled ? Colors.blue : Colors.grey, // Cor de fundo
                    foregroundColor: isEnabled
                        ? Colors.white
                        : Colors.black54, // Cor do texto
                  ),
                  child: const Text("SEND"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
