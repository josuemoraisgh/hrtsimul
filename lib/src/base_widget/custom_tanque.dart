import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../modules/home/home_controller.dart';

class CustomTank extends StatefulWidget {
  final String varkey;

  CustomTank(this.varkey) {}

  @override
  _CustomTankState createState() => _CustomTankState();
}

class _CustomTankState extends State<CustomTank> {
  final controller = Modular.get<HomeController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        width: 200,
        height: 400,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ValueListenableBuilder(
          valueListenable: controller
              .hrtTransmitter.funcNotifier.value[widget.varkey]!.funcValueNotifier,
          builder: (___, _currentLevel, _) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Visor de nível
                Container(
                  width: 200, // Largura do líquido
                  height: (_currentLevel / 100) * 400, // Altura do nível
                  decoration: BoxDecoration(
                    color: Colors.blue, // Cor do líquido
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Texto para mostrar o nível
                Positioned(
                  bottom: (_currentLevel / 100) * 400 + 10,
                  child: Text(
                    '${_currentLevel.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
