import 'dart:async';
import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/sudoku.dart';
import 'data/game_step.dart';
import 'data/token_type.dart';

class SudokuGameState extends Equatable {
  final GameStep step;
  final TokenType type;
  final SudokuStyle style;
  final GameScreen screen;
  final int elapsedSeconds;

  const SudokuGameState({
    required this.step,
    required this.type,
    required this.style,
    required this.screen,
    this.elapsedSeconds = 0,
  });

  factory SudokuGameState.empty() {
    return SudokuGameState(
      step: GameStep.play,
      type: TokenType.number,
      style: SudokuLightStyle(),
      screen: GameScreen.menu,
    );
  }

  SudokuGameState copy({GameStep? step, TokenType? type, SudokuStyle? style, GameScreen? screen, int? elapsedSeconds}) {
    return SudokuGameState(
      step: step ?? this.step,
      type: type ?? this.type,
      style: style ?? this.style,
      screen: screen ?? this.screen,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object> get props => [step, type, style, screen, elapsedSeconds];
}

class SudokuGameCubit extends Cubit<SudokuGameState> {
  Timer? _timer;

  SudokuGameCubit() : super(SudokuGameState.empty());

  void setupStyle(BuildContext context) {
    emit(state.copy(
      style: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? SudokuDarkStyle()
          : SudokuLightStyle(),
    ));
  }

  void toggleGame() {
    if (state.step == GameStep.play) {
      // Pausar el temporizador
      _timer?.cancel();
    } else {
      // Reanudar el temporizador
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

  void play() {
    emit(state.copy(screen: GameScreen.game, elapsedSeconds: 0, step: GameStep.play));
    _startTimer();
  }

  void back() {
    _timer?.cancel();
    emit(state.copy(screen: GameScreen.menu, elapsedSeconds: 0));
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
