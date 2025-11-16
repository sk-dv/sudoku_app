import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/models/sudoku_object.dart';
import 'package:sudoku_app/widgets/sudoku_grid.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
      builder: (context, state) {
        final gameModel = state.gameModel;

        // Convertir SudokuGameModel a List<List<SudokuObject>>
        final board = List.generate(
          9,
          (i) => List.generate(
            9,
            (j) => SudokuObject(
              value: gameModel.board[i][j],
              isOriginal: gameModel.isOriginal[i][j],
              isSelected: gameModel.isSelected[i][j],
              isHighlighted: gameModel.isHighlighted[i][j],
              isError: gameModel.isErrorCell[i][j],
            ),
          ),
        );

        return SudokuGrid(
          boardObject: board,
          isCompleted: gameModel.isCompleted,
          onCellTap: context.read<SudokuBoardCubit>().selectCell,
        );
      },
    );
  }
}
