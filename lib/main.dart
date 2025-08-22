import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sudoku_app/sudoku_game.dart';
import 'package:sudoku_app/sudoku_game_screen.dart';
import 'package:sudoku_app/iteration_selector_screen.dart';
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
          'https://sudoku-api-production-ff31.up.railway.app/api/game?iterations=$iterations',
        ),
        headers: {
          'accept': 'application/json',
          'port': '8080',
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
  int? _selectedIterations;

  @override
  Widget build(BuildContext context) {
    return SudokuThemeSystem(
      darkMode: _darkMode,
      builder: (context, isDarkMode) {
        return MaterialApp(
          theme: isDarkMode ? _darkTheme : _claudeTheme,
          home: _selectedIterations == null
              ? IterationSelectorScreen(
                  isDarkMode: isDarkMode,
                  toggleTheme: () {
                    setState(() {
                      _darkMode = !(_darkMode ?? isDarkMode);
                    });
                  },
                  onIterationsSelected: (iterations) {
                    setState(() {
                      _selectedIterations = iterations;
                    });
                  },
                )
              : FutureBuilder<SudokuGame>(
                  future: SudokuRepository.game(_selectedIterations!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingScreen(isDarkMode);
                    }

                    if (snapshot.hasError) {
                      return _buildErrorScreen(
                          snapshot.error.toString(), isDarkMode);
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
                  },
                ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildLoadingScreen(bool isDarkMode) {
    final colorScheme =
        isDarkMode ? _darkTheme.colorScheme : _claudeTheme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDarkMode)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Generando Sudoku...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Iteraciones: $_selectedIterations',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIterations = null;
                });
              },
              child: Text(
                'Cambiar iteraciones',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error, bool isDarkMode) {
    final colorScheme =
        isDarkMode ? _darkTheme.colorScheme : _claudeTheme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el juego',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIterations = null;
                      });
                    },
                    child: Text(
                      'Cambiar iteraciones',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Forzar recarga
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      surface: Color(0xFFE9EDF5),
    ),
    fontFamily: 'Poppins',
  );
}
