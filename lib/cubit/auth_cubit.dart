import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/services/auth_service.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
}

/// Estado inicial: comprobando si hay sesión guardada.
class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

/// Proceso de login en curso.
class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

/// Usuario autenticado con Google / Firebase.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  final User user;

  String get displayName => user.displayName ?? 'Jugador';
  String get email => user.email ?? '';
  String? get photoUrl => user.photoURL;

  @override
  List<Object?> get props => [user.uid];
}

/// Usuario jugando sin cuenta.
class AuthGuest extends AuthState {
  const AuthGuest();
  @override
  List<Object?> get props => [];
}

/// Error durante el proceso de auth.
class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authService) : super(const AuthInitial()) {
    _checkCurrentUser();
  }

  final AuthService _authService;

  /// Comprueba si ya había una sesión guardada de Firebase.
  void _checkCurrentUser() {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    }
    // Si no hay sesión → se queda en AuthInitial → muestra LoginScreen
  }

  /// Inicia sesión con Google.
  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user!;
      final token = await _authService.getIdToken();

      // Registrar en backend (fire-and-forget, no bloquea el login)
      if (token != null) {
        SudokuApiService.registerUser(
          idToken: token,
          displayName: user.displayName ?? 'Jugador',
          email: user.email ?? '',
        ).catchError((_) {
          // Silencioso: el usuario puede jugar aunque falle el registro
        });
      }

      emit(AuthAuthenticated(user: user));
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message: msg));
    }
  }

  /// Continuar sin cuenta.
  void continueAsGuest() {
    emit(const AuthGuest());
  }

  /// Cerrar sesión → vuelve a pantalla de login.
  Future<void> signOut() async {
    await _authService.signOut();
    emit(const AuthInitial());
  }

  /// Limpiar error y volver a inicial.
  void clearError() {
    emit(const AuthInitial());
  }

  /// Volver a la pantalla de login (desde guest o cualquier estado).
  void goToLogin() {
    emit(const AuthInitial());
  }
}
