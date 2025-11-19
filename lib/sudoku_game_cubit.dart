import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/models/style.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';
import 'models/game_step.dart';
import 'models/token_type.dart';

class SudokuGameState extends Equatable {
  final GameStep step;
  final TokenType type;
  final SudokuStyle style;
  final DifficultLevel difficulty;
  final SudokuGameModel? game;

  const SudokuGameState({
    required this.step,
    required this.type,
    required this.style,
    required this.difficulty,
    this.game,
  });

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
    DifficultLevel? difficulty,
    SudokuGameModel? game,
    bool? clearGame,
  }) {
    return SudokuGameState(
      step: step ?? this.step,
      type: type ?? this.type,
      style: style ?? this.style,
      difficulty: difficulty ?? this.difficulty,
      game: clearGame == true ? null : (game ?? this.game),
    );
  }

  @override
  List<Object> get props => [step, type, style, difficulty];
}

class SudokuGameCubit extends Cubit<SudokuGameState> {
  SudokuGameCubit() : super(SudokuGameState.empty());

  void setupStyle(BuildContext context) {
    emit(state.copy(
      style: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? SudokuDarkStyle()
          : SudokuLightStyle(),
    ));
  }

  void toggleGame() {
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
      step: GameStep.play,
      difficulty: difficulty,
      game: game,
      clearGame: game == null,
    ));
  }
}
