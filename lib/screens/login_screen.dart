import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/cubit/auth_cubit.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/theme/app_theme.dart';
import 'package:sudoku_app/widgets/floating_card.dart';
import 'package:sudoku_app/widgets/pixelated_background.dart';
import 'package:sudoku_app/widgets/shadow_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFFF5E5B),
            ),
          );
          context.read<AuthCubit>().clearError();
        }
      },
      child: BlocBuilder<SudokuGameCubit, SudokuGameState>(
        builder: (context, gameState) {
          final style = gameState.style;
          final isDark = style.mode.isDark;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                PixelatedBackground(
                  primaryColor:
                      isDark ? AppColors.loginDarkTop : AppColors.loginLightTop,
                  secondaryColor: isDark
                      ? AppColors.loginDarkBottom
                      : AppColors.loginLightBottom,
                  stop: false,
                  child: const SizedBox.expand(),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      // ── Toggle dark/light ─────────────────────────────────
                      Positioned(
                        top: 8,
                        right: 16,
                        child: _ThemeToggleButton(isDark: isDark),
                      ),
                      // ── Contenido principal ───────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 3),
                          _PixelLogo(isDark: isDark),
                          const Spacer(flex: 4),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: _AuthButtons(style: style),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Logo ─────────────────────────────────────────────────────────────────────

class _PixelLogo extends StatelessWidget {
  const _PixelLogo({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? const Color(0xFFFFFBF0) : const Color(0xFF1A1A2E);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'SUDOKU',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'BrickSans',
            fontSize: 56,
            color: titleColor,
            letterSpacing: 4,
            shadows: [Shadow(color: shadowColor, offset: const Offset(4, 4))],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '8 B I T',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'BrickSans',
            fontSize: 24,
            color: AppColors.accent,
            letterSpacing: 10,
            shadows: [Shadow(color: shadowColor, offset: const Offset(3, 3))],
          ),
        ),
      ],
    );
  }
}

// ─── Toggle dark / light ──────────────────────────────────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark
        ? const Color(0xFFFFFBF0).withValues(alpha: 0.7)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () => context.read<SudokuGameCubit>().changeMode(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 20,
          color: iconColor,
        ),
      ),
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
        return Column(
          children: [
            _SocialButton(
              label: 'INICIAR SESIÓN',
              isLoading: isLoading,
              onPressed: () {
                final authCubit = context.read<AuthCubit>();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => BlocProvider.value(
                    value: authCubit,
                    child: _AuthModalSheet(style: style),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _GuestButton(style: style, isLoading: isLoading),
          ],
        );
      },
    );
  }
}

// ─── Modal de opciones de auth ────────────────────────────────────────────────

class _AuthModalSheet extends StatelessWidget {
  const _AuthModalSheet({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    final showApple = defaultTargetPlatform != TargetPlatform.android;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthError) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: FloatingCard(
          elevation: 8,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'INICIAR SESIÓN',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _ModalButton(
                    label: 'CONTINUAR CON GOOGLE',
                    filled: true,
                    isLoading: isLoading,
                    onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                  ),
                  if (showApple) ...[
                    const SizedBox(height: 12),
                    _ModalButton(
                      label: 'CONTINUAR CON APPLE',
                      filled: false,
                      isLoading: isLoading,
                      onPressed: () => context.read<AuthCubit>().signInWithApple(),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModalButton extends StatelessWidget {
  const _ModalButton({
    required this.label,
    required this.filled,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = filled
        ? (isLoading ? cs.primary.withValues(alpha: 0.5) : cs.primary)
        : Colors.transparent;
    final fgColor = filled ? cs.onPrimary : cs.onSurface;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: filled ? null : Border.all(color: cs.onSurface, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading && filled
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: fgColor,
                        letterSpacing: 1.5,
                      ),
                ),
        ),
      ),
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
    final cs = Theme.of(context).colorScheme;
    final btnBg = isLoading ? cs.primary.withValues(alpha: 0.15) : cs.primary;
    final btnFg = cs.onPrimary;

    return ShadowButton(
      containerSize: const (340, 56),
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shadowOffset: const Offset(4, 4),
      radius: 14,
      restSpace: 5,
      pressedSpace: 2,
      onPressed: isLoading ? () {} : onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: btnBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: btnFg),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: btnFg,
                        letterSpacing: 1.5,
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 0.8),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                Icon(Icons.person_outline_rounded, size: 36, color: cs.onSurface),
                const SizedBox(height: 12),
                Text(
                  'MODO SIN CUENTA',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu progreso se guardará únicamente en este dispositivo.\n\nSi lo desinstalás o cambiás de teléfono, se perderá.',
                  style: tt.bodySmall?.copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'ENTENDIDO, CONTINUAR',
                      textAlign: TextAlign.center,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onPrimary,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
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
                      border: Border.all(color: cs.onSurface, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'VOLVER',
                      textAlign: TextAlign.center,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurface,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
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
