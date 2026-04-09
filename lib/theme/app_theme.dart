import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  // ── Dark palette ──────────────────────────────────────────────────────────
  static const darkBg = Color(0xFF0D0D1A);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkText = Color(0xFFFFFBF0);
  static const darkTextMuted = Color(0x8AFFFBF0); // ~54%

  // ── Light palette ─────────────────────────────────────────────────────────
  static const lightBg = Color(0xFFE8E3DB);
  static const lightSurface = Color(0xFFFFFBF0);
  static const lightText = Color(0xFF1A1A2E);
  static const lightTextMuted = Color(0x8A1A1A2E); // ~54%

  // ── Login background gradients ────────────────────────────────────────────
  static const loginDarkTop = Color(0xFF0D0D1A);
  static const loginDarkBottom = Color(0xFF1A1A2E);
  static const loginLightTop = Color(0xFFCBC5BB);
  static const loginLightBottom = Color(0xFFDDD8D0);

  // ── Shared ────────────────────────────────────────────────────────────────
  static const accent = Color(0xFFFFC759);
  static const error = Color(0xFFFF5E5B);
}

class AppTheme {
  static TextTheme _textTheme(Brightness brightness) {
    final color =
        brightness == Brightness.dark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;

    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.bold, fontSize: 57),
      displayMedium: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.bold, fontSize: 45),
      displaySmall: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.bold, fontSize: 36),
      headlineLarge: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.w600, fontSize: 28),
      headlineSmall: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.w600, fontSize: 24),
      titleLarge: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.w600, fontSize: 22),
      titleMedium: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.w500, fontSize: 16),
      titleSmall: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge: GoogleFonts.spaceGrotesk(color: color, fontSize: 16),
      bodyMedium: GoogleFonts.spaceGrotesk(color: color, fontSize: 14),
      bodySmall: GoogleFonts.spaceGrotesk(color: mutedColor, fontSize: 12),
      labelLarge: GoogleFonts.spaceGrotesk(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 1.2),
      labelMedium: GoogleFonts.spaceGrotesk(
          color: color, fontWeight: FontWeight.w500, fontSize: 12, letterSpacing: 0.8),
      labelSmall: GoogleFonts.spaceGrotesk(
          color: mutedColor, fontSize: 11, letterSpacing: 0.5),
    );
  }

  static ThemeData light() {
    const cs = ColorScheme.light(
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      primary: AppColors.lightText,
      onPrimary: AppColors.lightSurface,
      secondary: AppColors.accent,
      onSecondary: AppColors.lightText,
      error: AppColors.error,
      onError: AppColors.lightSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _textTheme(Brightness.light),
    );
  }

  static ThemeData dark() {
    const cs = ColorScheme.dark(
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      primary: AppColors.darkText,
      onPrimary: AppColors.darkBg,
      secondary: AppColors.accent,
      onSecondary: AppColors.darkBg,
      error: AppColors.error,
      onError: AppColors.darkBg,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _textTheme(Brightness.dark),
    );
  }
}
