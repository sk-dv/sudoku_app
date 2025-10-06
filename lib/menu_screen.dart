import 'package:flutter/material.dart';
import 'package:sudoku_app/screens/main_navigation_screen.dart';

/// MenuScreen ahora actúa como punto de entrada a MainNavigationScreen
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
