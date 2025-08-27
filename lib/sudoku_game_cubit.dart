import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/style.dart';
import 'data/game_step.dart';
import 'data/token_type.dart';

class SudokuGameState extends Equatable {
  final GameStep step;
  final TokenType type;
  final SudokuStyle style;

  const SudokuGameState({
    required this.step,
    required this.type,
    required this.style,
  });

  factory SudokuGameState.empty() {
    return SudokuGameState(
      step: GameStep.play,
      type: TokenType.number,
      style: SudokuLightStyle(),
    );
  }

  SudokuGameState copy({GameStep? step, TokenType? type, SudokuStyle? style}) {
    return SudokuGameState(
      step: step ?? this.step,
      type: type ?? this.type,
      style: style ?? this.style,
    );
  }

  @override
  List<Object> get props => [step, type, style];
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

  void changeMode() {
    emit(state.copy(
      style: state.style is SudokuLightStyle
          ? SudokuDarkStyle()
          : SudokuLightStyle(),
    ));
  }
}
