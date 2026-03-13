import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/cubit/auth_cubit.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
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
              content: Text(state.message),
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
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _PixelLogo(style: style),
                        const SizedBox(height: 16),
                        _PixelSubtitle(style: style),
                        const SizedBox(height: 64),
                        _GoogleSignInButton(style: style),
                        const SizedBox(height: 20),
                        _GuestButton(style: style),
                        const SizedBox(height: 48),
                        _FooterText(style: style),
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
            fontSize: 52,
            color: const Color(0xFFFFFBF0),
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
        ),
        Text(
          '8BIT',
          style: TextStyle(
            fontFamily: 'Overbit Shadow',
            fontSize: 36,
            color: const Color(0xFFFFC759),
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PixelSubtitle extends StatelessWidget {
  const _PixelSubtitle({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return const Text(
      '▸ ▸ ▸  ¡PRESS START!  ◂ ◂ ◂',
      style: TextStyle(
        fontFamily: 'Brick Sans',
        fontSize: 13,
        color: Color(0xFFFFFBF0),
        letterSpacing: 1,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return ShadowButton(
          containerSize: const (320, 64),
          shadowColor: Colors.black.withValues(alpha: 0.5),
          shadowOffset: const Offset(0, 0),
          radius: 8,
          restSpace: 6,
          pressedSpace: 2,
          onPressed: isLoading
              ? () {}
              : () => context.read<AuthCubit>().signInWithGoogle(),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF2D2D2D),
                width: 2,
              ),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF2D2D2D),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Jugar con Google',
                          style: TextStyle(
                            fontFamily: 'Brick Sans',
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () => context.read<AuthCubit>().continueAsGuest(),
          child: Container(
            width: 320,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFFFFBF0).withValues(alpha: 0.6),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Continuar sin cuenta',
                style: TextStyle(
                  fontFamily: 'Brick Sans',
                  fontSize: 14,
                  color: Color(0xFFFFFBF0),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FooterText extends StatelessWidget {
  const _FooterText({required this.style});
  final dynamic style;

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Sin cuenta, el progreso se guarda\nsolo en este dispositivo',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Brick Sans',
        fontSize: 11,
        color: Color(0xFFFFFBF0),
        height: 1.5,
      ),
    );
  }
}
