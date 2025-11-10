import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/cubit/sudoku_board_cubit.dart';
import 'package:sudoku_app/models/context_utils.dart';
import 'package:sudoku_app/models/style.dart';
import 'package:sudoku_app/models/token_type.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'number_preview.dart';

class KeyboardMode extends StatelessWidget {
  final int idx;
  final TokenType type;
  final bool showClearButton;

  const KeyboardMode({
    super.key,
    required this.idx,
    required this.type,
    this.showClearButton = false,
  });

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

          // Si es el último slot de la segunda fila y showClearButton es true
          if (showClearButton && buttonIndex == 10) {
            return _ClearButtonCompact();
          }

          if (buttonIndex > 9) return const SizedBox.shrink();

          return _NumberButton(
            number: buttonIndex,
            width: width,
            height: height,
            type: type,
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
      children: [
        KeyboardMode(idx: 1, type: type),
        KeyboardMode(idx: 6, type: type, showClearButton: true),
      ],
    );
  }
}

/// Widget individual de botón numérico con efecto flotante
class _NumberButton extends StatefulWidget {
  final int number;
  final double width;
  final double height;
  final TokenType type;

  const _NumberButton({
    required this.number,
    required this.width,
    required this.height,
    required this.type,
  });

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton> {
  final GlobalKey _buttonKey = GlobalKey();

  void _showPreview(BuildContext context, SudokuStyle style) {
    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // Calcular posición centrada arriba del botón
      final previewPosition = Offset(
        position.dx + size.width / 2 - 27.5, // Centrar (55px de ancho / 2)
        position.dy - 60,
      );

      NumberPreviewOverlay.show(
        context,
        number: widget.number,
        position: previewPosition,
        backgroundColor: style.flatColor,
        textColor: style.background,
      );
    }
  }

  void _hidePreview() {
    NumberPreviewOverlay.hide();
  }

  void _handleTap(BuildContext context) {
    context.read<SudokuBoardCubit>().enterNumber(widget.number);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
      selector: (state) => state.style,
      builder: (context, style) {
        return _ButtonWithPreview(
          buttonKey: _buttonKey,
          onTapDown: () => _showPreview(context, style),
          onTapUp: () {
            _hidePreview();
            _handleTap(context);
          },
          onTapCancel: _hidePreview,
          width: widget.width,
          height: widget.height,
          number: widget.number,
          type: widget.type,
          style: style,
        );
      },
    );
  }
}

/// Widget que combina el botón con animación de sombra y el preview
class _ButtonWithPreview extends StatefulWidget {
  final GlobalKey buttonKey;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final double width;
  final double height;
  final int number;
  final TokenType type;
  final SudokuStyle style;

  const _ButtonWithPreview({
    required this.buttonKey,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.width,
    required this.height,
    required this.number,
    required this.type,
    required this.style,
  });

  @override
  State<_ButtonWithPreview> createState() => _ButtonWithPreviewState();
}

class _ButtonWithPreviewState extends State<_ButtonWithPreview> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    const restSpace = 2.0;
    const pressedSpace = 0.0;
    final space = isPressed ? pressedSpace : restSpace;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
        widget.onTapDown();
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTapUp();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
        widget.onTapCancel();
      },
      child: AnimatedContainer(
        key: widget.buttonKey,
        duration: const Duration(milliseconds: 200),
        width: widget.width / 5,
        height: widget.height,
        child: Stack(
          children: [
            // Sombra
            Positioned(
              left: 2.5 + space,
              top: 2.5 + space,
              child: Container(
                width: (widget.width / 5) - space,
                height: widget.height - space,
                decoration: BoxDecoration(
                  color: const Color(0xFF880E4F),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Contenido del botón
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (widget.width / 5) - space,
                height: widget.height - space,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.style.background,
                    border: Border.all(color: widget.style.borderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: widget.type.isImage ? 10 : 16,
                            fontWeight: FontWeight.w900,
                            color: widget.style.flatColor,
                            fontFamily: 'Brick Sans',
                          ),
                          child: Text(
                            '${widget.number}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.type.isImage)
                          Expanded(
                            child: Padding(
                              padding: widget.type == TokenType.halloween ||
                                      widget.type == TokenType.cats
                                  ? const EdgeInsets.all(6.0)
                                  : EdgeInsets.zero,
                              child: Image.asset(
                                '${widget.type.path}0${widget.number}.png',
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearButtonCompact extends StatefulWidget {
  @override
  State<_ClearButtonCompact> createState() => _ClearButtonCompactState();
}

class _ClearButtonCompactState extends State<_ClearButtonCompact> {
  final GlobalKey _buttonKey = GlobalKey();

  void _showPreview(BuildContext context, SudokuStyle style) {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // Calcular posición centrada arriba del botón
      final previewPosition = Offset(
        position.dx + size.width / 2 - 27.5, // Centrar (55px de ancho / 2)
        position.dy - 60,
      );

      // Mostrar preview con ícono de borrar
      NumberPreviewOverlay.show(
        context,
        number: 0, // No se usa cuando hay ícono
        position: previewPosition,
        backgroundColor: style.flatColor,
        textColor: style.background,
        icon: Icons.backspace_outlined,
      );
    }
  }

  void _hidePreview() {
    NumberPreviewOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    final width = context.width * 0.85;
    final height = context.height * 0.075;

    return BlocSelector<SudokuGameCubit, SudokuGameState, SudokuStyle>(
      selector: (state) => state.style,
      builder: (context, style) {
        return _ClearButtonWithPreview(
          buttonKey: _buttonKey,
          onTapDown: () => _showPreview(context, style),
          onTapUp: () {
            _hidePreview();
            context.read<SudokuBoardCubit>().clearCell();
          },
          onTapCancel: _hidePreview,
          width: width,
          height: height,
          style: style,
        );
      },
    );
  }
}

/// Botón de borrar con preview
class _ClearButtonWithPreview extends StatefulWidget {
  final GlobalKey buttonKey;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final double width;
  final double height;
  final SudokuStyle style;

  const _ClearButtonWithPreview({
    required this.buttonKey,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.width,
    required this.height,
    required this.style,
  });

  @override
  State<_ClearButtonWithPreview> createState() =>
      _ClearButtonWithPreviewState();
}

class _ClearButtonWithPreviewState extends State<_ClearButtonWithPreview> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    const restSpace = 2.0;
    const pressedSpace = 0.0;
    final space = isPressed ? pressedSpace : restSpace;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
        widget.onTapDown();
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTapUp();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
        widget.onTapCancel();
      },
      child: AnimatedContainer(
        key: widget.buttonKey,
        duration: const Duration(milliseconds: 200),
        width: widget.width / 5,
        height: widget.height,
        child: Stack(
          children: [
            // Sombra
            Positioned(
              left: 2.5 + space,
              top: 2.5 + space,
              child: Container(
                width: (widget.width / 5) - space,
                height: widget.height - space,
                decoration: BoxDecoration(
                  color: const Color(0xFF880E4F),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Contenido del botón
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (widget.width / 5) - space,
                height: widget.height - space,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.style.background,
                    border: Border.all(color: widget.style.borderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.backspace_outlined,
                      color: widget.style.flatColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
