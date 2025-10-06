import 'package:flutter/material.dart';

class TextShadow extends StatelessWidget {
  const TextShadow({
    super.key,
    required this.text,
    required this.mainColor,
    this.fontSize = 45,
  });

  final String text;
  final Color mainColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 4,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.black.withValues(alpha: 0.3),
              fontFamily: 'Brick Sans',
              letterSpacing: 7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            color: mainColor,
            fontFamily: 'Brick Sans',
            letterSpacing: 7,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
