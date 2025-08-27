import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/context_utils.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/text_shadow_button.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: context.height * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocSelector<SudokuGameCubit, SudokuGameState, Color>(
              selector: (state) => state.style.selectedCell,
              builder: (context, color) {
                return Text(
                  'SUDOKU',
                  style: TextStyle(
                    fontSize: 52,
                    color: color,
                    fontFamily: 'Brick Sans',
                    letterSpacing: 7,
                  ),
                );
              },
            ),
            const TextShadowButton(text: 'JUGAR')
          ],
        ),
      ),
    );
  }
}
