import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/token_type.dart';

enum GameStep {
  stop,
  play;

  GameStep get toggle {
    return this == GameStep.stop ? GameStep.play : GameStep.stop;
  }

  IconData get icon {
    return this == GameStep.stop ? Icons.play_arrow : Icons.pause;
  }
}

class SudokuGameState {
  final GameStep step;
  final TokenType type;

  const SudokuGameState({required this.step, required this.type});

  factory SudokuGameState.empty() {
    return const SudokuGameState(step: GameStep.play, type: TokenType.number);
  }

  SudokuGameState copy({GameStep? step, TokenType? type}) {
    return SudokuGameState(
      step: step ?? this.step,
      type: type ?? this.type,
    );
  }
}

class SudokuGameCubit extends Cubit<SudokuGameState> {
  SudokuGameCubit() : super(SudokuGameState.empty());

  void toggleGame() {
    emit(state.copy(step: state.step.toggle));
  }

  void changeSymbol(TokenType type) {
    emit(state.copy(type: type));
  }
}
