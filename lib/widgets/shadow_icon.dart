import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'shadow_button.dart';

class ShadowIcon extends StatelessWidget {
  const ShadowIcon({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
      selector: (state) => state.style,
      builder: (context, style) {
        return ShadowButton(
          radius: 40,
          containerSize: const (60, 60),
          shadowSize: const (50, 50),
          restSpace: 8,
          pressedSpace: 7.5,
          shadowOffset: const Offset(-6, 3),
          shadowColor: style.cellColor.withValues(alpha: 0.5),
          onPressed: onPressed,
          child: Container(
            margin: const EdgeInsets.only(right: 10, top: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: style.themeColor,
            ),
            child: Center(
              child: Icon(icon, size: 22, color: const Color(0xFFFFFBF0)),
            ),
          ),
        );
      },
    );
  }
}
