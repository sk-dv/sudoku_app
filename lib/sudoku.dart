import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/context_utils.dart';

import 'package:sudoku_app/menu_screen.dart';
import 'package:sudoku_app/game_background.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';

import 'data/game_step.dart';
import 'data/token_type.dart';
import 'widgets/pixelated_background.dart';
import 'widgets/shadow_button.dart';
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

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

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
            leadingWidth: state.screen.isMenu ? null : context.width * 0.45,
            leading: state.screen.isMenu
                ? null
                : Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadowIcon(
                          icon: state.step.icon,
                          onPressed: context.read<SudokuGameCubit>().toggleGame,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: context.width * 0.02),
                          child: Text(
                            _formatTime(state.elapsedSeconds),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: state.style.selectedCell,
                              fontFamily: 'Brick Sans',
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            actions: [
              if (!state.screen.isMenu) ...[
                Transform.translate(
                  offset: const Offset(12, 0),
                  child: _SymbolButton(),
                ),
              ],
              ShadowIcon(
                icon: state.style.themeIcon,
                onPressed: context.read<SudokuGameCubit>().changeMode,
              ),
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

class _SymbolButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        return ShadowButton(
          radius: 40,
          containerSize: const (60, 60),
          shadowSize: const (50, 50),
          restSpace: 8,
          pressedSpace: 7.5,
          shadowOffset: const Offset(-6, 3),
          shadowColor: state.style.cellColor.withValues(alpha: 0.5),
          onPressed: context.read<SudokuGameCubit>().cycleSymbol,
          child: Container(
            margin: const EdgeInsets.only(right: 10, top: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: state.style.themeColor,
            ),
            child: Center(
              child: state.type.token.isEmpty
                  ? const Text(
                      '1',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFBF0),
                        fontFamily: 'Brick Sans',
                      ),
                    )
                  : Padding(
                      padding: state.type == TokenType.halloween ||
                              state.type == TokenType.cats
                          ? const EdgeInsets.all(4.0)
                          : EdgeInsets.zero,
                      child: Image.asset(
                        state.type.token,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
