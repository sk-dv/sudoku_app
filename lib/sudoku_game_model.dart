import 'sudoku_game.dart';

enum DifficultLevel { veryEasy, easy, medium, hard, veryHard, master }

// Modelo inmutable para el juego de Sudoku
class SudokuGameModel {
  final List<List<int>> board;
  final List<List<bool>> isOriginal;
  final List<List<bool>> isSelected;
  final List<List<bool>> isHighlighted;
  final List<List<bool>> isErrorCell;
  final int selectedRow;
  final int selectedCol;
  final DifficultLevel difficulty;
  final String formattedTime;
  final int secondsElapsed;

  const SudokuGameModel({
    required this.board,
    required this.isOriginal,
    required this.isSelected,
    required this.isHighlighted,
    required this.isErrorCell,
    required this.selectedRow,
    required this.selectedCol,
    required this.difficulty,
    required this.formattedTime,
    required this.secondsElapsed,
  });

  // Constructor factory para crear un nuevo juego desde un SudokuGame
  factory SudokuGameModel.fromSudokuGame({
    required SudokuGame sudokuGame,
    DifficultLevel difficulty = DifficultLevel.medium,
  }) {
    // Crear matriz de celdas originales (celdas con números != 0)
    List<List<bool>> newIsOriginal = List.generate(
        9, (i) => List.generate(9, (j) => sudokuGame.playableGrid[i][j] != 0));

    final model = SudokuGameModel(
      board: List.generate(9, (i) => List.from(sudokuGame.playableGrid[i])),
      isOriginal: newIsOriginal,
      isSelected: List.generate(9, (_) => List.generate(9, (_) => false)),
      isHighlighted: List.generate(9, (_) => List.generate(9, (_) => false)),
      isErrorCell: List.generate(9, (_) => List.generate(9, (_) => false)),
      selectedRow: -1,
      selectedCol: -1,
      difficulty: difficulty,
      formattedTime: "00:00",
      secondsElapsed: 0,
    );

    return model.checkErrors();
  }

  // Selecciona una celda y actualiza las celdas resaltadas
  SudokuGameModel selectCell(int row, int col) {
    List<List<bool>> newIsSelected =
        List.generate(9, (i) => List.generate(9, (j) => false));

    List<List<bool>> newIsHighlighted =
        List.generate(9, (i) => List.generate(9, (j) => false));

    int newSelectedRow = -1;
    int newSelectedCol = -1;

    if (row >= 0 && col >= 0) {
      newIsSelected[row][col] = true;
      newSelectedRow = row;
      newSelectedCol = col;

      // Resaltar fila y columna
      for (int i = 0; i < 9; i++) {
        newIsHighlighted[row][i] = true;
        newIsHighlighted[i][col] = true;
      }

      // Resaltar subcuadrícula 3x3
      int startRow = (row ~/ 3) * 3;
      int startCol = (col ~/ 3) * 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          newIsHighlighted[startRow + i][startCol + j] = true;
        }
      }
    }

    return SudokuGameModel(
      board: board,
      isOriginal: isOriginal,
      isSelected: newIsSelected,
      isHighlighted: newIsHighlighted,
      isErrorCell: isErrorCell,
      selectedRow: newSelectedRow,
      selectedCol: newSelectedCol,
      difficulty: difficulty,
      formattedTime: formattedTime,
      secondsElapsed: secondsElapsed,
    );
  }

  // Ingresa un número en la celda seleccionada
  SudokuGameModel enterNumber(int number) {
    if (selectedRow >= 0 &&
        selectedCol >= 0 &&
        !isOriginal[selectedRow][selectedCol]) {
      List<List<int>> newBoard = List.generate(9, (i) => List.from(board[i]));

      newBoard[selectedRow][selectedCol] = number;

      final updatedModel = SudokuGameModel(
        board: newBoard,
        isOriginal: isOriginal,
        isSelected: isSelected,
        isHighlighted: isHighlighted,
        isErrorCell: isErrorCell,
        selectedRow: selectedRow,
        selectedCol: selectedCol,
        difficulty: difficulty,
        formattedTime: formattedTime,
        secondsElapsed: secondsElapsed,
      );

      return updatedModel.checkErrors();
    }

    return this;
  }

  // Borra el número de la celda seleccionada
  SudokuGameModel clearCell() {
    if (selectedRow >= 0 &&
        selectedCol >= 0 &&
        !isOriginal[selectedRow][selectedCol]) {
      List<List<int>> newBoard = List.generate(9, (i) => List.from(board[i]));

      newBoard[selectedRow][selectedCol] = 0;

      final updatedModel = SudokuGameModel(
        board: newBoard,
        isOriginal: isOriginal,
        isSelected: isSelected,
        isHighlighted: isHighlighted,
        isErrorCell: isErrorCell,
        selectedRow: selectedRow,
        selectedCol: selectedCol,
        difficulty: difficulty,
        formattedTime: formattedTime,
        secondsElapsed: secondsElapsed,
      );

      return updatedModel.checkErrors();
    }

    return this;
  }

  // Verifica errores en el tablero (números duplicados)
  SudokuGameModel checkErrors() {
    List<List<bool>> newIsErrorCell =
        List.generate(9, (i) => List.generate(9, (j) => false));

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
          for (int col in entry.value) {
            newIsErrorCell[row][col] = true;
          }
        }
      }
    }

    // Verificar columnas
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
          for (int row in entry.value) {
            newIsErrorCell[row][col] = true;
          }
        }
      }
    }

    // Verificar subcuadrículas 3x3
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
            for (var pos in entry.value) {
              newIsErrorCell[pos[0]][pos[1]] = true;
            }
          }
        }
      }
    }

    return SudokuGameModel(
      board: board,
      isOriginal: isOriginal,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
      isErrorCell: newIsErrorCell,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
      difficulty: difficulty,
      formattedTime: formattedTime,
      secondsElapsed: secondsElapsed,
    );
  }
}
