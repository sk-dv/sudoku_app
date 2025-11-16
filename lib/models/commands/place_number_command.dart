import 'package:sudoku_app/models/game_command.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';

class PlaceNumberCommand extends GameCommand {
  final (int, int) cell;
  final int value;
  final int? previousValue;
  final bool errorOccurred;

  PlaceNumberCommand({
    required this.cell,
    required this.value,
    required this.previousValue,
    this.errorOccurred = false,
    required DateTime timestamp,
    required Map<String, dynamic> metadata,
  }) : super(timestamp: timestamp, canUndo: true, metadata: metadata);

  @override
  SudokuGameModel execute(SudokuGameModel board) {
    final (newBoard, errorType) = _checkErrorType(board, cell, value);
    metadata['errorType'] = errorType.name;

    // Colocar el número (incluso si hay error)
    newBoard[cell.$1][cell.$2] = value;

    // checkErrors() verifica validez de todo el tablero
    return board.copy(board: newBoard).checkErrors();
  }

  @override
  SudokuGameModel undo(SudokuGameModel board) {
    final List<List<int>> newBoard =
        List.generate(9, (i) => List.from(board.board[i]));

    newBoard[cell.$1][cell.$2] = previousValue ?? 0;
    return board.copy(board: newBoard).checkErrors();
  }

  @override
  String get commandType => 'PlaceNumber';

  @override
  String description() {
    return 'PlaceNumber: [${cell.$1}, ${cell.$2}] = $value (was: $previousValue)';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'PlaceNumber',
      'cell': cell,
      'value': value,
      'previousValue': previousValue,
      'errorOccurred': errorOccurred,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PlaceNumberCommand.fromJson(Map<String, dynamic> json) {
    return PlaceNumberCommand(
      cell: (json['cell'][0] as int, json['cell'][1] as int),
      value: json['value'] as int,
      previousValue: json['previousValue'] as int?,
      errorOccurred: json['errorOccurred'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

(List<List<int>>, ErrorType) _checkErrorType(
  SudokuGameModel board,
  (int, int) cell,
  int value,
) {
  // Crear copia mutable del board
  final List<List<int>> newBoard =
      List.generate(9, (i) => List.from(board.board[i]));

  // Detectar errores
  bool hasRowDuplicate = false;
  bool hasColDuplicate = false;
  bool hasBlockDuplicate = false;

  // Verificar fila
  for (int j = 0; j < 9; j++) {
    if (j != cell.$2 && newBoard[cell.$1][j] == value) {
      hasRowDuplicate = true;
      break;
    }
  }

  // Verificar columna
  if (!hasRowDuplicate) {
    for (int i = 0; i < 9; i++) {
      if (i != cell.$1 && newBoard[i][cell.$2] == value) {
        hasColDuplicate = true;
        break;
      }
    }
  }

  // Verificar bloque 3x3
  if (!hasRowDuplicate && !hasColDuplicate) {
    final blockRow = (cell.$1 ~/ 3) * 3;
    final blockCol = (cell.$2 ~/ 3) * 3;

    for (int i = blockRow; i < blockRow + 3; i++) {
      for (int j = blockCol; j < blockCol + 3; j++) {
        if ((i != cell.$1 || j != cell.$2) && newBoard[i][j] == value) {
          hasBlockDuplicate = true;
          break;
        }
      }
      if (hasBlockDuplicate) break;
    }
  }

  // Registrar tipo de error si existe
  ErrorType errorType() {
    if (hasRowDuplicate) {
      return ErrorType.rowDuplicate;
    } else if (hasColDuplicate) {
      return ErrorType.columnDuplicate;
    } else if (hasBlockDuplicate) {
      return ErrorType.blockDuplicate;
    } else {
      return ErrorType.none;
    }
  }

  return (newBoard, errorType());
}
