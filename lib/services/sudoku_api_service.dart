import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/sudoku_game.dart';

class SudokuApiService {
  static const String baseUrl =
      'https://sudoku-api-production-ff31.up.railway.app/api';

  /// Genera un nuevo puzzle de Sudoku
  ///
  /// [iterations]: Número de iteraciones (10-200, default: 70)
  /// [difficulty]: Nivel de dificultad (EASY, MEDIUM, HARD, EXPERT, MASTER)
  Future<SudokuGame> getGame({
    int iterations = 70,
    String difficulty = 'MEDIUM',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/game').replace(
        queryParameters: {
          'iterations': iterations.toString(),
          'difficulty': difficulty,
        },
      ),
    );

    if (response.statusCode == 200) {
      return SudokuGame.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load game: ${response.statusCode}');
    }
  }

  /// Obtiene el puzzle del día según dificultad
  ///
  /// [difficulty]: Nivel de dificultad (EASY, MEDIUM, HARD, EXPERT, MASTER)
  Future<SudokuGame> getDailyGame({String difficulty = 'MEDIUM'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/daily')
          .replace(queryParameters: {'difficulty': difficulty}),
    );

    if (response.statusCode == 200) {
      return SudokuGame.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load daily game: ${response.statusCode}');
    }
  }

  /// Resuelve un tablero de Sudoku parcialmente completado
  ///
  /// [grid]: Tablero de 9x9 con números del 1-9 (0 para celdas vacías)
  Future<Map<String, dynamic>> solveBoard(List<List<int>> grid) async {
    final response = await http.post(
      Uri.parse('$baseUrl/solve'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'grid': grid}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to solve board: ${response.statusCode}');
    }
  }

  /// Valida un tablero de Sudoku
  ///
  /// [grid]: Tablero de 9x9 con números del 1-9 (0 para celdas vacías)
  Future<Map<String, dynamic>> validateBoard(List<List<int>> grid) async {
    final response = await http.post(
      Uri.parse('$baseUrl/validate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'grid': grid}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to validate board: ${response.statusCode}');
    }
  }

  /// Obtiene estadísticas de puzzles disponibles
  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse('$baseUrl/stats'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  /// Health check endpoint
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
