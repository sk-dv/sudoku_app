import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/widgets/keyboard_mode.dart';
import 'package:sudoku_app/widgets/sudoku_board.dart';
import 'package:sudoku_app/widgets/game_controls.dart';

import 'models/token_type.dart';

class SudokuGameScreen extends StatelessWidget {
  const SudokuGameScreen({super.key, required this.type});

  final TokenType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
                  builder: (context, state) {
                    final hintsRemaining = state.gameModel.hintsRemaining;
                    return GameControls(
                      onHints: () {
                        if (hintsRemaining > 0) {
                          context.read<SudokuBoardCubit>().useHint();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No hay pistas disponibles'),
                            ),
                          );
                        }
                      },
                      hintsCount: hintsRemaining,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Tablero
                const SudokuBoard(),
                const SizedBox(height: 20),

                // Teclado
                ImageKeyboard(type: type),
              ],
            ),
          ),
        );
      },
    );
  }
}
