import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sudoku_app/sudoku_game.dart';
import 'package:sudoku_app/sudoku_game_screen.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SudokuApp());
}

class SudokuRepository {
  const SudokuRepository();

  static Future<SudokuGame> game(int iterations) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${const String.fromEnvironment('SUDOKU_API_URL')}/api/game?iterations=$iterations',
        ),
        headers: {
          'accept': 'application/json',
          'port': const String.fromEnvironment('PORT'),
        },
      );

      if (response.statusCode != 200) return SudokuGame.empty();
      return SudokuGame.fromJson(jsonDecode(response.body)['data']);
    } catch (e) {
      return SudokuGame.empty();
    }
  }
}

class SudokuThemeSystem extends StatelessWidget {
  const SudokuThemeSystem({
    required this.builder,
    required this.darkMode,
    super.key,
  });

  final Widget Function(BuildContext context, bool isDarkMode) builder;
  final bool? darkMode;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      darkMode ?? MediaQuery.of(context).platformBrightness == Brightness.dark,
    );
  }
}

class SudokuApp extends StatefulWidget {
  const SudokuApp({Key? key}) : super(key: key);

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  bool? _darkMode;

  @override
  Widget build(BuildContext context) {
    return SudokuThemeSystem(
      darkMode: _darkMode,
      builder: (context, isDarkMode) {
        return MaterialApp(
          theme: isDarkMode ? _darkTheme : _claudeTheme,
          home: FutureBuilder<SudokuGame>(
              future: SudokuRepository.game(50),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return SudokuGameScreen(
                  game: snapshot.data ?? SudokuGame.empty(),
                  isDarkMode: isDarkMode,
                  toggleTheme: () {
                    setState(() {
                      _darkMode = !(_darkMode ?? isDarkMode);
                    });
                  },
                );
              }),
          debugShowCheckedModeBanner: false,
        );
      },
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
