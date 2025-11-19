import 'package:hive_flutter/hive_flutter.dart';
import 'package:sudoku_app/models/game_progress.dart';

class GameSaveService {
  static const String _boxName = 'game_saves';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_boxName);
  }

  static Future<void> saveGame(GameProgress progress) async {
    final box = Hive.box<Map>(_boxName);
    await box.put(progress.id, progress.toMap());
  }

  static GameProgress? loadGame(String gameId) {
    final box = Hive.box<Map>(_boxName);
    final data = box.get(gameId);
    if (data == null) return null;
    return GameProgress.fromMap(Map<String, dynamic>.from(data));
  }

  static Future<bool> hasSavedGame() async {
    final box = Hive.box<Map>(_boxName);
    return box.isNotEmpty;
  }

  static GameProgress? getLatestSavedGame() {
    final box = Hive.box<Map>(_boxName);
    if (box.isEmpty) return null;
    final lastData = box.values.last;
    return GameProgress.fromMap(Map<String, dynamic>.from(lastData));
  }

  static Future<void> deleteSavedGame(String gameId) async {
    final box = Hive.box<Map>(_boxName);
    await box.delete(gameId);
  }

  static Future<void> deleteAllSavedGames() async {
    final box = Hive.box<Map>(_boxName);
    await box.clear();
  }
}
