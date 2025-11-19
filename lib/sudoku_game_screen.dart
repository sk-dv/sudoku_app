import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/cubit/game_coordinator_cubit.dart';
import 'package:sudoku_app/models/game_progress.dart';
import 'package:sudoku_app/widgets/keyboard_mode.dart';
import 'package:sudoku_app/widgets/sudoku_board.dart';
import 'package:sudoku_app/widgets/game_controls.dart';
import 'package:sudoku_app/widgets/custom_toast.dart';

import 'models/token_type.dart';

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

        return Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
                  builder: (context, state) {
                    return GameControls(
                      onSave: () async {
                        await context.read<GameCoordinatorCubit>().saveGame(
                              state.gameModel,
                              GameSource.level,
                            );
                        if (context.mounted) {
                          showCustomToast(
                            context,
                            'GUARDADO',
                            icon: Icons.check_circle_rounded,
                          );
                        }
                      },
                      onHints: context.read<SudokuBoardCubit>().useHint,
                      hintsCount: state.gameModel.hintsRemaining,
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
