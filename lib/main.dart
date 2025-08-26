import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:sudoku_app/data/service_locator.dart';
import 'package:sudoku_app/sudoku_game_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(Builder(builder: (context) {
    setupStyle(context);
    return const SudokuGameScreen();
  }));
}
