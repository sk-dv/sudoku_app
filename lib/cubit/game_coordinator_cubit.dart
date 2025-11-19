import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/game_progress.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'package:sudoku_app/services/game_save_service.dart';
import 'package:sudoku_app/services/timer_service.dart';

class GameCoordinatorState extends Equatable {
  final int elapsedSeconds;
  final int hintIndex;
  final DifficultLevel? difficulty;
  final bool isPlaying;

  const GameCoordinatorState({
    this.elapsedSeconds = 0,
    this.hintIndex = 0,
    this.difficulty,
    this.isPlaying = false,
  });

  GameCoordinatorState copyWith({
    int? elapsedSeconds,
    int? hintIndex,
    DifficultLevel? difficulty,
    bool? isPlaying,
  }) {
    return GameCoordinatorState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hintIndex: hintIndex ?? this.hintIndex,
      difficulty: difficulty ?? this.difficulty,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  String get formattedTime {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final secs = elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [elapsedSeconds, hintIndex, difficulty, isPlaying];
}

class GameCoordinatorCubit extends Cubit<GameCoordinatorState> {
  final TimerService _timerService = TimerService();
  StreamSubscription<int>? _timerSubscription;

  GameCoordinatorCubit() : super(const GameCoordinatorState()) {
    _timerSubscription = _timerService.timeStream.listen((seconds) {
      emit(state.copyWith(elapsedSeconds: seconds));
    });
  }

  void startGame(DifficultLevel difficulty) {
    _timerService.stop();
    emit(state.copyWith(
      difficulty: difficulty,
      hintIndex: 0,
      elapsedSeconds: 0,
      isPlaying: true,
    ));
    _timerService.start();
  }

  void resumeGame(int elapsedSeconds, DifficultLevel difficulty, int hintIndex) {
    _timerService.setTime(elapsedSeconds);
    emit(state.copyWith(
      difficulty: difficulty,
      hintIndex: hintIndex,
      elapsedSeconds: elapsedSeconds,
      isPlaying: true,
    ));
    _timerService.start();
  }

  void pauseGame() {
    _timerService.pause();
    emit(state.copyWith(isPlaying: false));
  }

  void resumeTimer() {
    _timerService.resume();
    emit(state.copyWith(isPlaying: true));
  }

  void stopGame() {
    _timerService.stop();
    emit(const GameCoordinatorState());
  }

  void incrementHintIndex() {
    emit(state.copyWith(hintIndex: state.hintIndex + 1));
  }

  Future<void> saveGame(SudokuGameModel model, GameSource source) async {
    // Delete previous save to ensure only one exists
    await GameSaveService.deleteAllSavedGames();

    final progress = GameProgress.fromGameModel(SavedGame(
      model: model,
      idx: state.hintIndex,
      source: source,
      elapsedSeconds: state.elapsedSeconds,
    ));
    await GameSaveService.saveGame(progress);
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    _timerService.dispose();
    return super.close();
  }
}
