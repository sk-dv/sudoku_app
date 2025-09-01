import 'package:flutter/material.dart';

import 'package:sudoku_app/widgets/pixelated_clouds.dart';
import 'package:sudoku_app/widgets/pixelated_stars_background.dart';

class PixelatedBackground extends StatelessWidget {
  final List<String>? cloudAssets;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget child;
  final bool stop;

  const PixelatedBackground({
    super.key,
    this.cloudAssets,
    required this.primaryColor,
    required this.secondaryColor,
    required this.child,
    required this.stop,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PixelatedStarsBackground(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
        PixelatedClouds(
          stop: stop,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
        child,
      ],
    );
  }
}
