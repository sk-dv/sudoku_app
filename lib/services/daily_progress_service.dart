import 'package:hive_flutter/hive_flutter.dart';

class DailyProgressService {
  static const String _boxName = 'daily_progress';

  static Future<void> initialize() async {
    await Hive.openBox<bool>(_boxName);
  }

  static String _key(String difficulty) {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_$difficulty';
  }

  static Future<void> saveCompleted(String difficulty) async {
    final box = Hive.box<bool>(_boxName);
    await box.put(_key(difficulty), true);
  }

  static bool isCompleted(String difficulty) {
    final box = Hive.box<bool>(_boxName);
    return box.get(_key(difficulty)) ?? false;
  }
}
