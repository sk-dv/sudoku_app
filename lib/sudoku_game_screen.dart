import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/cubit/game_coordinator_cubit.dart';
import 'package:sudoku_app/models/game_progress.dart';
import 'package:sudoku_app/models/sudoku_object.dart';
import 'package:sudoku_app/models/style.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/keyboard_mode.dart';
import 'package:sudoku_app/widgets/sudoku_board.dart';
import 'package:sudoku_app/widgets/custom_toast.dart';
import 'package:sudoku_app/widgets/shadow_button.dart';
import 'package:sudoku_app/widgets/sudoku_minimap.dart';

import 'models/token_type.dart';

class SudokuGameScreen extends StatefulWidget {
  const SudokuGameScreen({super.key, required this.type});
  final TokenType type;

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late final AnimationController _animController;
  Animation<Matrix4>? _zoomAnimation;
  final GlobalKey _boardKey = GlobalKey();
  int _focusedQuadrant = -1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if (scale < 1.5 && _focusedQuadrant != -1) {
      setState(() => _focusedQuadrant = -1);
    }
  }

  void _zoomToQuadrant(int qi) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final s = box.size.shortestSide;
    final qRow = qi ~/ 3;
    final qCol = qi % 3;
    final cx = (qCol + 0.5) * s / 3;
    final cy = (qRow + 0.5) * s / 3;
    const scale = 2.8;
    final target = Matrix4.identity()
      ..translate(-cx * (scale - 1), -cy * (scale - 1))
      ..scale(scale);
    setState(() => _focusedQuadrant = qi);
    _animateToMatrix(target);
  }

  void _resetZoom() {
    setState(() => _focusedQuadrant = -1);
    _animateToMatrix(Matrix4.identity());
  }

  void _animateToMatrix(Matrix4 target) {
    _zoomAnimation?.removeListener(_applyAnimation);
    _zoomAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _zoomAnimation!.addListener(_applyAnimation);
    _animController.forward(from: 0);
  }

  void _applyAnimation() {
    if (_zoomAnimation != null) {
      _transformController.value = _zoomAnimation!.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final coordinator = context.read<GameCoordinatorCubit>();
        final boardCubit = context.read<SudokuBoardCubit>();

        Future<void> onSave() async {
          await coordinator.saveGame(state.gameModel, GameSource.level);
          if (context.mounted) {
            showCustomToast(context, 'GUARDADO', icon: Icons.check_circle_rounded);
          }
        };

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              // ── Barra superior: minimapa | spacer | controles ────────
              BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
                builder: (context, boardState) {
                  return BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
                    selector: (s) => s.style,
                    builder: (context, style) {
                      final board = List.generate(
                        9,
                        (i) => List.generate(
                          9,
                          (j) => SudokuObject(
                            value: boardState.gameModel.board[i][j],
                            isOriginal: boardState.gameModel.isOriginal[i][j],
                            isSelected: boardState.gameModel.isSelected[i][j],
                            isHighlighted: boardState.gameModel.isHighlighted[i][j],
                            isError: boardState.gameModel.isErrorCell[i][j],
                          ),
                        ),
                      );

                      const double btnSize = 50;
                      const double gap = 8;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Minimapa (solo hace zoom-in)
                          SudokuMinimap(
                            board: board,
                            focusedQuadrant: _focusedQuadrant,
                            onQuadrantActivated: _zoomToQuadrant,
                            style: style,
                          ),
                          // Spacer entre minimapa y controles
                          const Spacer(),
                          // Grid 2×2 de controles
                          SizedBox(
                            width: btnSize * 2 + gap,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    _ControlBtn(icon: Icons.save_rounded, style: style, onPressed: onSave),
                                    const SizedBox(width: gap),
                                    BlocBuilder<SudokuBoardCubit, SudokuBoardState>(
                                      builder: (context, s) => _ControlBtn(
                                        icon: Icons.undo_rounded,
                                        style: style,
                                        onPressed: boardCubit.undoLastMove,
                                        isEnabled: boardCubit.canUndo,
                                        badge: boardCubit.canUndo ? boardCubit.undoMovements : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: gap),
                                Row(
                                  children: [
                                    _ControlBtn(
                                      icon: Icons.lightbulb_rounded,
                                      style: style,
                                      onPressed: boardCubit.useHint,
                                      badge: boardState.gameModel.hintsRemaining,
                                    ),
                                    const SizedBox(width: gap),
                                    SizedBox(width: btnSize, height: btnSize),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),

              // ── Tablero: toma todo el espacio restante ────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth;
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          minScale: 1.0,
                          maxScale: 4.0,
                          onInteractionEnd: (_) {
                            if (_transformController.value.getMaxScaleOnAxis() < 1.5 &&
                                _focusedQuadrant != -1) {
                              setState(() => _focusedQuadrant = -1);
                            }
                          },
                          child: KeyedSubtree(
                            key: _boardKey,
                            child: GestureDetector(
                              onDoubleTap: () {
                                if (_focusedQuadrant != -1) _resetZoom();
                              },
                              child: const SudokuBoard(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // ── Teclado ───────────────────────────────────────────
              ImageKeyboard(type: widget.type),
            ],
          ),
        );
      },
    );
  }
}

// ── Botón de control inline ────────────────────────────────────────────────────

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.icon,
    required this.style,
    required this.onPressed,
    this.badge,
    this.isEnabled = true,
  });

  final IconData icon;
  final SudokuStyle style;
  final VoidCallback onPressed;
  final int? badge;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final btn = Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: ShadowButton(
        containerSize: const (50, 50),
        shadowSize: const (45, 45),
        restSpace: 4,
        pressedSpace: 2,
        radius: 8,
        shadowOffset: const Offset(0, 3),
        shadowColor: style.flatColor.withValues(alpha: 0.3),
        onPressed: isEnabled ? onPressed : () {},
        child: Container(
          decoration: BoxDecoration(
            color: style.background,
            border: Border.all(color: style.borderColor, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              Center(child: Icon(icon, color: style.flatColor, size: 24)),
              if (badge != null)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: style.flatColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$badge',
                        style: TextStyle(
                          color: style.background,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return btn;
  }
}
