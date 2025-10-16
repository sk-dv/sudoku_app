import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/data/sudoku_object.dart';
import 'package:sudoku_app/data/token_type.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

class Cell extends StatelessWidget {
  const Cell({
    required this.row,
    required this.col,
    required this.sudokuObject,
    required this.onCellTap,
    super.key,
  });

  final int row;
  final int col;
  final SudokuObject sudokuObject;
  final Function(int, int) onCellTap;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
      selector: (state) => state.style,
      builder: (context, style) {
        Color cellColor = style.background;
        Color textColor = style.flatColor;
        Color borderColor = style.borderColor;

        if (sudokuObject.isSelected) {
          cellColor = style.selectedCell;
          textColor = style.background;
          borderColor = style.borderColor;
        } else if (sudokuObject.isError) {
          cellColor = style.errorCell;
          textColor = style.errorText;
          borderColor = style.errorCell.withValues(alpha: 0.8);
        } else if (sudokuObject.isHighlighted) {
          cellColor = style.cellColor.withValues(alpha: 0.3);
          textColor = style.flatColor;
        }

        if (sudokuObject.isOriginal && !sudokuObject.isSelected) {
          textColor = style.flatColor;
        }

        final bool needThickRight = col == 2 || col == 5;
        final bool needThickBottom = row == 2 || row == 5;

        return GestureDetector(
          onTap: () => onCellTap(row, col),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: cellColor,
              border: Border(
                right: BorderSide(
                  color: needThickRight ? style.borderColor : borderColor,
                  width: needThickRight ? 3 : 1,
                ),
                bottom: BorderSide(
                  color: needThickBottom ? style.borderColor : borderColor,
                  width: needThickBottom ? 3 : 1,
                ),
                left: BorderSide(color: borderColor, width: 1),
                top: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: BlocSelector<SudokuGameCubit, SudokuGameState, TokenType>(
              selector: (state) => state.type,
              builder: (context, type) {
                if (type.isImage) {
                  return ImageCell(path: type.path, value: sudokuObject.value);
                }

                return NumberCell(
                  textColor: textColor,
                  value: sudokuObject.value,
                  isSelected: sudokuObject.isSelected,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ImageCell extends StatelessWidget {
  const ImageCell({required this.value, required this.path, super.key});

  final int value;
  final String path;

  @override
  Widget build(BuildContext context) {
    final isHalloween = path.contains('halloween');
    final isCats = path.contains('cats');

    return Center(
      child: value == 0
          ? const SizedBox.shrink()
          : Padding(
              padding: isHalloween || isCats ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
              child: Image.asset('${path}0$value.png', fit: BoxFit.contain),
            ),
    );
  }
}

class NumberCell extends StatelessWidget {
  const NumberCell({
    required this.textColor,
    required this.value,
    required this.isSelected,
    super.key,
  });

  final Color textColor;
  final int value;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: value == 0
          ? const SizedBox.shrink()
          : AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 14 : 12,
                fontWeight: FontWeight.w900,
                color: textColor,
                fontFamily: 'Brick Sans',
              ),
              child: Text(
                '$value',
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
