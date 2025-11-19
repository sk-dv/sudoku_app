import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/cubit/navigation_cubit.dart';
import 'package:sudoku_app/cubit/game_coordinator_cubit.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';

class VictoryDialog extends StatelessWidget {
  const VictoryDialog({super.key});

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
                              Icons.emoji_events_rounded,
                              size: 48,
                              color: style.successCell,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '¡COMPLETADO!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: style.selectedCell,
                                fontFamily: 'Brick Sans',
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: style.borderColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  coordState.formattedTime,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: style.selectedCell,
                                    fontFamily: 'Brick Sans',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context.read<GameCoordinatorCubit>().stopGame();
                                context.read<NavigationCubit>().goToMenu();
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: style.selectedCell,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'MENÚ',
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
                          ],
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
