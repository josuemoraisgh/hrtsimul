import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../modules/home/home_controller.dart';
import 'tanque.dart';

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
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final _heightValue = constraints.maxHeight;
          final _widthValue = constraints.maxWidth;
          final _widthTanque =
              _widthValue >= 760.0 ? 500.0 : _widthValue - 260.0;
          return AnimatedBuilder(
            animation: controller.hrtTransmitter,
            builder: (context, child) {
              var _currentLevel = controller
                  .hrtTransmitter.funcValues[widget.varkey]!.funcValue;
              if (_currentLevel >= 100) {
                controller.tankTransfFunction.reestart();
                _currentLevel = 0.0;
              }
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Tanque
                  Tanque(currentLevel: _currentLevel),
                  Positioned(
                    bottom: _heightValue*0.05,
                    right: _widthValue/2 - _widthTanque * 0.45,
                    child: Image.asset(
                      "assets/trans_nivel.png",
                      scale: 6,
                      alignment: Alignment.center,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: _widthValue/2 -_widthTanque*0.8,
                    child: Image.asset(
                      "assets/bomba_centrifuga.png",
                      scale: 2.0,
                      alignment: Alignment.center,
                    ),
                  ),
                  _buildIndicador(_currentLevel, _widthValue/2,
                      _heightValue / 2),
                  _buildSlider( _widthValue/2 -_widthTanque*0.6),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Texto para mostrar o nível
  Widget _buildIndicador(
      double _currentLevel, double _posLeft, double _posBottom) {
    return Positioned(
      left: _posLeft,
      bottom: _posBottom,
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

  Widget _buildSlider(double _posLeft) {
    return Positioned(
      bottom: 150,
      left: _posLeft,
      child: ValueListenableBuilder<double>(
        valueListenable: controller.plantInputValue,
        builder: (context, value, child) => Center(
          child: Column(
            children: [
              Text(
                "${value.toStringAsFixed(2)}\n l/h",
                style: TextStyle(
                  fontFamily: 'Source Sans Pro', // Coloque o nome da fonte aqui
                  fontSize: 16, // Altere o tamanho da fonte conforme necessário
                ),
              ),
              RotatedBox(
                quarterTurns: 3, // Rotaciona o slider para a posição vertical
                child: Align(
                  alignment: Alignment
                      .centerLeft, // Garante que ocupe a altura total possível
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 10,
                    onChanged: (newValue) =>
                        controller.plantInputValue.value = newValue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
