import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/context_utils.dart';

import 'package:sudoku_app/menu_screen.dart';
import 'package:sudoku_app/game_background.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';

import 'data/game_step.dart';
import 'widgets/pixelated_background.dart';
import 'widgets/shadow_icon.dart';

enum GameScreen {
  menu,
  game;

  bool get isMenu => this == GameScreen.menu;
}

class Sudoku extends StatelessWidget {
  const Sudoku({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SudokuGameCubit()..setupStyle(context),
        ),
        BlocProvider(
          create: (_) => SudokuBoardCubit(SudokuApiService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CloudsBackground(
          builder: (context, onMenu) {
            return onMenu ? const MenuScreen() : const GameBackground();
          },
        ),
      ),
    );
  }
}

class CloudsBackground extends StatelessWidget {
  const CloudsBackground({super.key, required this.builder});

  final Widget Function(BuildContext, bool) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: state.style.topBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            leadingWidth: state.screen.isMenu ? null : context.width * 0.2,
            leading: state.screen.isMenu
                ? null
                : Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: ShadowIcon(
                      icon: state.step.icon,
                      onPressed: context.read<SudokuGameCubit>().toggleGame,
                    ),
                  ),
            actions: [
              ShadowIcon(
                icon: state.style.themeIcon,
                onPressed: context.read<SudokuGameCubit>().changeMode,
              )
            ],
          ),
          body: PixelatedBackground(
            stop: state.step == GameStep.stop,
            primaryColor: state.style.topBackground,
            secondaryColor: state.style.bottomBackground,
            child: builder(context, state.screen.isMenu),
          ),
        );
      },
    );
  }
}
