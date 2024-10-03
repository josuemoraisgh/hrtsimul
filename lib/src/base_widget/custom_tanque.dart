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
          var _heightValue = constraints.maxHeight - 50;
          var widthValue = constraints.maxWidth;
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
                width: widthValue,
                height: constraints.maxHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 90),
                      child: Container(
                        width: widthValue - 250,
                        height: _heightValue,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                    ),
                    // Visor de nível
                    Padding(
                      padding: const EdgeInsets.only(left: 90),
                      child: Container(
                        width: widthValue - 250, // Largura do líquido
                        height: (_currentLevel / 100) *
                            _heightValue, // Altura do nível

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
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        "assets/trans_nivel.png",
                        scale: 6,
                        alignment: Alignment.center,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Image.asset(
                        "assets/bomba.png",
                        scale: 1.5,
                        alignment: Alignment.center,
                      ),
                    ),
                    Positioned(
                      bottom: 34,
                      left: 144,
                      child: Container(
                        width: 28, // Largura do líquido
                        height: 20, // Altura do nível
                        decoration: BoxDecoration(
                          color: Colors.blue,
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
