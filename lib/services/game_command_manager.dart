import 'package:sudoku_app/models/commands/place_number_command.dart';
import 'package:sudoku_app/models/commands/remove_number_command.dart';
import 'package:sudoku_app/models/commands/use_hint_command.dart';
import 'package:sudoku_app/models/game_command.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';

class GameCommandManager {
  final List<GameCommand> _commandHistory = [];
  static const int maxHistorySize = 500;

  List<GameCommand> get commandHistory => List.unmodifiable(_commandHistory);

  bool get hasCommands {
    return _commandHistory
        .where((cmd) => cmd.commandType != 'UseHint')
        .isNotEmpty;
  }

  int get commandCount => _commandHistory.length;

  /// Ejecuta un comando, lo añade al historial y retorna el nuevo estado
  SudokuGameModel executeCommand(
    GameCommand command,
    SudokuGameModel currentBoard,
  ) {
    // Ejecutar el comando
    final newBoard = command.execute(currentBoard);

    // Agregarlo al historial
    _commandHistory.add(command);

    // Limitar historial si excede tamaño máximo
    if (_commandHistory.length > maxHistorySize) {
      _commandHistory.removeAt(0);
    }

    return newBoard;
  }

  /// Deshace el último comando si es posible
  SudokuGameModel? undo(SudokuGameModel currentBoard) {
    if (_commandHistory.isEmpty || !_commandHistory.last.canUndo) return null;

    final restoredBoard = _commandHistory.last.undo(currentBoard);

    _commandHistory.removeLast();
    return restoredBoard;
  }

  GameCommand createPlaceNumberCommand({
    required (int, int) cell,
    required int value,
    required int? previousValue,
    required double boardProgressPercentage,
  }) {
    return PlaceNumberCommand(
      cell: cell,
      value: value,
      previousValue: previousValue,
      timestamp: DateTime.now(),
      metadata: {'cell': cell, 'boardProgress': boardProgressPercentage},
    );
  }

  /// Crea un RemoveNumberCommand
  GameCommand createRemoveNumberCommand({
    required (int, int) cell,
    required int removedValue,
    required double boardProgressPercentage,
  }) {
    return RemoveNumberCommand(
      cell: cell,
      removedValue: removedValue,
      timestamp: DateTime.now(),
      metadata: {'cell': cell, 'boardProgress': boardProgressPercentage},
    );
  }

  /// Crea un UseHintCommand
  GameCommand createUseHintCommand({
    required (int, int) cell,
    required int revealedValue,
    required int? previousValue,
    required int hintIndex,
    required double boardProgressPercentage,
  }) {
    return UseHintCommand(
      cell: cell,
      revealedValue: revealedValue,
      previousValue: previousValue,
      hintIndex: hintIndex,
      timestamp: DateTime.now(),
      metadata: {
        'cell': cell,
        'boardProgress': boardProgressPercentage,
        'hintUsageType': 'USED',
      },
    );
  }

  /// Calcula el progreso del tablero (0-100)
  double calculateBoardProgress(SudokuGameModel model) {
    int filledCells = 0;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (model.board[i][j] != 0) {
          filledCells++;
        }
      }
    }
    return double.parse(((filledCells / 81) * 100).toStringAsFixed(1));
  }

  /// Exporta historial para persistencia o análisis
  List<Map<String, dynamic>> exportHistory() {
    return _commandHistory.map((cmd) => cmd.toJson()).toList();
  }

  /// Importa historial desde JSON
  void importHistory(List<Map<String, dynamic>> jsonCommands) {
    _commandHistory.clear();
    for (final json in jsonCommands) {
      _commandHistory.add(GameCommand.fromJson(json));
    }
  }

  /// Obtiene estadísticas del historial
  Map<String, dynamic> getStatistics() {
    if (_commandHistory.isEmpty) {
      return {
        'totalCommands': 0,
        'placeNumberCount': 0,
        'removeNumberCount': 0,
        'useHintCount': 0,
        'totalErrors': 0,
        'errorsByType': {
          'ROW_DUPLICATE': 0,
          'COL_DUPLICATE': 0,
          'BLOCK_DUPLICATE': 0
        },
      };
    }

    int placeCount = 0;
    int removeCount = 0;
    int hintCount = 0;
    int totalErrors = 0;
    final errorsByType = {
      'ROW_DUPLICATE': 0,
      'COL_DUPLICATE': 0,
      'BLOCK_DUPLICATE': 0
    };

    for (final cmd in _commandHistory) {
      switch (cmd.commandType) {
        case 'PlaceNumber':
          placeCount++;
          final errorType = cmd.metadata['errorType'] as String?;
          if (errorType != null) {
            totalErrors++;
            errorsByType[errorType] = (errorsByType[errorType] ?? 0) + 1;
          }
          break;
        case 'RemoveNumber':
          removeCount++;
          break;
        case 'UseHint':
          hintCount++;
          break;
      }
    }

    return {
      'totalCommands': _commandHistory.length,
      'placeNumberCount': placeCount,
      'removeNumberCount': removeCount,
      'useHintCount': hintCount,
      'totalErrors': totalErrors,
      'errorsByType': errorsByType,
    };
  }

  /// Replay: aplica comandos hasta un índice específico
  SudokuGameModel replayToStep(SudokuGameModel initialBoard, int stepIndex) {
    if (stepIndex < 0 || stepIndex > _commandHistory.length) {
      throw Exception('Invalid step index: $stepIndex');
    }

    SudokuGameModel result = initialBoard;
    for (int i = 0; i < stepIndex; i++) {
      result = _commandHistory[i].execute(result);
    }

    return result;
  }
}
