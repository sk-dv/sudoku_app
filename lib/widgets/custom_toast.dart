import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

void showCustomToast(BuildContext context, String message, {IconData? icon}) {
  final overlayEntry = OverlayEntry(
    builder: (_) => _CustomToast(message: message, icon: icon),
  );

  Overlay.of(context).insert(overlayEntry);
  Future.delayed(const Duration(seconds: 2), overlayEntry.remove);
}

class _CustomToast extends StatefulWidget {
  final String message;
  final IconData? icon;

  const _CustomToast({required this.message, this.icon});

  @override
  State<_CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<_CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: kToolbarHeight + 8,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: BlocBuilder<SudokuGameCubit, SudokuGameState>(
            builder: (context, state) {
              final style = state.style;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: style.selectedCell,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: style.background,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(0, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 22,
                        color: style.background,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      widget.message,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: style.background,
                          fontFamily: 'Brick Sans',
                          letterSpacing: 1.5,
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
