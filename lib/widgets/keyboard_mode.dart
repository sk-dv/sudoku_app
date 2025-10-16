import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/data/context_utils.dart';
import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/data/token_type.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'shadow_button.dart';

class KeyboardMode extends StatelessWidget {
  final int idx;
  final TokenType type;
  final bool showClearButton;

  const KeyboardMode({
    super.key,
    required this.idx,
    required this.type,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = context.width * 0.85;
    final height = context.height * 0.075;

    return SizedBox(
      width: width,
      height: height,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 0.5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          final buttonIndex = idx + index;

          // Si es el último slot de la segunda fila y showClearButton es true
          if (showClearButton && buttonIndex == 10) {
            return _ClearButtonCompact();
          }

          if (buttonIndex > 9) return const SizedBox.shrink();

          return ShadowButton(
            onPressed: () {
              context.read<SudokuBoardCubit>().enterNumber(buttonIndex);
            },
            containerSize: ((width / 5), height),
            shadowSize: ((width / 5), height),
            shadowColor: const Color(0xFF880E4F),
            radius: 12,
            shadowOffset: const Offset(2.5, 2.5),
            pressedSpace: 0,
            restSpace: 2,
            child: BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
              selector: (state) => state.style,
              builder: (context, style) {
                return Container(
                  decoration: BoxDecoration(
                    color: style.background,
                    border: Border.all(color: style.borderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: type.isImage ? 10 : 16,
                            fontWeight: FontWeight.w900,
                            color: style.flatColor,
                            fontFamily: 'Brick Sans',
                          ),
                          child:
                              Text('$buttonIndex', textAlign: TextAlign.center),
                        ),
                        if (type.isImage)
                          Expanded(
                            child: Padding(
                              padding: type == TokenType.halloween || type == TokenType.cats
                                  ? const EdgeInsets.all(6.0)
                                  : EdgeInsets.zero,
                              child: Image.asset('${type.path}0$buttonIndex.png'),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ImageKeyboard extends StatelessWidget {
  const ImageKeyboard({super.key, required this.type});

  final TokenType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KeyboardMode(idx: 1, type: type),
        KeyboardMode(idx: 6, type: type, showClearButton: true),
      ],
    );
  }
}

class _ClearButtonCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = context.width * 0.85;
    final height = context.height * 0.075;

    return ShadowButton(
      onPressed: () {
        context.read<SudokuBoardCubit>().clearCell();
      },
      containerSize: ((width / 5), height),
      shadowSize: ((width / 5), height),
      shadowColor: const Color(0xFF880E4F),
      radius: 12,
      shadowOffset: const Offset(2.5, 2.5),
      pressedSpace: 0,
      restSpace: 2,
      child: BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
        selector: (state) => state.style,
        builder: (context, style) {
          return Container(
            decoration: BoxDecoration(
              color: style.background,
              border: Border.all(color: style.borderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                color: style.flatColor,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
