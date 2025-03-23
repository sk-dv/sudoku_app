import 'package:flutter/material.dart';
import 'package:sudoku_app/sudoku_game_screen.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatefulWidget {
  const SudokuApp({Key? key}) : super(key: key);

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  bool _isDarkMode = true;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheSudoku',
      theme: _isDarkMode ? _darkTheme : _claudeTheme,
      home: SudokuGameScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
      debugShowCheckedModeBanner: false,
    );
  }

  // Tema oscuro original
  final ThemeData _darkTheme = ThemeData(
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
  );

  // Tema claro inspirado en Claude
  final ThemeData _claudeTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF5346A5),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF5346A5),
      secondary: Color(0xFF3B5BD9),
      background: Color(0xFFF5F7FA),
      surface: Color(0xFFE9EDF5),
    ),
    fontFamily: 'Poppins',
  );
}
