# Sudoku 8bit — Flutter App

App móvil de Sudoku con estética 8-bit. Parte del monorepo `sudoku/`.

## Stack

| Capa | Tecnología |
|---|---|
| App | Flutter 3.29.3 (iOS / Android / macOS) |
| Auth | Firebase Auth — Google Sign-In + Sign in with Apple |
| Backend | Python/Flask en Railway (`sudoku-api/`) |
| Base de datos | PostgreSQL en Railway |
| Estado | BLoC (flutter_bloc) + Hive (local) |

## Estructura

```
lib/
├── main.dart                     # Inicializa Firebase + Hive + runApp
├── sudoku.dart                   # Root widget, BlocProviders, ShellNavigation, AppBar
├── firebase_options.dart         # NO incluido en git — generar con flutterfire configure
├── cubit/
│   ├── auth_cubit.dart           # AuthInitial|Loading|Authenticated|Guest|Error
│   ├── navigation_cubit.dart
│   ├── sudoku_board_cubit.dart
│   └── game_coordinator_cubit.dart
├── services/
│   ├── auth_service.dart         # Singleton: signInWithGoogle, signInWithApple, signOut
│   ├── sudoku_api_service.dart   # Inyecta Bearer token automáticamente
│   ├── game_save_service.dart    # Persistencia local con Hive
│   ├── game_command_manager.dart
│   └── timer_service.dart
├── screens/
│   ├── login_screen.dart
│   ├── level_selection_screen.dart
│   ├── daily_puzzle_screen.dart
│   ├── stats_screen.dart
│   └── main_navigation_screen.dart
├── models/
└── widgets/
    ├── floating_card.dart
    ├── floating_bottom_navigation.dart
    ├── shadow_button.dart
    └── shadow_icon.dart
```

## Setup inicial (una sola vez)

```bash
# 1. Instalar flutterfire CLI
dart pub global activate flutterfire_cli

# 2. Configurar Firebase (genera lib/firebase_options.dart)
flutterfire configure

# 3. Colocar archivos de credenciales (NO están en git):
#    ios/Runner/GoogleService-Info.plist
#    macos/Runner/GoogleService-Info.plist
#    android/app/google-services.json

# 4. Instalar dependencias
flutter pub get

# 5. iOS / macOS — instalar pods
cd ios && pod install && cd ..
cd macos && pod install && cd ..
```

## Flujo de Auth

1. App abre → `AuthCubit` verifica `FirebaseAuth.currentUser` (auto-login si hay sesión)
2. Sin sesión → `LoginScreen`
3. "Continuar con Google" → Google Sign-In → Firebase → `AuthAuthenticated`
4. "Continuar con Apple" → Sign in with Apple → Firebase → `AuthAuthenticated`
5. "Continuar sin cuenta" → `AuthGuest` (progreso solo en Hive local)
6. Firebase vincula automáticamente cuentas con el mismo email (configurado en Firebase Console)

## Niveles de dificultad

Sincronizados con el backend (`DifficultyLevel` en `sudoku-api/`):

| App | Backend | Color |
|---|---|---|
| PRINCIPIANTE | `BEGINNER` | Verde claro |
| FÁCIL | `EASY` | Verde |
| MEDIO | `MEDIUM` | Azul |
| DIFÍCIL | `HARD` | Amarillo |
| EXPERTO | `EXPERT` | Naranja |
| MAESTRO | `MASTER` | Rojo |
| GRAN MAESTRO | `GRANDMASTER` | Púrpura |

## API

Base URL: `https://sudoku-api-production-ff31.up.railway.app/api`

| Endpoint | Auth | Descripción |
|---|---|---|
| `GET /health` | No | Health check |
| `GET /game?difficulty=MEDIUM` | Bearer | Puzzle aleatorio |
| `GET /daily?difficulty=MEDIUM` | Bearer | Puzzle del día |
| `GET /stats` | No | Conteo de puzzles por nivel |
| `POST /validate` | No | Valida tablero |
| `POST /solve` | No | Resuelve tablero |
| `POST /auth/register` | Bearer | Registra/actualiza usuario (pendiente) |

El `SudokuApiService` inyecta `Authorization: Bearer <firebase_id_token>` automáticamente si hay sesión activa.

## Credenciales — qué NO está en git

```
lib/firebase_options.dart
ios/Runner/GoogleService-Info.plist
macos/Runner/GoogleService-Info.plist
android/app/google-services.json
*.env
```

## Correr la app

```bash
# iOS
flutter run -d ios

# macOS
flutter run -d macos

# Android
flutter run -d android
```

## Estado actual (Marzo 2026)

**Completado**
- Firebase Auth con Google Sign-In, Sign in with Apple y modo invitado
- Auto-login con sesión persistente
- Vinculación de cuentas por email (Firebase Console)
- 7 niveles sincronizados con backend
- Rediseno visual: cards limpias, tipografia bold, nav minimalista
- Progreso guardado localmente con Hive

**Pendiente**
- Modal de auth unificado (Google + Apple en bottom sheet)
- Backend: `POST /auth/register` con firebase-admin
- Tablas `users`, `game_progress`, `user_stats` en PostgreSQL
- Guardado de progreso en cloud
