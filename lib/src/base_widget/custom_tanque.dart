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
      child: LayoutBuilder(
        builder: (context, constraints) {
          var heightValue = constraints.maxHeight - 50;
          return AnimatedBuilder(
            animation: controller.hrtTransmitter,
            builder: (context, child) {
              var _currentLevel = controller
                  .hrtTransmitter.funcValues[widget.varkey]!.funcValue;
              if (_currentLevel >= 100) {
                controller.tankTransfFunction.reestart();
                _currentLevel = 0.0;
              }
              return Container(
                width: 300,
                height: constraints.maxHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 200,
                      height: heightValue,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Visor de nível
                    Container(
                      width: 200, // Largura do líquido
                      height: (_currentLevel / 100) *
                          heightValue, // Altura do nível
                      decoration: BoxDecoration(
                        color: Colors.blue, // Cor do líquido
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Texto para mostrar o nível
                    Positioned(
                      bottom: (_currentLevel / 100) * heightValue + 10,
                      child: Text(
                        '${_currentLevel.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        "assets/trans_nivel.png",
                        scale:8,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
