import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:sudoku_app/sudoku.dart';

import 'services/game_save_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await GameSaveService.initialize();
  runApp(const Sudoku());
}
