import 'package:flutter/material.dart';

enum ColorMode {
  light,
  dark;

  bool get isDark => this == ColorMode.dark;
}

abstract class SudokuStyle {
  ColorMode get mode;
  Color get background;
  Color get borderColor;
  Color get selectedCell;
  Color get flatColor;
  Color get cellColor;
  Color get pixelRed;
  Color get topBackground;
  Color get bottomBackground;
  Color get themeColor;
  IconData get themeIcon;
}

class SudokuDarkStyle implements SudokuStyle {
  @override
  ColorMode get mode => ColorMode.dark;

  @override
  Color background = const Color(0xFF1A1A2E);
  @override
  Color borderColor = const Color(0xFF6B6B8A);
  @override
  Color selectedCell = const Color(0xFF5A67D8);
  @override
  Color flatColor = const Color(0xFFB794F6);
  @override
  Color cellColor = const Color(0xFF9C8B7A);
  @override
  Color pixelRed = const Color(0xFFF687B3);
  @override
  Color get topBackground => const Color(0xFF0F0F23);
  @override
  Color get bottomBackground => const Color(0xFF1E1E3F);

  @override
  Color get themeColor => bottomBackground;

  @override
  IconData get themeIcon => Icons.dark_mode;
}

class SudokuLightStyle implements SudokuStyle {
  @override
  ColorMode get mode => ColorMode.light;

  @override
  Color get background => const Color(0xFFFFFBF0);
  @override
  Color get borderColor => const Color(0xFF2D2D2D);
  @override
  Color get selectedCell => const Color(0xFF4A90E2);
  @override
  Color get flatColor => const Color(0xFFFF6B9D);
  @override
  Color get cellColor => const Color(0xFFFFC759);
  @override
  Color get pixelRed => const Color(0xFFFF5E5B);
  @override
  Color get topBackground => const Color(0xFF68B0AB);
  @override
  Color get bottomBackground => const Color(0xFF8FC0A9);

  @override
  Color get themeColor => cellColor;

  @override
  IconData get themeIcon => Icons.light_mode;
}
