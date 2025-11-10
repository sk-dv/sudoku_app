import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadBoardsSummary();
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

  void _selectLevel(BuildContext context, String difficulty) {
    context.read<SudokuBoardCubit>().loadNewGame(difficulty: difficulty);
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
                        _LevelCard(
                          level: 'FÁCIL',
                          difficulty: 'EASY',
                          description: 'Perfecto para comenzar',
                          color: const Color(0xFF4CAF50),
                          count: _boardsSummary?['EASY'],
                          onTap: () => _selectLevel(context, 'EASY'),
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          level: 'MEDIO',
                          difficulty: 'MEDIUM',
                          description: 'Un poco más desafiante',
                          color: const Color(0xFF2196F3),
                          count: _boardsSummary?['MEDIUM'],
                          onTap: () => _selectLevel(context, 'MEDIUM'),
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          level: 'DIFÍCIL',
                          difficulty: 'HARD',
                          description: 'Para jugadores avanzados',
                          color: const Color(0xFFFFC107),
                          count: _boardsSummary?['HARD'],
                          onTap: () => _selectLevel(context, 'HARD'),
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          level: 'EXPERTO',
                          difficulty: 'EXPERT',
                          description: 'Solo para expertos',
                          color: const Color(0xFFFF9800),
                          count: _boardsSummary?['EXPERT'],
                          onTap: () => _selectLevel(context, 'EXPERT'),
                        ),
                        const SizedBox(height: 8),
                        _LevelCard(
                          level: 'MAESTRO',
                          difficulty: 'MASTER',
                          description: 'El desafío supremo',
                          color: const Color(0xFFF44336),
                          count: _boardsSummary?['MASTER'],
                          onTap: () => _selectLevel(context, 'MASTER'),
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
  const _LevelCard({
    required this.level,
    required this.difficulty,
    required this.description,
    required this.color,
    required this.onTap,
    this.count,
  });

  final String level;
  final String difficulty;
  final String description;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FloatingCard(
        elevation: 6,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Icon(
                  _getDifficultyIcon(difficulty),
                  color: color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: TextStyle(
                      color: color,
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
                        description,
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
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$count puzzles',
                        style: TextStyle(
                          color: color,
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

            // Flecha
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return Icons.sentiment_satisfied_rounded;
      case 'MEDIUM':
        return Icons.auto_awesome_rounded;
      case 'HARD':
        return Icons.local_fire_department_rounded;
      case 'EXPERT':
        return Icons.workspace_premium_rounded;
      case 'MASTER':
        return Icons.emoji_events_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
