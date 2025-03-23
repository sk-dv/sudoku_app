import 'dart:math';

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

  // Constructor factory para crear un nuevo juego inicializado
  factory SudokuGameModel.initialize({
    DifficultLevel difficulty = DifficultLevel.medium,
  }) {
    final model = SudokuGameModel(
      board: List.generate(9, (_) => List.generate(9, (_) => 0)),
      isOriginal: List.generate(9, (_) => List.generate(9, (_) => false)),
      isSelected: List.generate(9, (_) => List.generate(9, (_) => false)),
      isHighlighted: List.generate(9, (_) => List.generate(9, (_) => false)),
      isErrorCell: List.generate(9, (_) => List.generate(9, (_) => false)),
      selectedRow: -1,
      selectedCol: -1,
      difficulty: difficulty,
      formattedTime: "00:00",
      secondsElapsed: 0,
    );

    return model._generateBoard();
  }

  // Genera un tablero de juego basado en la dificultad
  SudokuGameModel _generateBoard() {
    final Random rnd = Random();

    // Tablero de solución predefinido
    final List<List<int>> solution = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9]
    ];

    // Copiar la solución al nuevo tablero
    List<List<int>> newBoard =
        List.generate(9, (i) => List.generate(9, (j) => solution[i][j]));

    // Determinar cuántas celdas eliminar según la dificultad
    int cellsToRemove;
    switch (difficulty) {
      case DifficultLevel.veryEasy:
        cellsToRemove = 30;
        break;
      case DifficultLevel.easy:
        cellsToRemove = 40;
        break;
      case DifficultLevel.medium:
        cellsToRemove = 45;
        break;
      case DifficultLevel.hard:
        cellsToRemove = 50;
        break;
      case DifficultLevel.veryHard:
        cellsToRemove = 55;
        break;
      case DifficultLevel.master:
        cellsToRemove = 60;
        break;
    }

    // Eliminar celdas aleatoriamente
    int cellsRemoved = 0;
    while (cellsRemoved < cellsToRemove) {
      int row = rnd.nextInt(9);
      int col = rnd.nextInt(9);

      if (newBoard[row][col] != 0) {
        newBoard[row][col] = 0;
        cellsRemoved++;
      }
    }

    // Crear matriz de celdas originales
    List<List<bool>> newIsOriginal =
        List.generate(9, (i) => List.generate(9, (j) => newBoard[i][j] != 0));

    return SudokuGameModel(
      board: newBoard,
      isOriginal: newIsOriginal,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
      isErrorCell: isErrorCell,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
      difficulty: difficulty,
      formattedTime: formattedTime,
      secondsElapsed: secondsElapsed,
    );
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
