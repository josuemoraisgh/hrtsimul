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
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final _heightValue = constraints.maxHeight;
          final _widthValue = constraints.maxWidth;
          final _widthTanque =
              _widthValue >= 737.0 ? 380.0 : _widthValue - 357.0;

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
                  _buildTanque(width: _widthTanque, height: _heightValue),
                  // Visor de nível
                  _buildVisor(
                      level: _currentLevel,
                      width: _widthTanque,
                      height: _heightValue),
                  Positioned(
                    bottom: 0,
                    right: _widthValue / 2 - _widthTanque,
                    child: Image.asset(
                      "assets/trans_nivel.png",
                      scale: 6,
                      alignment: Alignment.center,
                    ),
                  ),
                  _buildTubulacao(
                    left: (_widthValue - _widthTanque) / 2 + 100 - 40,
                    bottom: 54,
                    width: 40,
                    height: 20,
                  ),
                  Positioned(
                    bottom: 0,
                    left: _widthValue / 2 - _widthTanque,
                    child: Image.asset(
                      "assets/bomba_centrifuga.png",
                      scale: 2.0,
                      alignment: Alignment.center,
                    ),
                  ),
                  _buildIndicador(_currentLevel, (_widthValue + 100) / 2 + 45,
                      _heightValue / 2),
                  _buildSlider((_widthValue - _widthTanque) / 2 - 100),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTanque({final double width = 0, final double height = 0}) {
    return Padding(
      padding: const EdgeInsets.only(left: 200, bottom: 50),
      child: Container(
        width: width,
        height: height - 70,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.grey[600]!, Colors.grey[400]!, Colors.grey[600]!],
          ),
          border: Border.all(color: Colors.blueGrey, width: 2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(5, 5), // posição da sombra
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisor(
      {final double level = 0,
      final double width = 0,
      final double height = 0}) {
    return Padding(
      padding: const EdgeInsets.only(left: 200, bottom: 50),
      child: Container(
        width: width,
        height: (level / 100) * (height - 70), // Altura do nível
        decoration: BoxDecoration(
          color: Colors.blue, // Cor do líquido
          //borderRadius: BorderRadius.circular(10),
          border: Border(
            right: BorderSide(
              color: Colors.blueGrey, // Cor da borda superior
              width: 2.0, // Espessura da borda superior
            ),
            left: BorderSide(
              color: Colors.blueGrey, // Cor da borda superior
              width: 2.0, // Espessura da borda superior
            ),
            bottom: BorderSide(
              color: Colors.blueGrey, // Cor da borda inferior
              width: 2.0, // Espessura da borda inferior
            ),
          ),
        ),
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

  // Texto para mostrar o nível
  Widget _buildTubulacao({
    double left = 0,
    double bottom = 0,
    double width = 0,
    double height = 0,
  }) {
    return Positioned(
      bottom: bottom, // 34,
      left: left, //144,
      child: Container(
        width: width, //52, // Largura do líquido
        height: height, //20, // Altura do nível
        decoration: BoxDecoration(
          color: Colors.grey[700],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[600]!, Colors.grey[400]!, Colors.grey[600]!],
          ),
          border: Border(
            top: BorderSide(
              color: Colors.blueGrey, // Cor da borda superior
              width: 2.0, // Espessura da borda superior
            ),
            bottom: BorderSide(
              color: Colors.blueGrey, // Cor da borda inferior
              width: 2.0, // Espessura da borda inferior
            ),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
          ),
        ),
      ),
    );
  }
}
