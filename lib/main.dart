import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sudoku_app/firebase_options.dart';
import 'package:sudoku_app/sudoku.dart';
import 'services/daily_progress_service.dart';
import 'services/game_save_service.dart';
import 'services/guest_puzzle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GameSaveService.initialize();
  await DailyProgressService.initialize();
  await GuestPuzzleService.initialize();
  runApp(const Sudoku());
}
