import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'package:sudoku_app/services/auth_service.dart';
import '../models/sudoku_game.dart';

class SudokuApiService {
  static const String baseUrl =
      'https://sudoku-api-production-ff31.up.railway.app/api';

  /// Headers base, inyectando el Bearer token si hay sesión activa.
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.instance.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Registra al usuario en el backend tras el login con Google.
  /// Crea el perfil en PostgreSQL si no existe (idempotente).
  static Future<void> registerUser({
    required String idToken,
    required String displayName,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: json.encode({
        'display_name': displayName,
        'email': email,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to register user: ${response.statusCode}');
    }
  }

  /// Genera un nuevo puzzle de Sudoku
  ///
  /// [difficulty]: Nivel de dificultad (EASY, MEDIUM, HARD, EXPERT, MASTER)
  static Future<SudokuGame> getGame({
    DifficultLevel difficulty = DifficultLevel.medium,
  }) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/game').replace(
        queryParameters: {'difficulty': difficulty.gameMap()},
      ),
      headers: headers,
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
  static Future<SudokuGame> getDailyGame({String difficulty = 'MEDIUM', String? date}) async {
    final headers = await _authHeaders();
    final params = <String, String>{'difficulty': difficulty};
    if (date != null) params['date'] = date;
    final response = await http.get(
      Uri.parse('$baseUrl/daily').replace(queryParameters: params),
      headers: headers,
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

  /// Guarda el progreso de una partida en el backend (requiere sesión activa).
  static Future<void> saveProgress({
    required int puzzleId,
    required List<List<int>> currentState,
    required int timeElapsed,
    required int hintsUsed,
    required bool completed,
  }) async {
    final token = await AuthService.instance.getIdToken();
    if (token == null) return;

    await http.post(
      Uri.parse('$baseUrl/progress/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'puzzle_id': puzzleId,
        'current_state': currentState,
        'time_elapsed': timeElapsed,
        'hints_used': hintsUsed,
        'completed': completed,
      }),
    );
  }

  /// Obtiene las estadísticas del usuario autenticado.
  static Future<Map<String, dynamic>?> getUserStats() async {
    final token = await AuthService.instance.getIdToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data']['stats'] as Map<String, dynamic>?;
    }
    return null;
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
