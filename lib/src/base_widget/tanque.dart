import 'package:flutter/material.dart';

class Tanque extends StatelessWidget {
  const Tanque({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _heightValue = constraints.maxHeight;
        final _widthValue = constraints.maxWidth;
        return Center(
          child: CustomPaint(
            size: Size(
              _widthValue >= 737.0 ? 380.0 : _widthValue - 357.0,
              _heightValue, // Definindo a altura com base na tela
            ),
            painter: TankPainter(),
          ),
        );
      },
    );
  }
}

class TankPainter extends CustomPainter {
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
        size.height * 0.1; // 10% da altura para as tampas superior e inferior
    final bodyHeight = size.height -
        (2 *
            topBottomHeight); // Altura do corpo, o restante da altura disponível

    // Desenho do corpo do tanque (cilindro)
    final rect = Rect.fromLTWH(
        size.width * 0.2, topBottomHeight, size.width * 0.6, bodyHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(10));
    canvas.drawRRect(rrect, paint);

    // Desenho das linhas de solda
    final weldPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Soldas horizontais (linhas de solda espaçadas proporcionalmente)
    for (int i = 1; i < 4; i++) {
      final y = topBottomHeight + (i * (bodyHeight / 4));
      canvas.drawLine(
          Offset(size.width * 0.2, y), Offset(size.width * 0.8, y), weldPaint);
    }

    // Visor de nível (base)
    final levelGauge = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Visor lateral
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.65, topBottomHeight + 20, 10, bodyHeight - 40),
        levelGauge);

    // Nível de líquido dentro do visor
    final liquidLevel1 = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.65, topBottomHeight + 20, 10, bodyHeight - 40),
        liquidLevel1);

    // Nível de líquido dentro do visor
    final liquidLevel = Paint()..color = Colors.blue;
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.65, topBottomHeight + bodyHeight / 2, 10,
            bodyHeight / 2 - 20),
        liquidLevel);

    // Pés do tanque
    final footPaint = Paint()..color = Colors.grey[600]!;

    // Ajustando os pés para tocar o bottom
    final footWidth = 30.0;
    final footHeight = size.height * 0.1; // Altura dos pés 10% da altura total
    final footYPosition =
        size.height - footHeight; // Posição Y dos pés no bottom

    // Pés esquerdo e direito do tanque
    final footRect1 = Rect.fromLTWH(size.width * 0.3, footYPosition, footWidth,
        footHeight); // Pé esquerdo mais centralizado
    final footRect2 = Rect.fromLTWH(
        size.width * 0.6, footYPosition, footWidth, footHeight); // Pé direito
    canvas.drawRect(footRect1, footPaint);
    canvas.drawRect(footRect2, footPaint);

    // Desenho da tampa superior
    final topCapPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.grey[400]!, Colors.grey[600]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final topCapRect = Rect.fromLTWH(
        size.width * 0.2, size.height*0.1- (size.height * 0.1 / 2)+5, size.width * 0.6, size.height*0.1);
    canvas.drawOval(topCapRect, topCapPaint);

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
        size.height - footHeight - (size.height * 0.1 / 2)-5,
        size.width * 0.6,
        size.height * 0.1);
    canvas.drawOval(bottomCapRect, bottomCapPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
