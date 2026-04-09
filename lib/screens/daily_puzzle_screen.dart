import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/cubit/auth_cubit.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/models/game_progress.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'package:sudoku_app/services/daily_progress_service.dart';
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
  int? _userStreak;
  DateTime _selectedDate = DateTime.now();

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String get _dateApiString =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final stats = await SudokuApiService.getUserStats();
    if (mounted && stats != null) {
      setState(() => _userStreak = stats['current_streak'] as int?);
    }
  }

  void _onDifficultySelected(String difficulty) {
    setState(() => _selectedDifficulty = difficulty);
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDifficulty = null;
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    if (!_isToday) {
      setState(() {
        _selectedDifficulty = null;
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
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
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: _goToPreviousDay,
                                  child: Icon(Icons.arrow_back_ios_rounded, size: 16, color: color),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getCurrentDate(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: color,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: _isToday ? null : _goToNextDay,
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: _isToday ? color.withValues(alpha: 0.25) : color,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (_userStreak != null && _userStreak! > 0 &&
                            context.read<AuthCubit>().state is AuthAuthenticated) ...[
                          const SizedBox(height: 12),
                          BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                            selector: (state) => state.style.selectedCell,
                            builder: (context, color) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_fire_department_rounded, color: color, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'RACHA: $_userStreak',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: color,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
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
                    selectedDate: _selectedDate,
                    dateApiString: _dateApiString,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.medium,
                    selected: _selectedDifficulty,
                    selectedDate: _selectedDate,
                    dateApiString: _dateApiString,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.hard,
                    selected: _selectedDifficulty,
                    selectedDate: _selectedDate,
                    dateApiString: _dateApiString,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.expert,
                    selected: _selectedDifficulty,
                    selectedDate: _selectedDate,
                    dateApiString: _dateApiString,
                    onDifficultySelected: _onDifficultySelected,
                  ),
                  const SizedBox(height: 8),
                  _DailyDifficultyCard(
                    difficulty: DifficultLevel.master,
                    selected: _selectedDifficulty,
                    selectedDate: _selectedDate,
                    dateApiString: _dateApiString,
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
    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }
}

class _DailyDifficultyCard extends StatelessWidget {
  const _DailyDifficultyCard({
    required this.difficulty,
    required this.selected,
    required this.selectedDate,
    required this.dateApiString,
    required this.onDifficultySelected,
  });

  final DifficultLevel difficulty;
  final String? selected;
  final DateTime selectedDate;
  final String dateApiString;
  final void Function(String) onDifficultySelected;

  bool get isSelected => selected == difficulty.level;

  bool get isCompletedToday => DailyProgressService.isCompleted(difficulty.level, selectedDate);

  bool get isDisabled => (selected != null && selected != difficulty.level) || isCompletedToday;

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
                  date: dateApiString,
                ),
              );

              cubit.play(difficulty, gameModel);

              if (context.mounted) {
                context.read<GameCoordinatorCubit>().startGame(
                  difficulty,
                  source: GameSource.daily,
                  dailyDate: selectedDate,
                );
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
                    letterSpacing: 2,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  ),
                ),
              ),
              if (isCompletedToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: effectiveColor, width: 1.5),
                  ),
                  child: Text(
                    'COMPLETADO',
                    style: TextStyle(
                      fontSize: 9,
                      color: effectiveColor,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (!isDisabled)
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
