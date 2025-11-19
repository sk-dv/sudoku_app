import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/context_utils.dart';

import 'package:sudoku_app/menu_screen.dart';
import 'package:sudoku_app/game_background.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/navigation_cubit.dart';
import 'package:sudoku_app/cubit/game_coordinator_cubit.dart';

import 'models/game_step.dart';
import 'models/token_type.dart';
import 'widgets/pixelated_background.dart';
import 'widgets/shadow_button.dart';
import 'widgets/shadow_icon.dart';

class Sudoku extends StatelessWidget {
  const Sudoku({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SudokuGameCubit()..setupStyle(context)),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => GameCoordinatorCubit()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ShellNavigation(),
      ),
    );
  }
}

class ShellNavigation extends StatelessWidget {
  const ShellNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        return BlocBuilder<SudokuGameCubit, SudokuGameState>(
          builder: (context, gameState) {
            return BlocBuilder<GameCoordinatorCubit, GameCoordinatorState>(
              builder: (context, coordState) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: _AppBar(
                    navState: navState,
                    gameState: gameState,
                    coordState: coordState,
                  ),
                  body: Stack(
                    children: [
                      PixelatedBackground(
                        stop: gameState.step == GameStep.stop,
                        primaryColor: gameState.style.topBackground,
                        secondaryColor: gameState.style.bottomBackground,
                        child: const SizedBox.expand(),
                      ),
                      _Content(navState: navState),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.navState});

  final NavigationState navState;

  @override
  Widget build(BuildContext context) {
    if (navState.route.isMenu) return const MenuScreen();
    return GameBackground(gameModel: navState.gameModel);
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.navState,
    required this.gameState,
    required this.coordState,
  });

  final NavigationState navState;
  final SudokuGameState gameState;
  final GameCoordinatorState coordState;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: gameState.style.topBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      leadingWidth: navState.route.isGame ? context.width * 0.45 : null,
      leading: navState.route.isGame
          ? Container(
              margin: const EdgeInsets.only(left: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShadowIcon(
                    icon: gameState.step.icon,
                    onPressed: () {
                      final cubit = context.read<SudokuGameCubit>();
                      final coordinator = context.read<GameCoordinatorCubit>();

                      if (gameState.step == GameStep.play) {
                        coordinator.pauseGame();
                      } else {
                        coordinator.resumeTimer();
                      }
                      cubit.toggleGame();
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: context.width * 0.02),
                    child: Text(
                      coordState.formattedTime,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: gameState.style.selectedCell,
                        fontFamily: 'Brick Sans',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      actions: [
        if (navState.route.isGame) ...[
          Transform.translate(
            offset: const Offset(12, 0),
            child: const _SymbolButton(),
          ),
        ],
        ShadowIcon(
          icon: gameState.style.themeIcon,
          onPressed: context.read<SudokuGameCubit>().changeMode,
        ),
      ],
    );
  }
}

class _SymbolButton extends StatelessWidget {
  const _SymbolButton();

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
