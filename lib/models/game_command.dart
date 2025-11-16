import 'commands/place_number_command.dart';
import 'commands/remove_number_command.dart';
import 'commands/use_hint_command.dart';
import 'sudoku_game_model.dart';

enum ErrorType {
  rowDuplicate,
  columnDuplicate,
  blockDuplicate,
  none;

  String? get name {
    switch (this) {
      case ErrorType.rowDuplicate:
        return 'ROW_DUPLICATE';
      case ErrorType.columnDuplicate:
        return 'COL_DUPLICATE';
      case ErrorType.blockDuplicate:
        return 'BLOCK_DUPLICATE';
      case ErrorType.none:
        return null;
    }
  }
}

abstract class GameCommand {
  final DateTime timestamp;
  final bool canUndo;
  final Map<String, dynamic> metadata;

  GameCommand({
    required this.timestamp,
    required this.canUndo,
    required this.metadata,
  });

  /// Aplica el comando y retorna el nuevo estado del modelo
  SudokuGameModel execute(SudokuGameModel board);

  /// Revierte el comando y retorna el estado anterior
  SudokuGameModel undo(SudokuGameModel board);

  /// Tipo de comando para serialización
  String get commandType;

  /// Descripción legible del comando (para logs/debugging)
  String description();

  /// Serializa el comando a JSON para persistencia
  Map<String, dynamic> toJson();

  /// Factory para deserializar comandos según su tipo
  static GameCommand fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'PlaceNumber':
        return PlaceNumberCommand.fromJson(json);
      case 'RemoveNumber':
        return RemoveNumberCommand.fromJson(json);
      case 'UseHint':
        return UseHintCommand.fromJson(json);
      default:
        throw Exception('Unknown command type: $type');
    }
  }
}
