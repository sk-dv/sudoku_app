import 'package:flutter/material.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'package:sudoku_app/screens/daily_puzzle_screen.dart';
import 'package:sudoku_app/screens/stats_screen.dart';
import 'package:sudoku_app/widgets/floating_bottom_navigation.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LevelSelectionScreen(),
    DailyPuzzleScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // Permite que el body se extienda bajo el bottom nav
      body: SafeArea(
        bottom: false, // No aplicar safe area al bottom para el nav flotante
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: FloatingBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
