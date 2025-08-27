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

  const SudokuGrid({
    super.key,
    required this.boardObject,
    required this.onCellTap,
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
              return Container(
                decoration: BoxDecoration(
                  color: style.background.withValues(alpha: 1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: style.background, width: 3),
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
