class SudokuGame {
  final List<List<int>> playableGrid;
  final bool playableIsValid;
  final List<List<int>> solutionGrid;
  final bool solutionIsValid;
  final String difficultyLevel;
  final double difficultyCoefficient;
  final int iterationsUsed;
  final int emptyCells;
  final bool cached;

  SudokuGame({
    required this.playableGrid,
    required this.playableIsValid,
    required this.solutionGrid,
    required this.solutionIsValid,
    required this.difficultyLevel,
    required this.difficultyCoefficient,
    required this.iterationsUsed,
    required this.emptyCells,
    required this.cached,
  });

  factory SudokuGame.empty() {
    return SudokuGame(
      playableGrid: List.generate(9, (_) => List.filled(9, 0)),
      playableIsValid: false,
      solutionGrid: List.generate(9, (_) => List.filled(9, 0)),
      solutionIsValid: false,
      difficultyLevel: 'unknown',
      difficultyCoefficient: 0.0,
      iterationsUsed: 0,
      emptyCells: 81,
      cached: false,
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
      iterationsUsed: json['metadata']['iterations_used'],
      emptyCells: json['metadata']['empty_cells'],
      cached: json['metadata']['cached'],
    );
  }

  @override
  String toString() {
    return 'SudokuGame('
        'difficulty: $difficultyLevel, '
        'coefficient: $difficultyCoefficient, '
        'emptyCells: $emptyCells, '
        'cached: $cached, '
        'iterations: $iterationsUsed'
        ')';
  }
}
