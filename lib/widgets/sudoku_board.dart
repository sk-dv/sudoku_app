import 'package:flutter/material.dart';

import 'package:sudoku_app/data/sudoku_list_management.dart';
import 'package:sudoku_app/data/sudoku_object.dart';
import 'package:sudoku_app/widgets/sudoku_grid.dart';

class SudokuBoard extends StatefulWidget {
  const SudokuBoard({super.key});

  @override
  State<SudokuBoard> createState() => _SudokuBoardState();
}

class _SudokuBoardState extends State<SudokuBoard> {
  late final List<List<SudokuObject>> boardObject;
  int selectedRow = -1;
  int selectedCol = -1;

  @override
  void initState() {
    super.initState();
    _initializeDemo();
  }

  void _initializeDemo() {
    boardObject = SudokuListManagement.fromBoard([
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9]
    ]);
  }

  void _selectCell(int row, int col) {
    setState(() {
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          boardObject[i][j] = boardObject[i][j].copy(isSelected: false);
          boardObject[i][j] = boardObject[i][j].copy(isHighlighted: false);
        }
      }

      boardObject[row][col] = boardObject[row][col].copy(isSelected: true);
      selectedRow = row;
      selectedCol = col;

      for (int i = 0; i < 9; i++) {
        boardObject[row][i] = boardObject[row][i].copy(isHighlighted: true);
        boardObject[i][col] = boardObject[i][col].copy(isHighlighted: true);
      }

      int startRow = (row ~/ 3) * 3;
      int startCol = (col ~/ 3) * 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          boardObject[startRow + i][startCol + j] =
              boardObject[startRow + i][startCol + j].copy(isHighlighted: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SudokuGrid(boardObject: boardObject, onCellTap: _selectCell);
  }
}
