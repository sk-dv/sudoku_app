import 'package:flutter/material.dart';
import 'package:sudoku_app/header.dart';
import 'package:sudoku_app/sudoku_game_model.dart';

class SudokuGameScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const SudokuGameScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  late SudokuGameModel _gameModel;

  @override
  void initState() {
    super.initState();
    _gameModel = SudokuGameModel.initialize();
  }

  void _updateGameModel(SudokuGameModel newModel) {
    setState(() {
      _gameModel = newModel;
    });
  }

  void _selectCell(int row, int col) {
    _updateGameModel(_gameModel.selectCell(row, col));
  }

  void _enterNumber(int number) {
    _updateGameModel(_gameModel.enterNumber(number));
  }

  void _clearCell() {
    _updateGameModel(_gameModel.clearCell());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
            ),
            _buildSudokuBoard(),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildSudokuBoard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final highlightColor =
        widget.isDarkMode ? const Color(0xFF4361EE) : const Color(0xFF3B5BD9);
    final borderColor =
        widget.isDarkMode ? const Color(0xFF2A3A55) : const Color(0xFFD0D5DC);
    final accentColor =
        widget.isDarkMode ? const Color(0xFF6952DC) : const Color(0xFF5346A5);

    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!widget.isDarkMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ],
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
                  Color cellColor = colorScheme.surface;
                  if (_gameModel.isSelected[row][col]) {
                    cellColor = highlightColor;
                  } else if (_gameModel.isHighlighted[row][col]) {
                    cellColor = colorScheme.primary.withOpacity(0.3);
                  }

                  // Determinar diseño de borde para crear líneas de subcuadrículas
                  BorderSide rightBorder =
                      BorderSide(color: borderColor, width: 1);
                  BorderSide bottomBorder =
                      BorderSide(color: borderColor, width: 1);

                  // Bordes más gruesos para las subcuadrículas
                  if (col % 3 == 2 && col < 8) {
                    rightBorder = BorderSide(color: highlightColor, width: 2);
                  }
                  if (row % 3 == 2 && row < 8) {
                    bottomBorder = BorderSide(color: highlightColor, width: 2);
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
                        child: _gameModel.board[row][col] != 0
                            ? Text(
                                '${_gameModel.board[row][col]}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _gameModel.isErrorCell[row][col]
                                      ? Colors.red
                                      : _gameModel.isOriginal[row][col]
                                          ? textColor
                                          : accentColor,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++)
                _buildNumberButton(i, colorScheme, textColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 6; i <= 9; i++)
                _buildNumberButton(i, colorScheme, textColor),
              _buildEraseButton(colorScheme, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(
      int number, ColorScheme colorScheme, Color textColor) {
    return GestureDetector(
      onTap: () => _enterNumber(number),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!widget.isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEraseButton(ColorScheme colorScheme, Color textColor) {
    return GestureDetector(
      onTap: () => _clearCell(),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!widget.isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Center(
          child: Icon(Icons.backspace, color: textColor),
        ),
      ),
    );
  }
}
