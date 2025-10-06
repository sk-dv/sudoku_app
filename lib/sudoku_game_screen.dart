import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/widgets/keyboard_mode.dart';
import 'package:sudoku_app/widgets/sudoku_board.dart';

import 'data/token_type.dart';

class SudokuGameScreen extends StatelessWidget {
  const SudokuGameScreen({
    super.key,
    required this.type,
  });

  final TokenType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.gameModel == null) {
          return const Center(child: Text('No hay juego disponible'));
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SudokuBoard(),
                const SizedBox(height: 20),
                ImageKeyboard(type: type),
              ],
            ),
          ),
        );
      },
    );
  }
}
