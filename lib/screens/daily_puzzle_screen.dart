import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/widgets/text_shadow.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  String? _selectedDifficulty;

  void _playDailyPuzzle(BuildContext context, String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
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
                    isSelected: _selectedDifficulty == 'EASY',
                    isDisabled: _selectedDifficulty != null && _selectedDifficulty != 'EASY',
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'MEDIO',
                    difficulty: 'MEDIUM',
                    color: const Color(0xFF2196F3),
                    onTap: () => _playDailyPuzzle(context, 'MEDIUM'),
                    isSelected: _selectedDifficulty == 'MEDIUM',
                    isDisabled: _selectedDifficulty != null && _selectedDifficulty != 'MEDIUM',
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'DIFÍCIL',
                    difficulty: 'HARD',
                    color: const Color(0xFFFFC107),
                    onTap: () => _playDailyPuzzle(context, 'HARD'),
                    isSelected: _selectedDifficulty == 'HARD',
                    isDisabled: _selectedDifficulty != null && _selectedDifficulty != 'HARD',
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'EXPERTO',
                    difficulty: 'EXPERT',
                    color: const Color(0xFFFF9800),
                    onTap: () => _playDailyPuzzle(context, 'EXPERT'),
                    isSelected: _selectedDifficulty == 'EXPERT',
                    isDisabled: _selectedDifficulty != null && _selectedDifficulty != 'EXPERT',
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    level: 'MAESTRO',
                    difficulty: 'MASTER',
                    color: const Color(0xFFF44336),
                    onTap: () => _playDailyPuzzle(context, 'MASTER'),
                    isSelected: _selectedDifficulty == 'MASTER',
                    isDisabled: _selectedDifficulty != null && _selectedDifficulty != 'MASTER',
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
    this.isSelected = false,
    this.isDisabled = false,
  });

  final String level;
  final String difficulty;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled ? color.withValues(alpha: 0.3) : color;
    final backgroundColor = isSelected
        ? color.withValues(alpha: 0.3)
        : color.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: FloatingCard(
          elevation: isDisabled ? 2 : 6,
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: effectiveColor,
                    width: isSelected ? 3 : 2,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
                  color: effectiveColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  level,
                  style: TextStyle(
                    color: effectiveColor,
                    fontSize: 15,
                    fontFamily: 'Brick Sans',
                    letterSpacing: 2,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  ),
                ),
              ),
              if (!isDisabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: effectiveColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
