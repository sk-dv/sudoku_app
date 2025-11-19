import 'package:sudoku_app/screens/level_selection_screen.dart';

import 'sudoku_game.dart';

class SudokuGameModel {
  final List<List<int>> board;
  final List<List<bool>> isOriginal;
  final List<List<bool>> isSelected;
  final List<List<bool>> isHighlighted;
  final List<List<bool>> isErrorCell;
  final (int, int) selectedCell;
  final DifficultLevel difficulty;
  final int secondsElapsed;
  final bool isCompleted;
  final int hintsRemaining;
  final int maxHints;
  final List<(int, int)> hintsCoordinates;
  final List<List<int>> solutionGrid;

  const SudokuGameModel({
    required this.board,
    required this.isOriginal,
    required this.isSelected,
    required this.isHighlighted,
    required this.isErrorCell,
    required this.selectedCell,
    required this.difficulty,
    required this.secondsElapsed,
    this.isCompleted = false,
    required this.hintsRemaining,
    required this.maxHints,
    this.hintsCoordinates = const [],
    this.solutionGrid = const [],
  });

  SudokuGameModel copy({
    List<List<int>>? board,
    List<List<bool>>? isOriginal,
    List<List<bool>>? isSelected,
    List<List<bool>>? isHighlighted,
    List<List<bool>>? isErrorCell,
    (int, int)? selectedCell,
    DifficultLevel? difficulty,
    int? secondsElapsed,
    bool? isCompleted,
    int? hintsRemaining,
    int? maxHints,
    List<(int, int)>? hintsCoordinates,
    List<List<int>>? solutionGrid,
  }) {
    return SudokuGameModel(
      board: board ?? this.board,
      isOriginal: isOriginal ?? this.isOriginal,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isErrorCell: isErrorCell ?? this.isErrorCell,
      selectedCell: selectedCell ?? this.selectedCell,
      difficulty: difficulty ?? this.difficulty,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      isCompleted: isCompleted ?? this.isCompleted,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      maxHints: maxHints ?? this.maxHints,
      hintsCoordinates: hintsCoordinates ?? this.hintsCoordinates,
      solutionGrid: solutionGrid ?? this.solutionGrid,
    );
  }

  factory SudokuGameModel.fromSudokuGame({
    required SudokuGame sudokuGame,
    DifficultLevel difficulty = DifficultLevel.medium,
  }) {
    final model = SudokuGameModel(
      board: List.generate(9, (i) => List.from(sudokuGame.playableGrid[i])),
      isOriginal: List.generate(
        9,
        (i) => List.generate(9, (j) => sudokuGame.playableGrid[i][j] != 0),
      ),
      isSelected: List.generate(9, (_) => List.generate(9, (_) => false)),
      isHighlighted: List.generate(9, (_) => List.generate(9, (_) => false)),
      isErrorCell: List.generate(9, (_) => List.generate(9, (_) => false)),
      selectedCell: (-1, -1),
      difficulty: difficulty,
      secondsElapsed: 0,
      hintsRemaining: sudokuGame.hintsCoordinates.length,
      maxHints: sudokuGame.hintsCoordinates.length,
      solutionGrid: List.generate(
        9,
        (i) => List.from(sudokuGame.solutionGrid[i]),
      ),
      hintsCoordinates:
          sudokuGame.hintsCoordinates.map((c) => (c[0], c[1])).toList(),
    );

    return model.checkErrors();
  }

  SudokuGameModel useHint() {
    return copy(hintsRemaining: hintsRemaining - 1);
  }

  SudokuGameModel selectCell((int, int) cell) {
    final newIsSelected =
        List.generate(9, (i) => List.generate(9, (j) => false));

    final newIsHighlighted =
        List.generate(9, (i) => List.generate(9, (j) => false));

    (int, int) newSelectedCell = (-1, -1);

    if (cell.$1 >= 0 && cell.$2 >= 0) {
      newIsSelected[cell.$1][cell.$2] = true;
      newSelectedCell = cell;

      for (int i = 0; i < 9; i++) {
        newIsHighlighted[cell.$1][i] = true;
        newIsHighlighted[i][cell.$2] = true;
      }

      // Resaltar subcuadrícula 3x3
      int startRow = (cell.$1 ~/ 3) * 3;
      int startCol = (cell.$2 ~/ 3) * 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          newIsHighlighted[startRow + i][startCol + j] = true;
        }
      }
    }

    return copy(
      isSelected: newIsSelected,
      isHighlighted: newIsHighlighted,
      selectedCell: newSelectedCell,
    );
  }

  SudokuGameModel enterNumber(int number) {
    if (selectedCell.$1 >= 0 &&
        selectedCell.$2 >= 0 &&
        !isOriginal[selectedCell.$1][selectedCell.$2]) {
      List<List<int>> newBoard = List.generate(9, (i) => List.from(board[i]));

      newBoard[selectedCell.$1][selectedCell.$2] = number;
      return copy(board: newBoard).checkErrors();
    }

    return this;
  }

  SudokuGameModel clearCell() {
    if (!isOriginal[selectedCell.$1][selectedCell.$2]) {
      List<List<int>> newBoard = List.generate(9, (i) => List.from(board[i]));

      newBoard[selectedCell.$1][selectedCell.$2] = 0;
      return copy(board: newBoard).checkErrors();
    }

    return this;
  }

  SudokuGameModel checkErrors() {
    List<List<bool>> newIsErrorCell =
        List.generate(9, (i) => List.generate(9, (j) => false));

    bool hasErrors = false;

    // Verificar filas
    for (int row = 0; row < 9; row++) {
      Map<int, List<int>> numPositions = {};
      for (int col = 0; col < 9; col++) {
        final num = board[row][col];
        if (num != 0) {
          numPositions.putIfAbsent(num, () => []);
          numPositions[num]!.add(col);
        }
      }

      for (var entry in numPositions.entries) {
        if (entry.value.length > 1) {
          hasErrors = true;
          for (int col in entry.value) {
            newIsErrorCell[row][col] = true;
          }
        }
      }
    }

    for (int col = 0; col < 9; col++) {
      Map<int, List<int>> numPositions = {};
      for (int row = 0; row < 9; row++) {
        final num = board[row][col];
        if (num != 0) {
          numPositions.putIfAbsent(num, () => []);
          numPositions[num]!.add(row);
        }
      }

      for (var entry in numPositions.entries) {
        if (entry.value.length > 1) {
          hasErrors = true;
          for (int row in entry.value) {
            newIsErrorCell[row][col] = true;
          }
        }
      }
    }

    for (int blockRow = 0; blockRow < 3; blockRow++) {
      for (int blockCol = 0; blockCol < 3; blockCol++) {
        Map<int, List<List<int>>> numPositions = {};

        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int row = blockRow * 3 + i;
            int col = blockCol * 3 + j;
            final num = board[row][col];

            if (num != 0) {
              numPositions.putIfAbsent(num, () => []);
              numPositions[num]!.add([row, col]);
            }
          }
        }

        for (var entry in numPositions.entries) {
          if (entry.value.length > 1) {
            hasErrors = true;
            for (var pos in entry.value) {
              newIsErrorCell[pos[0]][pos[1]] = true;
            }
          }
        }
      }
    }

    // Verificar si está completo (sin errores y sin celdas vacías)
    bool isBoardComplete = !hasErrors && _isBoardFull();
    return copy(isErrorCell: newIsErrorCell, isCompleted: isBoardComplete);
  }

  bool _isBoardFull() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }
}

extension SudokuGameModelList on SudokuGameModel {
  bool originalAt((int, int) coord) {
    return isOriginal[coord.$1][coord.$2];
  }

  int valueAt((int, int) coord) {
    return board[coord.$1][coord.$2];
  }
}
