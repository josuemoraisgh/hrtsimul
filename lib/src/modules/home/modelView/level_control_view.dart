import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../home_controller.dart';
import '../../../base_widget/custom_tank.dart';

class LevelControlView extends StatefulWidget {
  final String varkey;

  LevelControlView(this.varkey) {}

  @override
  _LevelControlViewState createState() => _LevelControlViewState();
}

class _LevelControlViewState extends State<LevelControlView> {
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
                //alignment: Alignment.bottomCenter,
                children: [
                  // Tanque
                  Center(
                    child: CustomPaint(
                      size: Size(
                        _widthTanque,
                        _heightValue, // Definindo a altura com base na tela
                      ),
                      painter: TankPainter(currentLevel: _currentLevel),
                    ),
                  ),
                  Positioned(
                    bottom: _heightValue * 0.06,
                    right: _widthValue / 2 - _widthTanque * 0.45,
                    child: Image.asset(
                      "assets/trans_nivel.png",
                      scale: 6,
                      alignment: Alignment.center,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: _widthValue / 2 - _widthTanque * 0.8,
                    child: Image.asset(
                      "assets/bomba_centrifuga.png",
                      scale: 2.0,
                      alignment: Alignment.center,
                    ),
                  ),
                  _buildIndicador(
                      _currentLevel, _widthValue / 2, _heightValue / 2),
                  _buildSlider(
                    controller.plantInputValue,
                    "Ajuste da\nVazão da Bomba",
                    _widthValue / 2 - _widthTanque * 0.7,
                    130,
                  ),
                  _buildSlider(
                      controller.tankLeakValue,
                      "Ajuste da\nVazão de Saída",
                      _widthValue / 2 + _widthTanque * 0.55,
                      _heightValue * 0.1,
                      min: 0.0000000001),
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

  Widget _buildSlider(ValueListenable<double> valueListenable, String text,
      double _posLeft, double bottom,
      {final double min = 0, final double max = 10}) {
    return Positioned(
      bottom: bottom,
      left: _posLeft,
      child: ValueListenableBuilder<double>(
        valueListenable: valueListenable,
        builder: (context, value, child) => Center(
          child: Column(
            children: [
              Text(
                "${value.toStringAsFixed(2)}\n l/h",
                style: TextStyle(
                  fontFamily: 'Source Sans Pro', // Fonte utilizada
                  fontSize: 16, // Tamanho da fonte
                ),
              ),
              RotatedBox(
                quarterTurns: 3, // Mantém o slider na vertical
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: (newValue) =>
                        controller.plantInputValue.value = newValue,
                  ),
                ),
              ),
              Text(
                text, // Texto a ser exibido
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, // Tamanho da fonte do texto
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
