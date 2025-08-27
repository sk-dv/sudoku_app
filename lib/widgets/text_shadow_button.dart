import 'package:flutter/material.dart';

import 'package:sudoku_app/widgets/shadow_button.dart';

class TextShadowButton extends StatelessWidget {
  const TextShadowButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShadowButton(
      radius: 12,
      restSpace: 8,
      pressedSpace: 0,
      shadowOffset: const Offset(0, 0),
      shadowColor: const Color(0xFF880E4F),
      onPressed: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63),
          borderRadius: BorderRadius.circular(12),
        ),
        child:  Center(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Brick Sans',
              letterSpacing: 5,
            ),
          ),
        ),
      ),
    );
  }
}
