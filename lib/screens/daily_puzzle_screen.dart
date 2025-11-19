import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/navigation_cubit.dart';
import 'package:sudoku_app/cubit/game_coordinator_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/widgets/text_shadow.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  String? _selectedDifficulty;

  void _onDifficultySelected(String difficulty) {
    setState(() => _selectedDifficulty = difficulty);
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
                    difficulty: DifficultLevel.easy,
                    selected: _selectedDifficulty,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.medium,
                    selected: _selectedDifficulty,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.hard,
                    selected: _selectedDifficulty,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.expert,
                    selected: _selectedDifficulty,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.master,
                    selected: _selectedDifficulty,
                    onDifficultySelected: _onDifficultySelected,
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
    required this.difficulty,
    required this.selected,
    required this.onDifficultySelected,
  });

  final DifficultLevel difficulty;
  final String? selected;
  final void Function(String) onDifficultySelected;

  bool get isSelected => selected == difficulty.level;

  bool get isDisabled => selected != null && selected != difficulty.level;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        isDisabled ? difficulty.color.withValues(alpha: 0.3) : difficulty.color;

    final backgroundColor = isSelected
        ? difficulty.color.withValues(alpha: 0.3)
        : difficulty.color.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () async {
              onDifficultySelected(difficulty.level);

              final cubit = context.read<SudokuGameCubit>();

              final gameModel = SudokuGameModel.fromSudokuGame(
                difficulty: difficulty,
                sudokuGame: await SudokuApiService.getDailyGame(
                  difficulty: difficulty.levelMap(),
                ),
              );

              cubit.play(difficulty, gameModel);

              if (context.mounted) {
                context.read<GameCoordinatorCubit>().startGame(difficulty);
                context.read<NavigationCubit>().goToGame(difficulty, gameModel);
              }
            },
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
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.play_arrow_rounded,
                  color: effectiveColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  difficulty.level,
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
