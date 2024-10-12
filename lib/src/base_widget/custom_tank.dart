import 'package:flutter/material.dart';

class TankPainter extends CustomPainter {
  final double currentLevel;
  TankPainter({super.repaint, required this.currentLevel});

  @override
  void paint(Canvas canvas, Size size) {
    // Joelho de conexão 1
    elbowPipePainter(
      canvas,
      left: 150,
      top: size.height - 111,
      giro: 0,
    );
    // Tubo da conexão 1
    pipePainter(
      canvas,
      left: 101,
      top: size.height - 73,
      pipeWidth: 77,
      pipeHeight: 14.5,
    );
    // Tubo da conexão 1
    pipePainter(
      canvas,
      left: 188,
      top: size.height - 148,
      pipeWidth: 14.5,
      pipeHeight: 60,
    );
    // Joelho de conexão 2
    elbowPipePainter(
      canvas,
      left: 305,
      top: size.height * 0.94 - 75,
      giro: 1,
    );
    // Tubo da conexão 2
    pipePainter(
      canvas,
      left: 325,
      top: size.height * 0.94 - 37,
      pipeWidth: 110,
      pipeHeight: 14.5,
    );
    // Tubo da conexão 2
    pipePainter(
      canvas,
      left: 298,
      top: size.height * 0.94 - 110,
      pipeWidth: 14.5,
      pipeHeight: 60,
    );

    // Joelho de conexão 3
    elbowPipePainter(
      canvas,
      left: size.width / 2,
      top: size.height * 0.94 - 35,
      giro: 1,
    );
    // Tubo da conexão 3B
    pipePainter(
      canvas,
      left: size.width / 2 + 18,
      top: size.height * 0.94 + 3,
      pipeWidth: 300,
      pipeHeight: 14.5,
    );

    // Adicionando a seta ao final do tubo da conexão 3B
    drawArrow(
      canvas,
      startX: size.width / 2 + 318, // Posição final do tubo
      startY: size.height * 0.94 + 3 + 7, // Ajuste para centralizar a seta
      arrowLength: 50, // Tamanho da seta
    );

    // Tubo da conexão 3
    pipePainter(
      canvas,
      left: size.width / 2 - 7,
      top: size.height * 0.94 - 110,
      pipeWidth: 14.5,
      pipeHeight: 100,
    );
    // Desenho do tank
    tankPaint(canvas, size);
    // Visor de nível
    levelGaugePaint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void tankPaint(Canvas canvas, Size size) {
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

    final footWidth = 30.0;
    final footHeight = size.height * 0.2;
    final footYPosition = size.height - footHeight;

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
    final bodyTankPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.grey[300]!, Colors.grey[400]!, Colors.grey[500]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rect = Rect.fromLTWH(
        size.width * 0.2, topBottomHeight, size.width * 0.6, bodyHeight);
    canvas.drawRect(rect, bodyTankPaint);

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
  }

  void levelGaugePaint(Canvas canvas, Size size) {
    // Definindo as proporções de altura e largura
    final topBottomHeight =
        size.height * 0.11; // 11% da altura para as tampas superior e inferior
    final bodyHeight =
        size.height - (2 * size.height * 0.16); // Altura do corpo

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

  void elbowPipePainter(
    Canvas canvas, {
    final double left = 0,
    final double top = 0,
    final double giro = 0,
    final double width = 15,
  }) {
    // Ajustando as tubulações
    final pipePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke // Estilo apenas contorno
      ..strokeWidth = width; // Diâmetro do tubo

    // Definir o path (caminho) apenas para o joelho (curva)
    final path = Path();

    // Criar a curva do tipo "joelho" em arco de 90 graus
    path.arcTo(
      Rect.fromLTWH(left, top, 3 * width, 3 * width),
      switch (giro) {
        0 => 0,
        1 => 1.57,
        2 => 3.14,
        _ => 4.71
      }, // Início do arco (em radianos, 180 graus)
      1.57, // Tamanho do arco (em radianos, 90 graus)
      true,
    );
    // Desenhar o path na tela
    canvas.drawPath(path, pipePaint);
  }

  void pipePainter(
    Canvas canvas, {
    final double left = 0,
    final double top = 0,
    final double pipeWidth = 0,
    final double pipeHeight = 0,
  }) {
    // Ajustando as tubulações
    final pipePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Tubo 1 (esquerda, mais perto da base)
    final pipe1 = Rect.fromLTWH(left, top, pipeWidth, pipeHeight);
    canvas.drawRect(pipe1, pipePaint);
  }

  // Função para desenhar a seta
  void drawArrow(Canvas canvas,
      {required double startX,
      required double startY,
      required double arrowLength}) {
    final arrowPaint = Paint()
      ..color = Colors.red // Cor da seta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Desenho da linha da seta
    final path = Path();
    path.moveTo(startX, startY);
    path.lineTo(startX + arrowLength, startY);

    // Desenho das pontas da seta
    path.moveTo(startX + arrowLength, startY);
    path.lineTo(startX + arrowLength - 10, startY - 10);
    path.moveTo(startX + arrowLength, startY);
    path.lineTo(startX + arrowLength - 10, startY + 10);

    canvas.drawPath(path, arrowPaint);
  }
}
