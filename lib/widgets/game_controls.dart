import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/widgets/shadow_button.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onHints;
  final VoidCallback onSave;
  final int hintsCount;

  const GameControls({
    super.key,
    required this.onHints,
    required this.onSave,
    required this.hintsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ControlButton(icon: Icons.save_rounded, onPressed: onSave),
          Row(
            children: [
              BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
                builder: (context, state) {
                  return _ControlButton(
                    icon: Icons.undo_rounded,
                    onPressed: context.read<SudokuBoardCubit>().undoLastMove,
                    isEnabled: context.read<SudokuBoardCubit>().canUndo,
                    badgeCount: context.read<SudokuBoardCubit>().canUndo
                        ? context.read<SudokuBoardCubit>().undoMovements
                        : null,
                  );
                },
              ),
              const SizedBox(width: 8),
              _ControlButton(
                icon: Icons.lightbulb_rounded,
                onPressed: onHints,
                badgeCount: hintsCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.badgeCount,
    this.isEnabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final int? badgeCount;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        final style = state.style;

        return Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: ShadowButton(
            containerSize: const (50, 50),
            shadowSize: const (45, 45),
            restSpace: 4,
            pressedSpace: 2,
            radius: 8,
            shadowOffset: const Offset(0, 3),
            shadowColor: style.flatColor.withValues(alpha: 0.3),
            onPressed: isEnabled ? onPressed : () {},
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
          ),
        );
      },
    );
  }
}
