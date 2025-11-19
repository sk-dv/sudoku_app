class SudokuGame {
  final List<List<int>> playableGrid;
  final List<List<int>> solutionGrid;
  final String difficultyLevel;
  final List<List<int>> hintsCoordinates;

  SudokuGame({
    required this.playableGrid,
    required this.solutionGrid,
    required this.difficultyLevel,
    required this.hintsCoordinates,
  });

  factory SudokuGame.empty() {
    return SudokuGame(
      playableGrid: List.generate(9, (_) => List.filled(9, 0)),
      solutionGrid: List.generate(9, (_) => List.filled(9, 0)),
      difficultyLevel: 'unknown',
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
      solutionGrid: List<List<int>>.from(
        json['solution']['grid'].map((row) => List<int>.from(row)),
      ),
      difficultyLevel: json['difficulty']['level'],
      hintsCoordinates: List<List<int>>.from(
        json['metadata']['hints_coordinates']?.map((c) => List<int>.from(c)) ??
            [],
      ),
    );
  }
}
