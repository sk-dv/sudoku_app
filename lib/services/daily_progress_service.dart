import 'package:hive_flutter/hive_flutter.dart';

class DailyProgressService {
  static const String _boxName = 'daily_progress';

  static Future<void> initialize() async {
    await Hive.openBox<bool>(_boxName);
  }

  static String _key(String difficulty, [DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}_$difficulty';
  }

  static Future<void> saveCompleted(String difficulty, [DateTime? date]) async {
    final box = Hive.box<bool>(_boxName);
    await box.put(_key(difficulty, date), true);
  }

  static bool isCompleted(String difficulty, [DateTime? date]) {
    final box = Hive.box<bool>(_boxName);
    return box.get(_key(difficulty, date)) ?? false;
  }
}
