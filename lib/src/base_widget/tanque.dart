import 'package:flutter/material.dart';

class Tanque extends StatelessWidget {
  final double currentLevel;
  const Tanque({super.key, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _heightValue = constraints.maxHeight;
        final _widthValue = constraints.maxWidth;
        return Center(
          child: CustomPaint(
            size: Size(
              _widthValue >= 760.0 ? 500.0 : _widthValue - 260.0,
              _heightValue, // Definindo a altura com base na tela
            ),
            painter: TankPainter(currentLevel: currentLevel),
          ),
        );
      },
    );
  }
}

class TankPainter extends CustomPainter {
  final double currentLevel;
  TankPainter({super.repaint, required this.currentLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.grey[300]!, Colors.grey[400]!, Colors.grey[500]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Definindo as proporções de altura e largura
    final topBottomHeight =
        size.height * 0.11; // 11% da altura para as tampas superior e inferior
    final bodyHeight =
        size.height - (2 * size.height * 0.16); // Altura do corpo

    // Desenho da tampa superior
    final topCapPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.grey[400]!, Colors.grey[600]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final topCapRect = Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.1 - (size.height * 0.1 / 2) + 5,
        size.width * 0.6,
        size.height * 0.1);
    canvas.drawOval(topCapRect, topCapPaint);

    // Ajustando as tubulações
    final pipePaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    final footWidth = 30.0;
    final footHeight = size.height * 0.2;
    final footYPosition = size.height - footHeight;

    final pipeWidth = 10.0;
    final pipeHeight = 50.0;
    final pipeOffsetY = size.height - footHeight + 10;

    // Tubo 1 (esquerda, mais perto da base)
    final pipe1 =
        Rect.fromLTWH(size.width * 0.35, pipeOffsetY, pipeWidth, pipeHeight);
    canvas.drawRect(pipe1, pipePaint);

    // Tubos 2 e 3 (direita)
    final pipe2 = Rect.fromLTWH(
        size.width * 0.55, pipeOffsetY, pipeWidth, pipeHeight + 30);
    final pipe3 =
        Rect.fromLTWH(size.width * 0.65, pipeOffsetY, pipeWidth, pipeHeight);
    canvas.drawRect(pipe2, pipePaint);
    canvas.drawRect(pipe3, pipePaint);

    // Pés do tanque
    final footPaint = Paint()..color = Colors.grey[600]!;

    final footRect1 = Rect.fromLTWH(
        size.width * 0.24, footYPosition - 5, footWidth, footHeight);
    final footRect2 = Rect.fromLTWH(
        size.width * 0.70, footYPosition - 5, footWidth, footHeight);
    canvas.drawRect(footRect1, footPaint);
    canvas.drawRect(footRect2, footPaint);

    // Desenho da base inferior
    final bottomCapPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.grey[500]!, Colors.grey[700]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final bottomCapRect = Rect.fromLTWH(
        size.width * 0.2,
        size.height - footHeight - (size.height * 0.1 / 2) - 10,
        size.width * 0.6,
        size.height * 0.1);
    canvas.drawOval(bottomCapRect, bottomCapPaint);

    // Desenho do corpo do tanque (cilindro)
    final rect = Rect.fromLTWH(
        size.width * 0.2, topBottomHeight, size.width * 0.6, bodyHeight);
    canvas.drawRect(rect, paint);

    // Desenho das linhas de solda
    final weldPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      final y = topBottomHeight + (i * (bodyHeight / 4));
      canvas.drawLine(
          Offset(size.width * 0.2, y), Offset(size.width * 0.8, y), weldPaint);
    }

    // Visor de nível
    final levelGauge = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.65, topBottomHeight, 10, bodyHeight),
        levelGauge);

    final liquidLevel1 = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.65, topBottomHeight, 10, bodyHeight),
        liquidLevel1);

    final liquidLevel = Paint()..color = Colors.blue;
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.65,
            topBottomHeight + bodyHeight * (100 - currentLevel) / 100,
            10,
            bodyHeight * (currentLevel / 100)),
        liquidLevel);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
