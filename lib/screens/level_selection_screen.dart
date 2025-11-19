import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/services/game_save_service.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/navigation_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/widgets/text_shadow.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final SudokuApiService _apiService = SudokuApiService();
  Map<String, int>? _boardsSummary;
  bool _isLoading = true;
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _loadBoardsSummary();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final hasSaved = await GameSaveService.hasSavedGame();

    setState(() {
      _hasSavedGame = hasSaved;
    });
  }

  Future<void> _loadBoardsSummary() async {
    try {
      final summary = await _apiService.getStats();
      if (mounted) {
        setState(() {
          _boardsSummary = Map<String, int>.from(summary['boards'] ?? {});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _continueSavedGame(BuildContext context, String gameId) async {
    final cubit = context.read<SudokuGameCubit>();
    await cubit.loadSavedGame(gameId);

    if (context.mounted) {
      context.read<NavigationCubit>().goToGame(
        cubit.state.difficulty,
        cubit.state.game,
      );
    }
  }

  void _discardSavedGame() {
    GameSaveService.deleteAllSavedGames();
    setState(() {
      _hasSavedGame = false;
    });
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
                return TextShadow(text: 'SUDOKU', mainColor: color);
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context
                          .read<SudokuGameCubit>()
                          .state
                          .style
                          .selectedCell,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_hasSavedGame) ...[
                          _ContinueGameCard(
                            onContinue: (gameId) {
                              _continueSavedGame(context, gameId);
                            },
                            onDiscard: _discardSavedGame,
                          ),
                          const SizedBox(height: 24),
                        ],
                        _LevelCard(
                          difficulty: DifficultLevel.easy,
                          count: (level) => _boardsSummary?[level],
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          difficulty: DifficultLevel.medium,
                          count: (level) => _boardsSummary?[level],
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          difficulty: DifficultLevel.hard,
                          count: (level) => _boardsSummary?[level],
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          difficulty: DifficultLevel.expert,
                          count: (level) => _boardsSummary?[level],
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          difficulty: DifficultLevel.master,
                          count: (level) => _boardsSummary?[level],
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
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.difficulty, this.count});

  final DifficultLevel difficulty;
  final int? Function(String level)? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SudokuGameCubit>().play(difficulty);
        context.read<NavigationCubit>().goToGame(difficulty);
      },
      child: FloatingCard(
        elevation: 6,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: difficulty.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: difficulty.color, width: 2),
              ),
              child: Center(
                child: Icon(difficulty.icon, color: difficulty.color, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.level,
                    style: TextStyle(
                      color: difficulty.color,
                      fontSize: 18,
                      fontFamily: 'Brick Sans',
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                    selector: (state) => state.style.borderColor,
                    builder: (context, textColor) {
                      return Text(
                        difficulty.description,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontFamily: 'Brick Sans',
                          letterSpacing: 1,
                        ),
                      );
                    },
                  ),
                  if (count != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: difficulty.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: difficulty.color.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${count?.call(difficulty.levelMap())} puzzles',
                        style: TextStyle(
                          color: difficulty.color,
                          fontSize: 10,
                          fontFamily: 'Brick Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: difficulty.color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

enum DifficultLevel {
  easy,
  medium,
  hard,
  expert,
  master;

  String get level {
    switch (this) {
      case DifficultLevel.easy:
        return 'FÁCIL';
      case DifficultLevel.medium:
        return 'MEDIO';
      case DifficultLevel.hard:
        return 'DIFÍCIL';
      case DifficultLevel.expert:
        return 'EXPERTO';
      case DifficultLevel.master:
        return 'MAESTRO';
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultLevel.easy:
        return Icons.sentiment_satisfied_rounded;
      case DifficultLevel.medium:
        return Icons.auto_awesome_rounded;
      case DifficultLevel.hard:
        return Icons.local_fire_department_rounded;
      case DifficultLevel.expert:
        return Icons.workspace_premium_rounded;
      case DifficultLevel.master:
        return Icons.emoji_events_rounded;
    }
  }

  String get description {
    switch (this) {
      case DifficultLevel.easy:
        return 'Perfecto para comenzar';
      case DifficultLevel.medium:
        return 'Un poco más desafiante';
      case DifficultLevel.hard:
        return 'Para jugadores avanzados';
      case DifficultLevel.expert:
        return 'Solo para expertos';
      case DifficultLevel.master:
        return 'El desafío supremo';
    }
  }

  Color get color {
    switch (this) {
      case DifficultLevel.easy:
        return const Color(0xFF4CAF50);
      case DifficultLevel.medium:
        return const Color(0xFF2196F3);
      case DifficultLevel.hard:
        return const Color(0xFFFFC107);
      case DifficultLevel.expert:
        return const Color(0xFFFF9800);
      case DifficultLevel.master:
        return const Color(0xFFF44336);
    }
  }

  String levelMap() {
    switch (this) {
      case DifficultLevel.easy:
        return 'VERY_EASY';
      case DifficultLevel.medium:
        return 'EASY';
      case DifficultLevel.hard:
        return 'HARD';
      case DifficultLevel.expert:
        return 'VERY_HARD';
      case DifficultLevel.master:
        return 'MASTER';
    }
  }

  String gameMap() {
    switch (this) {
      case DifficultLevel.easy:
        return 'EASY';
      case DifficultLevel.medium:
        return 'MEDIUM';
      case DifficultLevel.hard:
        return 'HARD';
      case DifficultLevel.expert:
        return 'EXPERT';
      case DifficultLevel.master:
        return 'MASTER';
    }
  }
}

class _ContinueGameCard extends StatelessWidget {
  final void Function(String gameId) onContinue;
  final VoidCallback onDiscard;

  const _ContinueGameCard({
    required this.onContinue,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final savedGame = GameSaveService.getLatestSavedGame();

    return BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
      selector: (state) => state.style.selectedCell,
      builder: (context, color) {
        return FloatingCard(
          elevation: 8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CONTINUAR JUEGO',
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontFamily: 'Brick Sans',
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (savedGame != null) ...[
                Text(
                  'Dificultad: ${savedGame.difficulty.level}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.7),
                    fontFamily: 'Brick Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pistas: ${savedGame.hintCoordinates.length - savedGame.hintIdx}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.7),
                    fontFamily: 'Brick Sans',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onContinue(savedGame!.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'CONTINUAR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Brick Sans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: onDiscard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DESCARTAR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontFamily: 'Brick Sans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
