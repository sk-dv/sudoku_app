import 'dart:async';
import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/models/style.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'models/game_progress.dart';
import 'models/game_step.dart';
import 'models/token_type.dart';
import 'services/game_save_service.dart';

class SudokuGameState extends Equatable {
  final GameStep step;
  final TokenType type;
  final SudokuStyle style;
  final int elapsedSeconds;
  final DifficultLevel difficulty;
  final SudokuGameModel? game;

  const SudokuGameState({
    required this.step,
    required this.type,
    required this.style,
    this.elapsedSeconds = 0,
    required this.difficulty,
    this.game,
  });

  String get timer {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final secs = elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  factory SudokuGameState.empty() {
    return SudokuGameState(
      step: GameStep.play,
      type: TokenType.number,
      style: SudokuLightStyle(),
      difficulty: DifficultLevel.medium,
      game: null,
    );
  }

  SudokuGameState copy({
    GameStep? step,
    TokenType? type,
    SudokuStyle? style,
    int? elapsedSeconds,
    DifficultLevel? difficulty,
    SudokuGameModel? game,
    bool? clearGame,
  }) {
    return SudokuGameState(
      step: step ?? this.step,
      type: type ?? this.type,
      style: style ?? this.style,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      difficulty: difficulty ?? this.difficulty,
      game: clearGame == true ? null : (game ?? this.game),
    );
  }

  @override
  List<Object> get props {
    return [step, type, style, elapsedSeconds, difficulty];
  }
}

class SudokuGameCubit extends Cubit<SudokuGameState> {
  Timer? _timer;

  SudokuGameCubit() : super(SudokuGameState.empty());

  Future<void> saveGameProgress(SavedGame game) async {
    final progress = GameProgress.fromGameModel(game);
    await GameSaveService.saveGame(progress);
  }

  Future<void> loadSavedGame(String gameId) async {
    final progress = GameSaveService.loadGame(gameId);
    if (progress == null) return;

    await GameSaveService.deleteSavedGame(gameId);

    emit(state.copy(
      step: GameStep.play,
      difficulty: progress.difficulty,
      game: progress.toSudokuGameModel(),
      elapsedSeconds: progress.timeElapsed,
    ));

    _startTimer();
  }

  void setupStyle(BuildContext context) {
    emit(state.copy(
      style: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? SudokuDarkStyle()
          : SudokuLightStyle(),
    ));
  }

  void toggleGame() {
    if (state.step == GameStep.play) {
      _timer?.cancel();
    } else {
      _startTimer();
    }

    emit(state.copy(step: state.step.toggle));
  }

  void changeSymbol(TokenType type) {
    emit(state.copy(type: type));
  }

  void cycleSymbol() {
    final currentIndex = TokenType.values.indexOf(state.type);
    final nextIndex = (currentIndex + 1) % TokenType.values.length;
    emit(state.copy(type: TokenType.values[nextIndex]));
  }

  void changeMode() {
    emit(state.copy(
      style: state.style is SudokuLightStyle
          ? SudokuDarkStyle()
          : SudokuLightStyle(),
    ));
  }

  void play(DifficultLevel difficulty, [SudokuGameModel? game]) {
    emit(state.copy(
      elapsedSeconds: 0,
      step: GameStep.play,
      difficulty: difficulty,
      game: game,
      clearGame: game == null,
    ));

    _startTimer();
  }

  void back() {
    _timer?.cancel();
    emit(state.copy(elapsedSeconds: 0, game: null));
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copy(elapsedSeconds: state.elapsedSeconds + 1));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
