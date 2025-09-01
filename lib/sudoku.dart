import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/menu_screen.dart';
import 'package:sudoku_app/mode_wrapper_background.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/sudoku_game_screen.dart';

import 'data/game_step.dart';
import 'widgets/pause_modal.dart';
import 'widgets/shadow_icon.dart';

enum GameScreen {
  menu,
  game;

  WrapperParams get params {
    switch (this) {
      case GameScreen.menu:
        return WrapperParams(builder: (context, state) => const MenuScreen());
      case GameScreen.game:
        return WrapperParams(
          leading: (context, state) => ShadowIcon(
            icon: state.step.icon,
            onPressed: context.read<SudokuGameCubit>().toggleGame,
          ),
          listenWhen: (prev, next) => prev.step != next.step,
          listener: (context, state) {
            if (state.step == GameStep.stop) {
              showModalBottomSheet(
                context: context,
                builder: (context) => const TokenSelector(),
              ).whenComplete(context.read<SudokuGameCubit>().toggleGame);
            }
          },
          builder: (context, state) => SudokuGameScreen(type: state.type),
        );
    }
  }
}

class WrapperParams {
  const WrapperParams({
    this.leading,
    required this.builder,
    this.listenWhen,
    this.listener,
  });

  final Widget Function(BuildContext, SudokuGameState)? leading;
  final Widget Function(BuildContext, SudokuGameState) builder;
  final bool Function(SudokuGameState, SudokuGameState)? listenWhen;
  final void Function(BuildContext, SudokuGameState)? listener;
}

class Sudoku extends StatelessWidget {
  const Sudoku({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SudokuGameCubit()..setupStyle(context),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<SudokuGameCubit, SudokuGameState>(
          builder: (context, state) {
            return ModeWrapperBackground(params: state.screen.params);
          },
        ),
      ),
    );
  }
}
