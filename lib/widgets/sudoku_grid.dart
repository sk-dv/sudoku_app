import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/data/sudoku_object.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/cell.dart';
import 'package:sudoku_app/widgets/grid.dart';

class SudokuGrid extends StatelessWidget {
  final List<List<SudokuObject>> boardObject;
  final Function(int, int) onCellTap;
  final bool isCompleted;

  const SudokuGrid({
    super.key,
    required this.boardObject,
    required this.onCellTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
            selector: (state) => state.style,
            builder: (context, style) {
              final borderColor = isCompleted
                  ? style.successCell
                  : style.background;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  color: style.background.withValues(alpha: 1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: style.successCell.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Grid(
                  builder: (row, col) {
                    return Cell(
                      row: row,
                      col: col,
                      sudokuObject: boardObject[row][col],
                      onCellTap: onCellTap,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
