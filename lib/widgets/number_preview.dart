import 'package:flutter/material.dart';

/// Widget que muestra un preview del número mientras está presionado
/// Estilo 8-bit, aparece arriba del botón
class NumberPreview extends StatelessWidget {
  final int number;
  final Offset position;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const NumberPreview({
    super.key,
    required this.number,
    required this.position,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(28), // Muy redondito
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: icon != null
                ? Icon(icon, color: textColor, size: 22)
                : Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'Brick Sans',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Gestor de overlays para el preview de números
class NumberPreviewOverlay {
  static OverlayEntry? _currentEntry;

  /// Muestra el preview del número
  static void show(
    BuildContext context, {
    required int number,
    required Offset position,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
  }) {
    // Remover overlay anterior si existe
    hide();

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (context) => NumberPreview(
        number: number,
        position: position,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
      ),
    );

    overlay.insert(_currentEntry!);
  }

  /// Oculta el preview actual
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
