import 'package:flutter/material.dart';
import 'package:sudoku_app/models/style.dart';
import 'package:sudoku_app/models/sudoku_object.dart';

class SudokuMinimap extends StatelessWidget {
  const SudokuMinimap({
    super.key,
    required this.board,
    required this.focusedQuadrant,
    required this.onQuadrantActivated,
    required this.style,
  });

  final List<List<SudokuObject>> board;

  /// Índice 0-8 del cuadrante actualmente ampliado, -1 = sin zoom.
  final int focusedQuadrant;

  /// Doble tap/clic en un cuadrante. Mismo índice = reset.
  final void Function(int) onQuadrantActivated;
  final SudokuStyle style;

  static const double _totalSize = 108;
  static const double _quadrantSize = _totalSize / 3; // 36
  static const double _cellSize = _quadrantSize / 3;  // 12

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _totalSize,
      height: _totalSize,
      decoration: BoxDecoration(
        border: Border.all(color: style.borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        color: style.background,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // ── Celdas ──────────────────────────────────────────────────
          for (int row = 0; row < 9; row++)
            for (int col = 0; col < 9; col++)
              Positioned(
                left: col * _cellSize,
                top: row * _cellSize,
                width: _cellSize,
                height: _cellSize,
                child: _MinimapCell(
                  obj: board[row][col],
                  style: style,
                ),
              ),

          // ── Overlay de cuadrantes (bordes + hit target) ──────────────
          for (int qi = 0; qi < 9; qi++)
            Positioned(
              left: (qi % 3) * _quadrantSize,
              top: (qi ~/ 3) * _quadrantSize,
              width: _quadrantSize,
              height: _quadrantSize,
              child: GestureDetector(
                onDoubleTap: () => onQuadrantActivated(qi),
                behavior: HitTestBehavior.translucent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: qi == focusedQuadrant
                          ? style.selectedCell
                          : style.borderColor.withValues(alpha: 0.6),
                      width: qi == focusedQuadrant ? 2 : 1,
                    ),
                    color: qi == focusedQuadrant
                        ? style.selectedCell.withValues(alpha: 0.12)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MinimapCell extends StatelessWidget {
  const _MinimapCell({required this.obj, required this.style});

  final SudokuObject obj;
  final SudokuStyle style;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;

    if (obj.isSelected) {
      bg = style.selectedCell;
      textColor = style.mode.isDark ? const Color(0xFF141414) : const Color(0xFFFFFFFF);
    } else if (obj.isError) {
      bg = style.errorCell;
      textColor = style.errorText;
    } else if (obj.isHighlighted) {
      bg = style.cellColor;
      textColor = style.flatColor;
    } else {
      bg = style.background;
      textColor = obj.isOriginal ? style.flatColor : style.flatColor.withValues(alpha: 0.6);
    }

    return Container(
      color: bg,
      child: obj.value != 0
          ? Center(
              child: Text(
                '${obj.value}',
                style: TextStyle(
                  fontSize: 5,
                  height: 1,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
