import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

class PixelatedStarsBackground extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const PixelatedStarsBackground({
    required this.primaryColor,
    required this.secondaryColor,
    super.key,
  });

  @override
  State<PixelatedStarsBackground> createState() {
    return _PixelatedStarsBackgroundState();
  }
}

class _PixelatedStarsBackgroundState extends State<PixelatedStarsBackground>
    with TickerProviderStateMixin {
  late final AnimationController _starsController;
  late final List<Star> _stars;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _generateStars();
  }

  void _generateStars() {
    _stars = List.generate(50, (index) {
      return Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 1,
        brightness: _random.nextDouble(),
        twinkleSpeed: _random.nextDouble() * 2 + 0.5,
      );
    });
  }

  @override
  void dispose() {
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_starsController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.primaryColor,
                widget.secondaryColor,
                widget.secondaryColor.withValues(alpha: 0.8),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
            selector: (state) => state.style,
            builder: (context, style) {
              return Stack(
                children: [
                  if (style.mode.isDark)
                    CustomPaint(
                      painter: StarsPainter(_stars, _starsController.value),
                      size: Size.infinite,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class Star {
  double x;
  double y;
  double size;
  double brightness;
  double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  const StarsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final paint = Paint()
        ..color = Colors.white.withValues(
          alpha: star.brightness *
              (0.3 + 0.7 * sin(animationValue * star.twinkleSpeed * 2 * pi)),
        );

      // Create pixelated star effect
      final rect = Rect.fromCenter(
        center: Offset(size.width * star.x, size.height * star.y),
        width: star.size,
        height: star.size,
      );

      canvas.drawRect(rect, paint);

      // Add cross pattern for larger stars
      if (star.size > 2) {
        final crossPaint = Paint()
          ..color = Colors.white.withValues(alpha: paint.color.a * 0.6);

        // Horizontal line
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(size.width * star.x, size.height * star.y),
            width: star.size + 2,
            height: 1,
          ),
          crossPaint,
        );

        // Vertical line
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(size.width * star.x, size.height * star.y),
            width: 1,
            height: star.size + 2,
          ),
          crossPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
