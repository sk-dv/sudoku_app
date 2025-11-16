class SudokuGame {
  final List<List<int>> playableGrid;
  final bool playableIsValid;
  final List<List<int>> solutionGrid;
  final bool solutionIsValid;
  final String difficultyLevel;
  final double difficultyCoefficient;
  final int emptyCells;
  final bool cached;
  final List<List<int>> hintsCoordinates;

  SudokuGame({
    required this.playableGrid,
    required this.playableIsValid,
    required this.solutionGrid,
    required this.solutionIsValid,
    required this.difficultyLevel,
    required this.difficultyCoefficient,
    required this.emptyCells,
    required this.cached,
    required this.hintsCoordinates,
  });

  factory SudokuGame.empty() {
    return SudokuGame(
      playableGrid: List.generate(9, (_) => List.filled(9, 0)),
      playableIsValid: false,
      solutionGrid: List.generate(9, (_) => List.filled(9, 0)),
      solutionIsValid: false,
      difficultyLevel: 'unknown',
      difficultyCoefficient: 0.0,
      emptyCells: 81,
      cached: false,
      hintsCoordinates: List.empty(),
    );
  }

  factory SudokuGame.fromJson(Map<String, dynamic> data) {
    final json = data['data'] as Map<String, dynamic>;
    if (json.isEmpty) return SudokuGame.empty();

    return SudokuGame(
      playableGrid: List<List<int>>.from(
        json['playable']['grid'].map((row) => List<int>.from(row)),
      ),
      playableIsValid: json['playable']['is_valid'],
      solutionGrid: List<List<int>>.from(
        json['solution']['grid'].map((row) => List<int>.from(row)),
      ),
      solutionIsValid: json['solution']['is_valid'],
      difficultyLevel: json['difficulty']['level'],
      difficultyCoefficient: json['difficulty']['coefficient'].toDouble(),
      emptyCells: json['metadata']['empty_cells'],
      cached: json['metadata']['cached'],
      hintsCoordinates: List<List<int>>.from(
        json['metadata']['hints_coordinates']?.map((c) => List<int>.from(c)) ??
            [],
      ),
    );
  }

  @override
  String toString() {
    return 'SudokuGame('
        'difficulty: $difficultyLevel, '
        'coefficient: $difficultyCoefficient, '
        'emptyCells: $emptyCells, '
        'cached: $cached, '
        ')';
  }
}
