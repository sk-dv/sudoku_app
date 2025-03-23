import 'package:flutter/material.dart';
import 'package:sudoku_app/sudoku_game_screen.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheSudoku',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6952DC),
        scaffoldBackgroundColor: const Color(0xFF121829),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6952DC),
          secondary: Color(0xFF4361EE),
          background: Color(0xFF121829),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Poppins',
      ),
      home: const SudokuGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
