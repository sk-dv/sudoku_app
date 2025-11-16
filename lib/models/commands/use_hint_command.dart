import 'package:sudoku_app/models/game_command.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';

class UseHintCommand extends GameCommand {
  final (int, int) cell;
  final int revealedValue;
  final int? previousValue;
  final int hintIndex;

  UseHintCommand({
    required this.cell,
    required this.revealedValue,
    required this.previousValue,
    required this.hintIndex,
    required DateTime timestamp,
    required Map<String, dynamic> metadata,
  }) : super(timestamp: timestamp, canUndo: false, metadata: metadata);

  @override
  SudokuGameModel execute(SudokuGameModel board) {
    // Colocar el número revelado
    final List<List<int>> newBoard =
        List.generate(9, (i) => List.from(board.board[i]));

    newBoard[cell.$1][cell.$2] = revealedValue;

    // Decrementar hints disponibles
    final newHintsRemaining =
        (board.hintsRemaining - 1).clamp(0, board.maxHints);

    final updatedModel = board.copy(
      board: newBoard,
      hintsRemaining: newHintsRemaining,
    );

    return updatedModel.checkErrors();
  }

  @override
  SudokuGameModel undo(SudokuGameModel board) {
    throw UnsupportedError(
      'Cannot undo hint usage. Hints are irreversible in this game.',
    );
  }

  @override
  String get commandType => 'UseHint';

  @override
  String description() {
    return 'UseHint: revealed [${cell.$1}, ${cell.$2}] = $revealedValue (hint #$hintIndex)';
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'UseHint',
        'cell': cell,
        'revealedValue': revealedValue,
        'previousValue': previousValue,
        'hintIndex': hintIndex,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  factory UseHintCommand.fromJson(Map<String, dynamic> json) {
    return UseHintCommand(
      cell: (json['cell'][0] as int, json['cell'][1] as int),
      revealedValue: json['revealedValue'] as int,
      previousValue: json['previousValue'] as int?,
      hintIndex: json['hintIndex'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
