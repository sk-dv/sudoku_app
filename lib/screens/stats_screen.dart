import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/cubit/auth_cubit.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';
import 'package:sudoku_app/widgets/text_shadow.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final SudokuApiService _apiService = SudokuApiService();
  Map<String, dynamic>? _stats;
  Map<String, int>? _boardsSummary;
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final serverStats = await _apiService.getStats();
      final userStats = await SudokuApiService.getUserStats();

      if (mounted) {
        setState(() {
          _stats = serverStats;
          _boardsSummary = Map<String, int>.from(serverStats['boards'] ?? {});
          _userStats = userStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  text: 'ESTADÍSTICAS',
                  mainColor: color,
                  fontSize: 28,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_userStats != null &&
                            context.read<AuthCubit>().state is AuthAuthenticated)
                          _UserStatsCard(stats: _userStats!),
                        if (_userStats != null &&
                            context.read<AuthCubit>().state is AuthAuthenticated)
                          const SizedBox(height: 20),
                        FloatingCard(
                          padding: const EdgeInsets.all(20),
                          child: BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                            selector: (state) => state.style.selectedCell,
                            builder: (context, accentColor) {
                              return BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                                selector: (state) => state.style.borderColor,
                                builder: (context, textColor) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'TOTAL PUZZLES',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: textColor.withValues(alpha: 0.5),
                                                letterSpacing: 2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_stats?['total_puzzles'] ?? 0}',
                                              style: TextStyle(
                                                fontSize: 48,
                                                color: accentColor,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2,
                                                height: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.grid_on_rounded,
                                          color: accentColor.withValues(alpha: 0.2),
                                          size: 48),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        FloatingCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                                selector: (state) => state.style.borderColor,
                                builder: (context, color) {
                                  return Text(
                                    'POR DIFICULTAD',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: color.withValues(alpha: 0.6),
                                      letterSpacing: 2,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              _DifficultyBar(
                                label: 'PRINCIPIANTE',
                                count: _boardsSummary?['BEGINNER'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFF8BC34A),
                              ),
                              const SizedBox(height: 10),
                              _DifficultyBar(
                                label: 'FÁCIL',
                                count: _boardsSummary?['EASY'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFF4CAF50),
                              ),
                              const SizedBox(height: 10),
                              _DifficultyBar(
                                label: 'MEDIO',
                                count: _boardsSummary?['MEDIUM'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFF2196F3),
                              ),
                              const SizedBox(height: 10),
                              _DifficultyBar(
                                label: 'DIFÍCIL',
                                count: _boardsSummary?['HARD'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFFFFC107),
                              ),
                              const SizedBox(height: 10),
                              _DifficultyBar(
                                label: 'EXPERTO',
                                count: _boardsSummary?['EXPERT'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFFFF9800),
                              ),
                              const SizedBox(height: 10),
                              _DifficultyBar(
                                label: 'MAESTRO',
                                count: _boardsSummary?['MASTER'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFFF44336),
                              ),
                              const SizedBox(height: 10),
                              _DifficultyBar(
                                label: 'GRAN MAESTRO',
                                count: _boardsSummary?['GRANDMASTER'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFF9C27B0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        FloatingCard(
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: context
                                    .read<SudokuGameCubit>()
                                    .state
                                    .style
                                    .selectedCell,
                                size: 24,
                              ),
                              const SizedBox(height: 12),
                              BlocSelector<SudokuGameCubit, SudokuGameState,
                                  Color>(
                                selector: (state) => state.style.borderColor,
                                builder: (context, color) {
                                  return Text(
                                    'Estas estadísticas representan\nla base de datos global de puzzles\ndisponibles en el servidor.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: color.withValues(alpha: 0.7),
                                      letterSpacing: 1,
                                      height: 1.5,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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

class _UserStatsCard extends StatelessWidget {
  const _UserStatsCard({required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final accentColor = context.read<SudokuGameCubit>().state.style.selectedCell;
    final textColor = context.read<SudokuGameCubit>().state.style.borderColor;
    final gamesPlayed = stats['games_played'] ?? 0;
    final gamesCompleted = stats['games_completed'] ?? 0;
    final streak = stats['current_streak'] ?? 0;
    final bestStreak = stats['best_streak'] ?? 0;
    final bestTimes = Map<String, dynamic>.from(stats['best_times'] ?? {});

    return FloatingCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TUS ESTADÍSTICAS',
            style: TextStyle(
              fontSize: 11,
              color: textColor.withValues(alpha: 0.5),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(label: 'JUGADAS', value: '$gamesPlayed', color: accentColor),
              const SizedBox(width: 24),
              _StatItem(label: 'COMPLETADAS', value: '$gamesCompleted', color: accentColor),
              const SizedBox(width: 24),
              _StatItem(label: 'RACHA', value: '$streak', color: accentColor),
              const SizedBox(width: 24),
              _StatItem(label: 'MEJOR RACHA', value: '$bestStreak', color: accentColor),
            ],
          ),
          if (bestTimes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'MEJORES TIEMPOS',
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.4),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: bestTimes.entries.map((e) {
                final secs = e.value as int;
                final mins = secs ~/ 60;
                final s = secs % 60;
                return Text(
                  '${e.key}: ${mins}m ${s}s',
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    letterSpacing: 1,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            color: color,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: color.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _DifficultyBar extends StatelessWidget {
  const _DifficultyBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: count / (total > 0 ? total : 1),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
