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
      padding: const EdgeInsets.only(left: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          var _heightValue = constraints.maxHeight - 50;
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
                width: 360,
                height: constraints.maxHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child: Container(
                        width: 200,
                        height: _heightValue,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Visor de nível
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child:Container(
                      width: 200, // Largura do líquido
                      height: (_currentLevel / 100) *
                          _heightValue, // Altura do nível
                      decoration: BoxDecoration(
                        color: Colors.blue, // Cor do líquido
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        "assets/trans_nivel.png",
                        scale: 8,
                        alignment: Alignment.center,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Image.asset(
                        "assets/bomba.png",
                        scale: 2,
                        alignment: Alignment.center,
                      ),
                    ),
                    _buildIndicador(_currentLevel, _heightValue),
                    _buildSlider(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Texto para mostrar o nível
  Widget _buildIndicador(double _currentLevel, double _heightValue) {
    return Positioned(
      left: 200,
      bottom: (_currentLevel / 100) * _heightValue + 10,
      child: Text(
        '${_currentLevel.toStringAsFixed(1)}%',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Positioned(
      bottom: 70,
      left: 30,
      top: 30, // Adiciona o top para esticar o slider verticalmente
      child: ValueListenableBuilder<double>(
        valueListenable: controller.plantInputValue,
        builder: (context, value, child) => Center(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona o slider para a posição vertical
            child: Align(
              alignment: Alignment
                  .centerLeft, // Garante que ocupe a altura total possível
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                onChanged: (newValue) =>
                    controller.plantInputValue.value = newValue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
