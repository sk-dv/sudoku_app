import 'dart:math';

import 'package:flutter/material.dart';

class PixeledClouds extends StatefulWidget {
  final List<String>? cloudAssets;
  final Color primaryColor;
  final Color secondaryColor;
  final bool stop;

  const PixeledClouds({
    super.key,
    this.cloudAssets,
    required this.primaryColor,
    required this.secondaryColor,
    required this.stop,
  });

  @override
  State<PixeledClouds> createState() => _PixeledCloudsState();
}

class _PixeledCloudsState extends State<PixeledClouds>
    with TickerProviderStateMixin {
  late AnimationController _cloudsController;
  late List<CloudSprite> _clouds;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _cloudsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _generateClouds();
  }

  @override
  void didUpdateWidget(covariant PixeledClouds oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.stop != widget.stop) {
      if (widget.stop) {
        _cloudsController.stop();
      } else {
        _cloudsController.repeat();
      }
    }
  }

  void _generateClouds() {
    _clouds = List.generate(8, (index) {
      return CloudSprite(
        x: _random.nextDouble() * 1.5 - 0.25, 
        y: _random.nextDouble() * 0.6 + 0.1,
        speed: _random.nextDouble() * 0.0375 + 0.0125,
        scale: _random.nextDouble() * 0.5 + 0.5,
        opacity: _random.nextDouble() * 0.4 + 0.3,
        assetIndex: widget.cloudAssets != null
            ? _random.nextInt(widget.cloudAssets!.length)
            : 0,
      );
    });
  }

  @override
  void dispose() {
    _cloudsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_cloudsController]),
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
          child: Stack(
            children: widget.cloudAssets != null
                ? _buildCloudSprites()
                : _buildPixelatedClouds(),
          ),
        );
      },
    );
  }

  List<Widget> _buildCloudSprites() {
    return _clouds.map((cloud) {
      // Update cloud position
      cloud.x += cloud.speed * 0.01;
      if (cloud.x > 1.2) {
        cloud.x = -0.2;
        cloud.y = _random.nextDouble() * 0.6 + 0.1;
      }

      return Positioned(
        left: MediaQuery.of(context).size.width * cloud.x,
        top: MediaQuery.of(context).size.height * cloud.y,
        child: Opacity(
          opacity: cloud.opacity,
          child: Transform.scale(
            scale: cloud.scale,
            child: Image.asset(
              widget.cloudAssets![cloud.assetIndex],
              width: 160,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildPixelatedClouds() {
    return _clouds.map((cloud) {
      cloud.x += cloud.speed * 0.05;
      if (cloud.x > 1.2) {
        cloud.x = -0.2;
        cloud.y = _random.nextDouble() * 0.6 + 0.1;
      }

      return Positioned(
        left: MediaQuery.of(context).size.width * cloud.x,
        top: MediaQuery.of(context).size.height * cloud.y,
        child: Opacity(
          opacity: cloud.opacity,
          child: Transform.scale(
            scale: cloud.scale,
            child: CustomPaint(
              painter: PixelatedCloudPainter(),
              size: const Size(60, 40),
            ),
          ),
        ),
      );
    }).toList();
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

class CloudSprite {
  double x;
  double y;
  double speed;
  double scale;
  double opacity;
  int assetIndex;

  CloudSprite({
    required this.x,
    required this.y,
    required this.speed,
    required this.scale,
    required this.opacity,
    required this.assetIndex,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarsPainter(this.stars, this.animationValue);

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

class PixelatedCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    final cloudPixels = [
      [0, 0, 1, 1, 1, 0, 0],
      [0, 1, 1, 1, 1, 1, 0],
      [1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 0],
    ];

    final pixelSize = size.width / 7;

    for (int row = 0; row < cloudPixels.length; row++) {
      for (int col = 0; col < cloudPixels[row].length; col++) {
        if (cloudPixels[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * pixelSize,
              row * pixelSize,
              pixelSize,
              pixelSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
