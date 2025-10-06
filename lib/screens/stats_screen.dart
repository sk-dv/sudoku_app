import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/context_utils.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _apiService.getStats();

      if (mounted) {
        setState(() {
          _stats = stats;
          _boardsSummary = Map<String, int>.from(stats['by_difficulty'] ?? {});
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
                        FloatingCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.public_rounded,
                                    color: context
                                        .read<SudokuGameCubit>()
                                        .state
                                        .style
                                        .selectedCell,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  BlocSelector<SudokuGameCubit, SudokuGameState,
                                      Color>(
                                    selector: (state) =>
                                        state.style.borderColor,
                                    builder: (context, color) {
                                      return Text(
                                        'GLOBAL',
                                        style: TextStyle(
                                          fontSize: 16,
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
                              const SizedBox(height: 20),
                              _StatItem(
                                label: 'Total de Puzzles',
                                value: '${_stats?['total_puzzles'] ?? 0}',
                                icon: Icons.grid_on_rounded,
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        FloatingCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    color: context
                                        .read<SudokuGameCubit>()
                                        .state
                                        .style
                                        .selectedCell,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  BlocSelector<SudokuGameCubit, SudokuGameState,
                                      Color>(
                                    selector: (state) =>
                                        state.style.borderColor,
                                    builder: (context, color) {
                                      return Text(
                                        'POR DIFICULTAD',
                                        style: TextStyle(
                                          fontSize: 16,
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
                              const SizedBox(height: 15),
                              _DifficultyBar(
                                label: 'FÁCIL',
                                count: _boardsSummary?['VERY_EASY'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFF4CAF50),
                              ),
                              const SizedBox(height: 12),
                              _DifficultyBar(
                                label: 'MEDIO',
                                count: _boardsSummary?['EASY'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFF2196F3),
                              ),
                              const SizedBox(height: 12),
                              _DifficultyBar(
                                label: 'DIFÍCIL',
                                count: _boardsSummary?['VERY_HARD'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFFFFC107),
                              ),
                              const SizedBox(height: 12),
                              _DifficultyBar(
                                label: 'EXPERTO',
                                count: _boardsSummary?['MASTER'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFFFF9800),
                              ),
                              const SizedBox(height: 12),
                              _DifficultyBar(
                                label: 'MAESTRO',
                                count: _boardsSummary?['MASTER'] ?? 0,
                                total: _stats?['total_puzzles'] ?? 1,
                                color: const Color(0xFFF44336),
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
                                      fontFamily: 'Brick Sans',
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
                selector: (state) => state.style.borderColor,
                builder: (context, textColor) {
                  return Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.7),
                      fontFamily: 'Brick Sans',
                      letterSpacing: 1,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  color: color,
                  fontFamily: 'Brick Sans',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
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
                fontFamily: 'Brick Sans',
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontFamily: 'Brick Sans',
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
