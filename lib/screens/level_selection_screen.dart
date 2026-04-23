import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/services/game_save_service.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/navigation_cubit.dart';
import 'package:sudoku_app/cubit/game_coordinator_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';

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
    final progress = GameSaveService.loadGame(gameId);
    if (progress == null) return;

    if (context.mounted) {
      context.read<SudokuGameCubit>().play(
        progress.difficulty,
        progress.toSudokuGameModel(),
      );
      context.read<GameCoordinatorCubit>().resumeGame(
        progress.timeElapsed,
        progress.difficulty,
        progress.hintIdx,
      );
      context.read<NavigationCubit>().goToGame(
        progress.difficulty,
        progress.toSudokuGameModel(),
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
            child: BlocSelector<SudokuGameCubit, SudokuGameState, bool>(
              selector: (state) => state.style.mode.isDark,
              builder: (context, isDark) {
                final color =
                    isDark ? const Color(0xFFFFFBF0) : const Color(0xFF1A1A2E);
                final shadow = isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.15);
                return Text(
                  'SUDOKU',
                  style: TextStyle(
                    fontFamily: 'BrickSans',
                    fontSize: 48,
                    color: color,
                    letterSpacing: 4,
                    shadows: [Shadow(color: shadow, offset: const Offset(4, 4))],
                  ),
                );
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
                          difficulty: DifficultLevel.beginner,
                          count: (level) => _boardsSummary?[level],
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 8),
                        _LevelCard(
                          difficulty: DifficultLevel.grandmaster,
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
        context.read<GameCoordinatorCubit>().startGame(difficulty);
        context.read<NavigationCubit>().goToGame(difficulty);
      },
      child: FloatingCard(
        elevation: 4,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Container(
              width: 3,
              height: 52,
              decoration: BoxDecoration(
                color: difficulty.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    difficulty.level,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 8),
                    Builder(builder: (context) {
                      final n = count?.call(difficulty.levelMap());
                      if (n == null) return const SizedBox.shrink();
                      return Text(
                        '$n',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    }),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                size: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum DifficultLevel {
  beginner,
  easy,
  medium,
  hard,
  expert,
  master,
  grandmaster;

  String get level {
    switch (this) {
      case DifficultLevel.beginner:
        return 'PRINCIPIANTE';
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
      case DifficultLevel.grandmaster:
        return 'GRAN MAESTRO';
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultLevel.beginner:
        return Icons.school_rounded;
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
      case DifficultLevel.grandmaster:
        return Icons.military_tech_rounded;
    }
  }

  String get description {
    switch (this) {
      case DifficultLevel.beginner:
        return 'Para dar los primeros pasos';
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
      case DifficultLevel.grandmaster:
        return 'Más allá del límite';
    }
  }

  Color get color {
    switch (this) {
      case DifficultLevel.beginner:
        return const Color(0xFF8BC34A);
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
      case DifficultLevel.grandmaster:
        return const Color(0xFF9C27B0);
    }
  }

  /// Nombre exacto del nivel en el backend (usado en /game y /stats).
  String backendName() {
    switch (this) {
      case DifficultLevel.beginner:
        return 'BEGINNER';
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
      case DifficultLevel.grandmaster:
        return 'GRANDMASTER';
    }
  }

  String levelMap() => backendName();

  String gameMap() => backendName();
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

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FloatingCard(
      elevation: 8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, color: cs.onSurface, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CONTINUAR JUEGO',
                  style: tt.titleSmall?.copyWith(
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
              style: tt.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Pistas restantes: ${savedGame.hintCoordinates.length - savedGame.hintIdx}',
              style: tt.bodySmall,
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
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CONTINUAR',
                      textAlign: TextAlign.center,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onPrimary,
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
                      border: Border.all(color: cs.onSurface.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DESCARTAR',
                      textAlign: TextAlign.center,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurface,
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
  }
}
