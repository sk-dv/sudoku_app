import 'package:flutter/material.dart';
import 'package:sudoku_app/header.dart';
import 'dart:math';

import 'bottom_bar.dart';

class SudokuGameScreen extends StatefulWidget {
  const SudokuGameScreen({super.key});

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  late List<List<int>> board;
  late List<List<bool>> isOriginal;
  late List<List<bool>> isSelected;
  late List<List<bool>> isHighlighted;
  late List<List<bool>> isErrorCell;
  int selectedRow = -1;
  int selectedCol = -1;
  final DifficultLevel difficulty = DifficultLevel.medium;
  String formattedTime = "00:00";
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Inicializar el tablero con ceros (celdas vacías)
    board = List.generate(9, (_) => List.generate(9, (_) => 0));
    isOriginal = List.generate(9, (_) => List.generate(9, (_) => false));
    isSelected = List.generate(9, (_) => List.generate(9, (_) => false));
    isHighlighted = List.generate(9, (_) => List.generate(9, (_) => false));
    isErrorCell = List.generate(9, (_) => List.generate(9, (_) => false));

    // Generar un tablero con algunos números predefinidos
    _generateBoard();

    // Iniciar el cronómetro
    _startTimer();
  }

  void _generateBoard() {
    // Este es un tablero de ejemplo, en una implementación real utilizarías
    // un algoritmo para generar un tablero válido
    final Random rnd = Random();

    // Definir un tablero válido para este ejemplo
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

    // Copiar la solución al tablero
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        board[i][j] = solution[i][j];
      }
    }

    // Eliminar algunos números según la dificultad
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

    int cellsRemoved = 0;
    while (cellsRemoved < cellsToRemove) {
      int row = rnd.nextInt(9);
      int col = rnd.nextInt(9);

      if (board[row][col] != 0) {
        board[row][col] = 0;
        cellsRemoved++;
      }
    }

    // Marcar las celdas originales (no modificables)
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        isOriginal[i][j] = board[i][j] != 0;
      }
    }
  }

  void _startTimer() {
    // En una implementación real, utilizarías un Timer real
    secondsElapsed = 0;
    formattedTime = "00:00";
  }

  void _selectCell(int row, int col) {
    // Reiniciar todas las celdas seleccionadas y resaltadas
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        isSelected[i][j] = false;
        isHighlighted[i][j] = false;
      }
    }

    // Marcar la celda seleccionada
    if (row >= 0 && col >= 0) {
      isSelected[row][col] = true;
      selectedRow = row;
      selectedCol = col;

      // Resaltar la fila, columna y subcuadrícula
      for (int i = 0; i < 9; i++) {
        isHighlighted[row][i] = true; // fila
        isHighlighted[i][col] = true; // columna
      }

      // Resaltar subcuadrícula 3x3
      int startRow = (row ~/ 3) * 3;
      int startCol = (col ~/ 3) * 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          isHighlighted[startRow + i][startCol + j] = true;
        }
      }
    } else {
      selectedRow = -1;
      selectedCol = -1;
    }

    setState(() {});
  }

  void _enterNumber(int number) {
    if (selectedRow >= 0 &&
        selectedCol >= 0 &&
        !isOriginal[selectedRow][selectedCol]) {
      setState(() {
        board[selectedRow][selectedCol] = number;
        // Comprobar errores
        _checkErrors();
      });
    }
  }

  void _checkErrors() {
    // Reiniciar errores
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        isErrorCell[i][j] = false;
      }
    }

    // Comprobar errores en filas
    for (int row = 0; row < 9; row++) {
      List<int> seen = [];
      for (int col = 0; col < 9; col++) {
        if (board[row][col] != 0) {
          if (seen.contains(board[row][col])) {
            // Marcar todas las ocurrencias como error
            for (int c = 0; c < 9; c++) {
              if (board[row][c] == board[row][col]) {
                isErrorCell[row][c] = true;
              }
            }
          } else {
            seen.add(board[row][col]);
          }
        }
      }
    }

    // Comprobar errores en columnas
    for (int col = 0; col < 9; col++) {
      List<int> seen = [];
      for (int row = 0; row < 9; row++) {
        if (board[row][col] != 0) {
          if (seen.contains(board[row][col])) {
            // Marcar todas las ocurrencias como error
            for (int r = 0; r < 9; r++) {
              if (board[r][col] == board[row][col]) {
                isErrorCell[r][col] = true;
              }
            }
          } else {
            seen.add(board[row][col]);
          }
        }
      }
    }

    // Comprobar errores en subcuadrículas 3x3
    for (int blockRow = 0; blockRow < 3; blockRow++) {
      for (int blockCol = 0; blockCol < 3; blockCol++) {
        List<int> seen = [];
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            int row = blockRow * 3 + i;
            int col = blockCol * 3 + j;
            if (board[row][col] != 0) {
              if (seen.contains(board[row][col])) {
                // Marcar todas las ocurrencias como error
                for (int r = 0; r < 3; r++) {
                  for (int c = 0; c < 3; c++) {
                    int r2 = blockRow * 3 + r;
                    int c2 = blockCol * 3 + c;
                    if (board[r2][c2] == board[row][col]) {
                      isErrorCell[r2][c2] = true;
                    }
                  }
                }
              } else {
                seen.add(board[row][col]);
              }
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            _buildSudokuBoard(),
            _buildKeypad(),
            const BottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSudokuBoard() {
    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                ),
                itemCount: 81,
                itemBuilder: (context, index) {
                  final row = index ~/ 9;
                  final col = index % 9;

                  // Determinar color de fondo según selección y resaltado
                  Color cellColor = Theme.of(context).colorScheme.surface;
                  if (isSelected[row][col]) {
                    cellColor = const Color(0xFF4361EE);
                  } else if (isHighlighted[row][col]) {
                    cellColor =
                        Theme.of(context).colorScheme.primary.withOpacity(0.3);
                  }

                  // Determinar diseño de borde para crear líneas de subcuadrículas
                  BorderSide rightBorder =
                      const BorderSide(color: Color(0xFF2A3A55), width: 1);
                  BorderSide bottomBorder =
                      const BorderSide(color: Color(0xFF2A3A55), width: 1);

                  // Bordes más gruesos para las subcuadrículas
                  if (col % 3 == 2 && col < 8) {
                    rightBorder =
                        const BorderSide(color: Color(0xFF4361EE), width: 2);
                  }
                  if (row % 3 == 2 && row < 8) {
                    bottomBorder =
                        const BorderSide(color: Color(0xFF4361EE), width: 2);
                  }

                  return GestureDetector(
                    onTap: () => _selectCell(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        border: Border(
                          right: rightBorder,
                          bottom: bottomBorder,
                        ),
                      ),
                      child: Center(
                        child: board[row][col] != 0
                            ? Text(
                                '${board[row][col]}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isErrorCell[row][col]
                                      ? Colors.red
                                      : isOriginal[row][col]
                                          ? Colors.white
                                          : const Color(0xFF6952DC),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++) _buildNumberButton(i),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 6; i <= 9; i++) _buildNumberButton(i),
              _buildEraseButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return GestureDetector(
      onTap: () => _enterNumber(number),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEraseButton() {
    return GestureDetector(
      onTap: () {
        if (selectedRow >= 0 &&
            selectedCol >= 0 &&
            !isOriginal[selectedRow][selectedCol]) {
          setState(() {
            board[selectedRow][selectedCol] = 0;
            _checkErrors();
          });
        }
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.backspace, color: Colors.white),
        ),
      ),
    );
  }
}

enum DifficultLevel { veryEasy, easy, medium, hard, veryHard, master }
