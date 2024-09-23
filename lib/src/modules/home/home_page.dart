import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../base_widget/custom_table.dart';
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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return FutureBuilder<bool>(
            future: controller.init(),
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot snapshot) => snapshot
                        .data ==
                    false
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    width: constraints.maxWidth,
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10)),
                                child: DropdownButton<String>(
                                  value: controller.hrtComm.port,
                                  onChanged: controller.connectNotifier.value ==
                                          "CONNECTED"
                                      ? null
                                      : (String? novoItemSelecionado) {
                                          if (novoItemSelecionado != null) {
                                            controller.hrtComm.port =
                                                novoItemSelecionado;
                                            setState(() {});
                                          }
                                        },
                                  underline: Container(),
                                  iconEnabledColor: Colors.black,
                                  dropdownColor:
                                      Theme.of(context).colorScheme.surface,
                                  focusColor:
                                      Theme.of(context).colorScheme.surface,
                                  selectedItemBuilder: (BuildContext context) {
                                    return controller.hrtComm.availablePorts
                                        .map((String value) {
                                          return Text(
                                            value,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          );
                                        })
                                        .toList()
                                        .cast<Widget>();
                                  },
                                  items: controller.hrtComm.availablePorts
                                      .map((String dropDownStringItem) {
                                        return DropdownMenuItem<String>(
                                          value: dropDownStringItem,
                                          child: Text(
                                            dropDownStringItem,
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
                              ),
                              CustomButton(
                                title: "CONNECTED",
                                titleOff: "DISCONNECTED",
                                initialValue: "DISCONNECTED",
                                groupValue: controller.connectNotifier,
                                onChanged: (e) {
                                  if (e == 'CONNECTED') {
                                    controller.textController.text = "";
                                    controller.hrtComm.funcRead =
                                        controller.readHrtFrame;
                                    if (!controller.hrtComm.connect()) {
                                      Future.delayed(
                                              const Duration(milliseconds: 500))
                                          .then(
                                        (value) {
                                          controller.connectNotifier.value =
                                              "DISCONNECTED";
                                          setState(() {});
                                        },
                                      );
                                    }
                                  } else {
                                    controller.hrtComm.disconnect();
                                  }
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          const CustomTable(),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 20, top: 10, right: 20, bottom: 10),
                            height: 200,
                            color: Colors.white,
                            child: TextField(
                              readOnly: true,
                              controller: controller.textController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Set this
                              expands: true, // and this
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                                labelText: 'Log de Eventos',
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 140,
                                child: RadioListTile<String>(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: const Text('Master'),
                                  value: '01',
                                  groupValue: controller.masterSlave,
                                  onChanged: (String? value) {
                                    setState(() {
                                      controller.masterSlave = value!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: RadioListTile<String>(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0.0),
                                  title: const Text('Slave'),
                                  value: '00',
                                  groupValue: controller.masterSlave,
                                  onChanged: (String? value) {
                                    setState(() {
                                      controller.masterSlave = value!;
                                    });
                                  },
                                ),
                              ),
                              const Text("Command: "),
                              SizedBox(
                                width: 80, //
                                height: 35,
                                child: TextField(
                                  textAlign: TextAlign.justify,
                                  controller: controller.commandController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                              ),
                              CustomButton(
                                title: "SEND",
                                initialValue: "",
                                groupValue: controller.sendNotifier,
                                onChanged: controller.connectNotifier.value ==
                                        "CONNECTED"
                                    ? (e) async {
                                        controller.masterMode(
                                            controller.commandController.text);
                                        await Future.delayed(
                                                const Duration(seconds: 1))
                                            .then(
                                          (value) {
                                            controller.sendNotifier.value =
                                                controller.sendNotifier.value ==
                                                        "SEND"
                                                    ? ""
                                                    : "SEND";
                                            controller.commandController.text =
                                                "";
                                          },
                                        );
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
