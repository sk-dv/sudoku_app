import 'package:flutter/material.dart';

class ShadowButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final (double, double) containerSize;
  final (double, double)? shadowSize;
  final Color shadowColor;
  final double restSpace;
  final double pressedSpace;
  final double radius;
  final Offset shadowOffset;

  const ShadowButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.containerSize = const (300, 80),
    this.shadowSize,
    required this.shadowColor,
    this.restSpace = 8,
    this.pressedSpace = 2,
    required this.radius,
    required this.shadowOffset,
  });

  @override
  State<ShadowButton> createState() => _ShadowButtonState();
}

class _ShadowButtonState extends State<ShadowButton> {
  bool isPressed = false;

  double get space {
    return isPressed ? widget.pressedSpace : widget.restSpace;
  }

  (double, double) get shadowSize {
    return widget.shadowSize ?? widget.containerSize;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.containerSize.$1,
        height: widget.containerSize.$2,
        child: Stack(
          children: [
            Positioned(
              left: widget.shadowOffset.dx + space,
              top: widget.shadowOffset.dy + space,
              child: Container(
                width: shadowSize.$1 - space,
                height: shadowSize.$2 - space,
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.containerSize.$1 - space,
                height: widget.containerSize.$2 - space,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
