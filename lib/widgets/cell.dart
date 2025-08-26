import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/service_locator.dart';
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
    Color cellColor = locator<SudokuStyle>().background;
    Color textColor = locator<SudokuStyle>().flatColor;
    Color borderColor = locator<SudokuStyle>().borderColor;

    if (sudokuObject.isSelected) {
      cellColor = locator<SudokuStyle>().selectedCell;
      textColor = locator<SudokuStyle>().background;
      borderColor = locator<SudokuStyle>().borderColor;
    } else if (sudokuObject.isError) {
      cellColor = locator<SudokuStyle>().pixelRed;
      textColor = locator<SudokuStyle>().background;
      borderColor = locator<SudokuStyle>().borderColor;
    } else if (sudokuObject.isHighlighted) {
      cellColor = locator<SudokuStyle>().cellColor.withValues(alpha: 0.3);
      textColor = locator<SudokuStyle>().flatColor;
    }

    if (sudokuObject.isOriginal && !sudokuObject.isSelected) {
      textColor = locator<SudokuStyle>().flatColor;
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
              color: needThickRight
                  ? locator<SudokuStyle>().borderColor
                  : borderColor,
              width: needThickRight ? 3 : 1,
            ),
            bottom: BorderSide(
              color: needThickBottom
                  ? locator<SudokuStyle>().borderColor
                  : borderColor,
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
  }
}

class ImageCell extends StatelessWidget {
  const ImageCell({required this.value, required this.path, super.key});

  final int value;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: value == 0
          ? const SizedBox.shrink()
          : Image.asset('$path/0$value.png', fit: BoxFit.contain),
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
                fontFamily: 'Overbit Regular',
              ),
              child: Text(
                '$value',
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
