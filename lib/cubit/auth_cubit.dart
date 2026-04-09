import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/services/auth_service.dart';
import 'package:sudoku_app/services/sudoku_api_service.dart';

String _friendlyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-disabled':
      return 'Esta cuenta ha sido deshabilitada.';
    case 'network-request-failed':
      return 'Sin conexión. Verifica tu internet e intenta de nuevo.';
    default:
      return e.message ?? 'Error de autenticación. Intenta de nuevo.';
  }
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  final User user;

  String get displayName => user.displayName ?? user.email ?? 'Jugador';
  String get email => user.email ?? '';
  String? get photoUrl => user.photoURL;

  @override
  List<Object?> get props => [user.uid];
}

class AuthGuest extends AuthState {
  const AuthGuest();
  @override
  List<Object?> get props => [];
}

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

  void _checkCurrentUser() {
    final user = _authService.currentUser;
    if (user != null) emit(AuthAuthenticated(user: user));
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final result = await _authService.signInWithGoogle();
      _registerAndEmit(result.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        emit(const AuthError(message: 'Ya tienes cuenta con Apple para ese email. Usa "Continuar con Apple" para entrar.'));
      } else {
        emit(AuthError(message: _friendlyAuthError(e)));
      }
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('canceled') || msg.contains('cancelled') || msg.contains('popup-closed')) {
        emit(const AuthInitial());
      } else {
        emit(const AuthError(message: 'Inicio cancelado o fallido. Intenta de nuevo.'));
      }
    }
  }

  Future<void> signInWithApple() async {
    emit(const AuthLoading());
    try {
      final result = await _authService.signInWithApple();
      _registerAndEmit(result.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        emit(const AuthError(message: 'Ya tienes cuenta con Google para ese email. Usa "Continuar con Google" para entrar.'));
      } else {
        emit(AuthError(message: _friendlyAuthError(e)));
      }
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('canceled') || msg.contains('cancelled') || msg.contains('AuthorizationErrorCode.canceled')) {
        emit(const AuthInitial());
      } else {
        emit(const AuthError(message: 'Inicio cancelado o fallido. Intenta de nuevo.'));
      }
    }
  }

  void _registerAndEmit(User user) {
    _authService.getIdToken().then((token) {
      if (token != null) {
        SudokuApiService.registerUser(
          idToken: token,
          displayName: user.displayName ?? 'Jugador',
          email: user.email ?? '',
        ).catchError((_) {});
      }
    });
    emit(AuthAuthenticated(user: user));
  }

  void continueAsGuest() => emit(const AuthGuest());

  Future<void> signOut() async {
    await _authService.signOut();
    emit(const AuthInitial());
  }

  void clearError() => emit(const AuthInitial());
  void goToLogin() => emit(const AuthInitial());
}
