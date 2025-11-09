import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/sudoku_game_model.dart';
import '../services/sudoku_api_service.dart';

class SudokuBoardState extends Equatable {
  final SudokuGameModel? gameModel;
  final bool isLoading;
  final String? error;

  const SudokuBoardState({
    this.gameModel,
    this.isLoading = false,
    this.error,
  });

  SudokuBoardState copyWith({
    SudokuGameModel? gameModel,
    bool? isLoading,
    String? error,
  }) {
    return SudokuBoardState(
      gameModel: gameModel ?? this.gameModel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [gameModel, isLoading, error];
}

class SudokuBoardCubit extends Cubit<SudokuBoardState> {
  final SudokuApiService _apiService;

  SudokuBoardCubit(this._apiService) : super(const SudokuBoardState());

  void useHint() {
    if (state.gameModel != null) {
      emit(state.copyWith(gameModel: state.gameModel!.useHint()));
    }
  }

  void undoLastMove() {
    // Implementar si tienes historial
  }

  Future<void> loadNewGame({
    int iterations = 70,
    String difficulty = 'MEDIUM',
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final sudokuGame = await _apiService.getGame(
        iterations: iterations,
        difficulty: difficulty,
      );

      final gameModel = SudokuGameModel.fromSudokuGame(
        sudokuGame: sudokuGame,
        difficulty: _mapDifficulty(difficulty),
      );

      emit(state.copyWith(gameModel: gameModel, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar el juego: $e',
      ));
    }
  }

  Future<void> loadDailyGame({String difficulty = 'MEDIUM'}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final sudokuGame = await _apiService.getDailyGame(difficulty: difficulty);

      final gameModel = SudokuGameModel.fromSudokuGame(
        sudokuGame: sudokuGame,
        difficulty: _mapDifficulty(difficulty),
      );

      emit(state.copyWith(gameModel: gameModel, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar el juego diario: $e',
      ));
    }
  }

  void selectCell(int row, int col) {
    if (state.gameModel != null) {
      emit(state.copyWith(gameModel: state.gameModel!.selectCell(row, col)));
    }
  }

  void enterNumber(int number) {
    if (state.gameModel != null) {
      emit(state.copyWith(gameModel: state.gameModel!.enterNumber(number)));
    }
  }

  void clearCell() {
    if (state.gameModel != null) {
      emit(state.copyWith(gameModel: state.gameModel!.clearCell()));
    }
  }

  DifficultLevel _mapDifficulty(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return DifficultLevel.easy;
      case 'MEDIUM':
        return DifficultLevel.medium;
      case 'HARD':
        return DifficultLevel.hard;
      case 'EXPERT':
        return DifficultLevel.veryHard;
      case 'MASTER':
        return DifficultLevel.master;
      default:
        return DifficultLevel.medium;
    }
  }
}
