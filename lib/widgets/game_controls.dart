import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/shadow_button.dart';

/// Widget que muestra los controles encima del tablero
class GameControls extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHints;
  final int hintsCount;

  const GameControls({
    super.key,
    required this.onBack,
    required this.onHints,
    this.hintsCount = 3,
  });

  /// Helper para crear botones de control reutilizables
  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    int? badgeCount,
  }) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        final style = state.style;

        return ShadowButton(
          containerSize: const (50, 50),
          shadowSize: const (45, 45),
          restSpace: 4,
          pressedSpace: 2,
          radius: 8,
          shadowOffset: const Offset(0, 3),
          shadowColor: style.flatColor.withValues(alpha: 0.3),
          onPressed: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: style.background,
              border: Border.all(color: style.borderColor, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(icon, color: style.flatColor, size: 24),
                ),
                // Badge opcional
                if (badgeCount != null)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: style.flatColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            color: style.background,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Brick Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Back
          _buildControlButton(
            context: context,
            icon: Icons.home_rounded,
            onPressed: onBack,
          ),

          const SizedBox(width: 32),

          // Botón Hints con badge
          _buildControlButton(
            context: context,
            icon: Icons.lightbulb_rounded,
            onPressed: onHints,
            badgeCount: hintsCount,
          ),
        ],
      ),
    );
  }
}
