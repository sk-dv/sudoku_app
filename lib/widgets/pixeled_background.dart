import 'package:flutter/material.dart';

import 'package:sudoku_app/widgets/pixeled_clouds.dart';
import 'package:sudoku_app/widgets/pixeled_stars_background.dart';

class PixeledBackground extends StatelessWidget {
  final List<String>? cloudAssets;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget child;
  final bool stop;

  const PixeledBackground({
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
        PixeledClouds(
          stop: stop,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
        child,
      ],
    );
  }
}
