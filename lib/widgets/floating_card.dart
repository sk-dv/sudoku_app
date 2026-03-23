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
        final shadowColor = isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.18);

        return Container(
          margin: EdgeInsets.only(
            right: elevation / 2,
            bottom: elevation / 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: Offset(elevation / 2, elevation / 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C2E)
                    : Colors.white,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.07),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
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
