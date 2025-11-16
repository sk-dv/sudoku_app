import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/models/game_step.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

import 'models/sudoku_game_model.dart';
import 'screens/level_selection_screen.dart';
import 'services/sudoku_api_service.dart';
import 'sudoku_game_screen.dart';
import 'widgets/pause_modal.dart';
import 'widgets/victory_modal.dart';

class _SudokuBoardSetup extends StatefulWidget {
  const _SudokuBoardSetup({
    required this.difficulty,
    required this.builder,
    this.game,
  });

  final DifficultLevel difficulty;
  final Widget Function(SudokuGameModel? gameModel) builder;
  final SudokuGameModel? game;

  @override
  State<_SudokuBoardSetup> createState() => _SudokuBoardSetupState();
}

class _SudokuBoardSetupState extends State<_SudokuBoardSetup> {
  SudokuGameModel? gameModel;

  @override
  void initState() {
    if (widget.game != null) {
      gameModel = widget.game;
    } else {
      SudokuApiService.getGame(difficulty: widget.difficulty).then((game) {
        gameModel = SudokuGameModel.fromSudokuGame(
          sudokuGame: game,
          difficulty: widget.difficulty,
        );
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.builder(gameModel);
}

class GameBackground extends StatelessWidget {
  const GameBackground({super.key, this.gameModel});

  final SudokuGameModel? gameModel;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SudokuGameCubit, SudokuGameState>(
      listenWhen: (prev, next) => prev.step != next.step,
      listener: (context, state) {
        if (state.step == GameStep.stop) {
          showModalBottomSheet(
            context: context,
            builder: (context) => const TokenSelector(),
          ).whenComplete(context.read<SudokuGameCubit>().toggleGame);
        }
      },
      builder: (context, state) {
        return _SudokuBoardSetup(
          game: gameModel,
          difficulty: state.difficulty,
          builder: (model) {
            if (model == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocProvider(
              create: (context) => SudokuBoardCubit(model),
              child: BlocListener<SudokuBoardCubit, SudokuBoardState>(
                listenWhen: (prev, next) =>
                    prev.gameModel.isCompleted != next.gameModel.isCompleted,
                listener: (context, state) {
                  if (state.gameModel.isCompleted) {
                    context.read<SudokuGameCubit>().stopTimer();
                    showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      enableDrag: false,
                      builder: (context) => const VictoryModal(),
                    );
                  }
                },
                child: SudokuGameScreen(type: state.type),
              ),
            );
          },
        );
      },
    );
  }
}
