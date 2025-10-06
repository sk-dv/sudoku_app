import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

/// Tarjeta flotante con estilo 8-bit glassmorphism
class FloatingCard extends StatelessWidget {
  const FloatingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.elevation = 8,
  });

  final Widget child;
  final EdgeInsets padding;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        final isDark = state.style.mode.isDark;

        return Container(
          margin: EdgeInsets.all(elevation),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Sombra pixelada estilo 8-bit
              BoxShadow(
                color: (isDark
                    ? Colors.black.withValues(alpha:0.4)
                    : const Color(0xFF880E4F).withValues(alpha:0.3)),
                offset: Offset(elevation, elevation),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF2A2A4E).withValues(alpha:0.85),
                          const Color(0xFF1A1A3E).withValues(alpha:0.85),
                        ]
                      : [
                          const Color(0xFFFFE5E5).withValues(alpha:0.9),
                          const Color(0xFFFFF0E5).withValues(alpha:0.9),
                        ],
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha:0.1)
                      : const Color(0xFF880E4F).withValues(alpha:0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: padding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
