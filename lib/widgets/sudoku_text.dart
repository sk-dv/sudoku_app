import 'package:flutter/material.dart';

class SudokuText3D extends StatelessWidget {
  final double fontSize;
  final Color primaryColor;
  final Color shadowColor;
  final Color accentColor;

  const SudokuText3D({
    Key? key,
    this.fontSize = 48,
    this.primaryColor = const Color(0xFFFFEB3B), 
    this.shadowColor = const Color(0xFFE91E63), 
    this.accentColor = const Color(0xFFFF5722), 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 4,
          child: _buildPixelText('SUDOKU', shadowColor),
        ),
        Positioned(
          left: 6,
          top: 6,
          child: _buildPixelText('SUDOKU', shadowColor.withValues(alpha: 0.7)),
        ),
        // Texto principal
        _buildPixelText('SUDOKU', primaryColor),
        // Detalles en color de acento
        Positioned(
          left: 2,
          top: 2,
          child: _buildAccentDetails(),
        ),
      ],
    );
  }

  Widget _buildPixelText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color,
        fontFamily: 'monospace',
        letterSpacing: 4,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentDetails() {
    return CustomPaint(
      size: Size(fontSize * 6, fontSize * 1.2),
      painter: PixelDetailsPainter(accentColor),
    );
  }
}

// Painter para agregar detalles pixelados al texto
class PixelDetailsPainter extends CustomPainter {
  final Color color;

  PixelDetailsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Agregar algunos detalles pixelados
    final pixelSize = size.height * 0.08;

    // Detalles en la S
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.02, size.height * 0.2, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.4, pixelSize, pixelSize),
      paint,
    );

    // Detalles en la U
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.18, size.height * 0.15, pixelSize, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.28, size.height * 0.35, pixelSize, pixelSize),
      paint,
    );

    // Detalles en la D
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.38, size.height * 0.25, pixelSize, pixelSize),
      paint,
    );

    // Detalles en la O
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.52, size.height * 0.3, pixelSize, pixelSize),
      paint,
    );

    // Detalles en la K
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.68, size.height * 0.2, pixelSize, pixelSize),
      paint,
    );

    // Detalles en la U final
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.82, size.height * 0.4, pixelSize, pixelSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
