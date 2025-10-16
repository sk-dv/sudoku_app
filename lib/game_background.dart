import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/game_step.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';

import 'sudoku_game_screen.dart';
import 'widgets/pause_modal.dart';
import 'widgets/victory_modal.dart';

class GameBackground extends StatelessWidget {
  const GameBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SudokuGameCubit, SudokuGameState>(
          listenWhen: (prev, next) => prev.step != next.step,
          listener: (context, state) {
            if (state.step == GameStep.stop) {
              showModalBottomSheet(
                context: context,
                builder: (context) => const TokenSelector(),
              ).whenComplete(context.read<SudokuGameCubit>().toggleGame);
            }
          },
        ),
        BlocListener<SudokuBoardCubit, SudokuBoardState>(
          listenWhen: (prev, next) =>
              prev.gameModel?.isCompleted != next.gameModel?.isCompleted,
          listener: (context, state) {
            if (state.gameModel?.isCompleted == true) {
              context.read<SudokuGameCubit>().stopTimer();
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                enableDrag: false,
                builder: (context) => const VictoryModal(),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<SudokuGameCubit, SudokuGameState>(
        builder: (context, state) {
          return SudokuGameScreen(
            type: state.type,
          );
        },
      ),
    );
  }
}
