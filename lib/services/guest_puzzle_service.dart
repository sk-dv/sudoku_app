import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sudoku_app/models/sudoku_game.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';

class GuestPuzzleService {
  static const _boxName = 'guest_puzzles';
  static const _metaKey = '_metadata';
  static const _msPerDay = 86400000;

  static Future<void> initialize() async {
    await Hive.openBox<Map>(_boxName);
  }

  /// Fetches puzzles on first launch, or when all are completed + 24h have passed.
  static Future<void> refreshIfEligible() async {
    final box = Hive.box<Map>(_boxName);

    if (box.isEmpty) {
      await _fetch(box);
      return;
    }

    if (!_allCompleted(box)) return;

    final meta = Map<String, dynamic>.from(box.get(_metaKey) ?? {});
    final lastFetch = meta['last_fetch'] as int? ?? 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastFetch;
    if (elapsed < _msPerDay) return;

    await _fetch(box);
  }

  static Future<void> _fetch(Box<Map> box) async {
    try {
      final response = await http.get(
        Uri.parse('${SudokuApiService.baseUrl}/guest/puzzles'),
      );
      if (response.statusCode != 200) return;

      await box.clear();

      final data = json.decode(response.body)['data'] as Map<String, dynamic>;
      for (final entry in data.entries) {
        final puzzle = Map<String, dynamic>.from(entry.value as Map);
        puzzle['completed'] = false;
        await box.put(entry.key, puzzle);
      }

      await box.put(_metaKey, {
        'last_fetch': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {
      // Silent fail — cached puzzles (if any) remain usable
    }
  }

  /// Call when a guest completes a puzzle for a given difficulty.
  static Future<void> markCompleted(DifficultLevel difficulty) async {
    final box = Hive.box<Map>(_boxName);
    final key = difficulty.gameMap();
    final raw = box.get(key);
    if (raw == null) return;

    final puzzle = Map<String, dynamic>.from(raw);
    puzzle['completed'] = true;
    await box.put(key, puzzle);
  }

  static bool _allCompleted(Box<Map> box) {
    final puzzleKeys = box.keys.where((k) => k != _metaKey);
    if (puzzleKeys.isEmpty) return false;
    return puzzleKeys.every((k) {
      final raw = box.get(k);
      if (raw == null) return false;
      return Map<String, dynamic>.from(raw)['completed'] == true;
    });
  }

  static Future<SudokuGame> getGame(DifficultLevel difficulty) async {
    final box = Hive.box<Map>(_boxName);
    final key = difficulty.gameMap();
    final fallback = DifficultLevel.easy.gameMap();

    final raw = box.get(key) ?? box.get(fallback);
    if (raw == null) throw Exception('No guest puzzle available for $key');

    final puzzle = Map<String, dynamic>.from(raw);

    final playable = List<List<int>>.from(
      (puzzle['playable_grid'] as List).map((row) => List<int>.from(row as List)),
    );
    final solution = List<List<int>>.from(
      (puzzle['solution_grid'] as List).map((row) => List<int>.from(row as List)),
    );
    final hints = List<List<int>>.from(
      (puzzle['hints_coordinates'] as List).map((c) => List<int>.from(c as List)),
    );

    return SudokuGame(
      playableGrid: playable,
      solutionGrid: solution,
      difficultyLevel: key,
      hintsCoordinates: hints,
      puzzleId: puzzle['puzzle_id'] as int?,
    );
  }
}
