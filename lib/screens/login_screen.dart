import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/cubit/auth_cubit.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/widgets/pixelated_background.dart';
import 'package:sudoku_app/widgets/shadow_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.read<SudokuGameCubit>().state.style;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Brick Sans')),
              backgroundColor: const Color(0xFFFF5E5B),
            ),
          );
          context.read<AuthCubit>().clearError();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            PixelatedBackground(
              primaryColor: style.topBackground,
              secondaryColor: style.bottomBackground,
              stop: false,
              child: const SizedBox.expand(),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    _PixelLogo(style: style),
                    const Spacer(flex: 4),
                    _AuthButtons(style: style),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logo ─────────────────────────────────────────────────────────────────────

class _PixelLogo extends StatelessWidget {
  const _PixelLogo({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'SUDOKU',
          style: TextStyle(
            fontFamily: 'Overbit Shadow',
            fontSize: 64,
            color: const Color(0xFFFFFBF0),
            letterSpacing: 6,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(5, 5))],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '8 B I T',
          style: TextStyle(
            fontFamily: 'Overbit Shadow',
            fontSize: 28,
            color: const Color(0xFFFFC759),
            letterSpacing: 12,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), offset: const Offset(3, 3))],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'El sudoku de siempre, con otro sabor.',
          style: TextStyle(
            fontFamily: 'Brick Sans',
            fontSize: 12,
            color: const Color(0xFFFFFBF0).withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Botones de autenticación ─────────────────────────────────────────────────

class _AuthButtons extends StatelessWidget {
  const _AuthButtons({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final showApple = defaultTargetPlatform != TargetPlatform.android;

        return Column(
          children: [
            _SocialButton(
              label: 'CONTINUAR CON GOOGLE',
              isLoading: isLoading,
              onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
            ),
            if (showApple) ...[
              const SizedBox(height: 14),
              _SocialButton(
                label: 'CONTINUAR CON APPLE',
                isLoading: isLoading,
                onPressed: () => context.read<AuthCubit>().signInWithApple(),
              ),
            ],
            const SizedBox(height: 20),
            _GuestButton(style: style, isLoading: isLoading),
          ],
        );
      },
    );
  }
}

// ─── Botón social (Google / Apple) ───────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.isLoading, required this.onPressed});

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ShadowButton(
      containerSize: const (340, 56),
      shadowColor: Colors.black.withValues(alpha: 0.6),
      shadowOffset: const Offset(4, 4),
      radius: 12,
      restSpace: 5,
      pressedSpace: 2,
      onPressed: isLoading ? () {} : onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isLoading
              ? const Color(0xFFFFFBF0).withValues(alpha: 0.15)
              : const Color(0xFFFFFBF0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2D2D2D)),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Brick Sans',
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Botón sin cuenta ─────────────────────────────────────────────────────────

class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.style, required this.isLoading});
  final dynamic style;
  final bool isLoading;

  Future<void> _showWarning(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _GuestWarningDialog(style: style),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().continueAsGuest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => _showWarning(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          'Continuar sin cuenta →',
          style: TextStyle(
            fontFamily: 'Brick Sans',
            fontSize: 12,
            color: const Color(0xFFFFFBF0).withValues(alpha: 0.55),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Modal aviso modo sin cuenta ──────────────────────────────────────────────

class _GuestWarningDialog extends StatelessWidget {
  const _GuestWarningDialog({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: FloatingCard(
          elevation: 6,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline_rounded, size: 36, color: Color(0xFF2D2D2D)),
                const SizedBox(height: 12),
                const Text(
                  'MODO SIN CUENTA',
                  style: TextStyle(
                    fontFamily: 'Brick Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tu progreso se guardará únicamente en este dispositivo.\n\nSi lo desinstalás o cambiás de teléfono, se perderá.',
                  style: TextStyle(
                    fontFamily: 'Brick Sans',
                    fontSize: 12,
                    color: Color(0xFF555555),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'ENTENDIDO, CONTINUAR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Brick Sans',
                        fontSize: 13,
                        color: Color(0xFFFFFBF0),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2D2D2D), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'VOLVER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Brick Sans',
                        fontSize: 13,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
