import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/navigation_cubit.dart';
import 'package:sudoku_app/cubit/game_coordinator_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/widgets/shadow_button.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BlocBuilder<GameCoordinatorCubit, GameCoordinatorState>(
        builder: (context, coordState) {
          return BlocBuilder<SudokuGameCubit, SudokuGameState>(
            builder: (context, state) {
              final style = state.style;

              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: FloatingCard(
                  elevation: 6,
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            Icon(
                              Icons.pause_rounded,
                              size: 40,
                              color: style.selectedCell,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              coordState.formattedTime,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: style.selectedCell,
                                fontFamily: 'Brick Sans',
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: style.selectedCell,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'CONTINUAR',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: style.background,
                                    fontFamily: 'Brick Sans',
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                final nav = context.read<NavigationCubit>();
                                final coord =
                                    context.read<GameCoordinatorCubit>();
                                Navigator.of(context).pop();
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  coord.stopGame();
                                  nav.goToMenu();
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: style.selectedCell,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'MENÚ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: style.selectedCell,
                                    fontFamily: 'Brick Sans',
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 0,
                        child: ShadowButton(
                          radius: 20,
                          containerSize: const (36, 36),
                          shadowSize: const (32, 32),
                          restSpace: 4,
                          pressedSpace: 3,
                          shadowOffset: const Offset(-3, 2),
                          shadowColor: style.cellColor.withValues(alpha: 0.5),
                          onPressed: () => Navigator.pop(context),
                          child: Container(
                            margin: const EdgeInsets.only(right: 4, top: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: style.themeColor,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFFFFFBF0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
