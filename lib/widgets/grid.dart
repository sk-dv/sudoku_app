import 'package:flutter/material.dart';

import 'package:sudoku_app/widgets/cell.dart';

class Grid extends StatelessWidget {
  const Grid({required this.builder, super.key});

  final Cell Function(int, int) builder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          childAspectRatio: 1,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          return builder(index ~/ 9, index % 9);
        },
      ),
    );
  }
}
