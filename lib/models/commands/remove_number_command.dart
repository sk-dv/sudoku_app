import 'package:sudoku_app/models/game_command.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';

class RemoveNumberCommand extends GameCommand {
  final (int, int) cell;
  final int removedValue;

  RemoveNumberCommand({
    required this.cell,
    required this.removedValue,
    required DateTime timestamp,
    required Map<String, dynamic> metadata,
  }) : super(timestamp: timestamp, canUndo: true, metadata: metadata);

  @override
  SudokuGameModel execute(SudokuGameModel board) {
    final List<List<int>> newBoard =
        List.generate(9, (i) => List.from(board.board[i]));

    newBoard[cell.$1][cell.$2] = 0;
    return board.copy(board: newBoard).checkErrors();
  }

  @override
  SudokuGameModel undo(SudokuGameModel board) {
    final List<List<int>> newBoard =
        List.generate(9, (i) => List.from(board.board[i]));

    newBoard[cell.$1][cell.$2] = removedValue;
    return board.copy(board: newBoard).checkErrors();
  }

  @override
  String get commandType => 'RemoveNumber';

  @override
  String description() {
    return 'RemoveNumber: [${cell.$1}, ${cell.$2}] removed $removedValue';
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'RemoveNumber',
        'cell': cell,
        'removedValue': removedValue,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  factory RemoveNumberCommand.fromJson(Map<String, dynamic> json) {
    return RemoveNumberCommand(
      cell: (json['cell'][0] as int, json['cell'][1] as int),
      removedValue: json['removedValue'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
