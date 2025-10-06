import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/context_utils.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/widgets/text_shadow.dart';

class DailyPuzzleScreen extends StatelessWidget {
  const DailyPuzzleScreen({super.key});

  void _playDailyPuzzle(BuildContext context, String difficulty) {
    context.read<SudokuBoardCubit>().loadDailyGame(difficulty: difficulty);
    context.read<SudokuGameCubit>().play();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
              selector: (state) => state.style.selectedCell,
              builder: (context, color) {
                return TextShadow(
                  text: 'JUEGO DIARIO',
                  mainColor: color,
                  fontSize: 28,
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FloatingCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 26,
                          color: context
                              .read<SudokuGameCubit>()
                              .state
                              .style
                              .selectedCell,
                        ),
                        const SizedBox(height: 16),
                        BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                          selector: (state) => state.style.borderColor,
                          builder: (context, color) {
                            return Text(
                              _getCurrentDate(),
                              style: TextStyle(
                                fontSize: 14,
                                color: color,
                                fontFamily: 'Brick Sans',
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                    selector: (state) => state.style.selectedCell,
                    builder: (context, color) {
                      return Text(
                        'ELIGE TU DIFICULTAD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          fontFamily: 'Brick Sans',
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _DailyDifficultyCard(
                    level: 'FÁCIL',
                    difficulty: 'EASY',
                    color: const Color(0xFF4CAF50),
                    onTap: () => _playDailyPuzzle(context, 'EASY'),
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'MEDIO',
                    difficulty: 'MEDIUM',
                    color: const Color(0xFF2196F3),
                    onTap: () => _playDailyPuzzle(context, 'MEDIUM'),
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'DIFÍCIL',
                    difficulty: 'HARD',
                    color: const Color(0xFFFFC107),
                    onTap: () => _playDailyPuzzle(context, 'HARD'),
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'EXPERTO',
                    difficulty: 'EXPERT',
                    color: const Color(0xFFFF9800),
                    onTap: () => _playDailyPuzzle(context, 'EXPERT'),
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'MAESTRO',
                    difficulty: 'MASTER',
                    color: const Color(0xFFF44336),
                    onTap: () => _playDailyPuzzle(context, 'MASTER'),
                  ),
                  SizedBox(height: context.height * 0.11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'ENERO',
      'FEBRERO',
      'MARZO',
      'ABRIL',
      'MAYO',
      'JUNIO',
      'JULIO',
      'AGOSTO',
      'SEPTIEMBRE',
      'OCTUBRE',
      'NOVIEMBRE',
      'DICIEMBRE'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _DailyDifficultyCard extends StatelessWidget {
  const _DailyDifficultyCard({
    required this.level,
    required this.difficulty,
    required this.color,
    required this.onTap,
  });

  final String level;
  final String difficulty;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FloatingCard(
        elevation: 6,
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                level,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontFamily: 'Brick Sans',
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
