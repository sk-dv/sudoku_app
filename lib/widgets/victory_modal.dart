import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/context_utils.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

class VictoryModal extends StatelessWidget {
  const VictoryModal({super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.read<SudokuGameCubit>().state.style;
    final elapsedTime = context.read<SudokuGameCubit>().state.elapsedSeconds;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: style.successCell,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 35,
              color: style.background,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¡FELICIDADES!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: style.selectedCell,
              fontFamily: 'Brick Sans',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Has completado el sudoku',
            style: TextStyle(
              fontSize: 16,
              color: style.borderColor,
              fontFamily: 'Brick Sans',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: style.cellColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: style.selectedCell.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: style.selectedCell,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatTime(elapsedTime),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: style.selectedCell,
                    fontFamily: 'Brick Sans',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.read<SudokuGameCubit>().back();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: style.selectedCell,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_rounded,
                    color: style.background,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'VOLVER AL MENÚ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: style.background,
                      fontFamily: 'Brick Sans',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.height * 0.05),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
