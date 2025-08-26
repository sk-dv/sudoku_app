import 'package:flutter/material.dart';

import 'package:sudoku_app/data/context_utils.dart';
import 'package:sudoku_app/data/service_locator.dart';
import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/data/token_type.dart';
import 'shadow_button.dart';

class KeyboardMode extends StatelessWidget {
  final int idx;
  final TokenType type;

  const KeyboardMode({super.key, required this.idx, required this.type});

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
          if (buttonIndex > 9) return const SizedBox.shrink();

          return ShadowButton(
            onPressed: () {},
            containerSize: ((width / 5), height),
            shadowSize: ((width / 5), height),
            shadowColor: const Color(0xFF880E4F),
            radius: 12,
            shadowOffset: const Offset(2.5, 2.5),
            pressedSpace: 0,
            restSpace: 2,
            child: Container(
              decoration: BoxDecoration(
                color: locator<SudokuStyle>().background,
                border: Border.all(color: locator<SudokuStyle>().borderColor),
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
                        color: locator<SudokuStyle>().flatColor,
                        fontFamily: 'Overbit Regular',
                      ),
                      child: Text('$buttonIndex', textAlign: TextAlign.center),
                    ),
                    if (type.isImage)
                      Expanded(
                        child: Image.asset('${type.path}0$buttonIndex.png'),
                      )
                  ],
                ),
              ),
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
      children: [1, 6].map((i) => KeyboardMode(idx: i, type: type)).toList(),
    );
  }
}
