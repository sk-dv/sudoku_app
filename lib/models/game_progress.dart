import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'package:uuid/uuid.dart';

import 'sudoku_game_model.dart';

enum GameSource { daily, level }

class GameProgress {
  final String id;
  final List<List<int>> board;
  final int hintIdx;
  final int timeElapsed;
  final DifficultLevel difficulty;
  final GameSource gameSource;
  final DateTime savedAt;
  final List<(int, int)> hintCoordinates;
  final List<List<int>> solutionGrid;

  const GameProgress({
    required this.id,
    required this.board,
    required this.hintIdx,
    required this.timeElapsed,
    required this.difficulty,
    required this.gameSource,
    required this.savedAt,
    required this.hintCoordinates,
    required this.solutionGrid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'board': board,
      'hintIdx': hintIdx,
      'timeElapsed': timeElapsed,
      'difficulty': difficulty.name,
      'gameSource': gameSource.name,
      'savedAt': savedAt.toIso8601String(),
      'hintCoordinates':
          hintCoordinates.map((coord) => [coord.$1, coord.$2]).toList(),
      'solutionGrid': solutionGrid,
    };
  }

  factory GameProgress.fromMap(Map<String, dynamic> map) {
    return GameProgress(
      id: map['id'],
      board: List<List<int>>.from(
        map['board'].map((row) => List<int>.from(row)),
      ),
      hintIdx: map['hintIdx'],
      timeElapsed: map['timeElapsed'],
      difficulty: DifficultLevel.values.byName(map['difficulty']),
      gameSource: GameSource.values.byName(map['gameSource']),
      savedAt: DateTime.parse(map['savedAt']),
      hintCoordinates: (map['hintCoordinates'] as List)
          .map((coord) => (coord[0] as int, coord[1] as int))
          .toList(),
      solutionGrid: List<List<int>>.from(
        map['solutionGrid'].map((row) => List<int>.from(row)),
      ),
    );
  }

  factory GameProgress.fromGameModel(SavedGame game) {
    return GameProgress(
      id: const Uuid().v4(),
      board: game.model.board,
      hintIdx: game.idx,
      timeElapsed: game.model.secondsElapsed,
      difficulty: game.model.difficulty,
      gameSource: game.source,
      savedAt: DateTime.now(),
      hintCoordinates: game.model.hintsCoordinates,
      solutionGrid: game.model.solutionGrid,
    );
  }

  SudokuGameModel toSudokuGameModel() {
    print(timeElapsed);
    return SudokuGameModel(
      board: board,
      isOriginal: List.generate(
        9,
        (i) => List.generate(9, (j) => board[i][j] != 0),
      ),
      isSelected: List.generate(9, (_) => List.generate(9, (_) => false)),
      isHighlighted: List.generate(9, (_) => List.generate(9, (_) => false)),
      isErrorCell: List.generate(9, (_) => List.generate(9, (_) => false)),
      selectedCell: (-1, -1),
      difficulty: difficulty,
      secondsElapsed: timeElapsed,
      maxHints: hintCoordinates.length,
      solutionGrid: solutionGrid,
      hintsRemaining: hintCoordinates.length - hintIdx,
      hintsCoordinates: hintCoordinates,
    );
  }
}

class SavedGame {
  const SavedGame({
    required this.model,
    required this.idx,
    required this.source,
    required this.elapsedSeconds,
  });

  final SudokuGameModel model;
  final int idx;
  final GameSource source;
  final int elapsedSeconds;
}
