import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';
import 'package:sudoku_app/services/game_command_manager.dart';

class SudokuBoardState extends Equatable {
  final SudokuGameModel gameModel;
  final bool isLoading;
  final String error;
  final int idx;

  const SudokuBoardState({
    required this.gameModel,
    this.isLoading = false,
    this.error = '',
    this.idx = 0,
  });

  SudokuBoardState copyWith({
    SudokuGameModel? gameModel,
    bool? isLoading,
    String? error,
    int? idx,
  }) {
    return SudokuBoardState(
      gameModel: gameModel ?? this.gameModel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      idx: idx ?? this.idx,
    );
  }

  @override
  List<Object?> get props => [gameModel, isLoading, error, idx];
}

class SudokuBoardCubit extends Cubit<SudokuBoardState> {
  final GameCommandManager _commandManager = GameCommandManager();

  SudokuBoardCubit(SudokuGameModel gameModel)
      : super(SudokuBoardState(gameModel: gameModel));

  void useHint() {
    final currentModel = state.gameModel;

    if (currentModel.hintsRemaining <= 0) {
      emit(state.copyWith(error: 'No hay pistas disponibles'));
      return;
    }

    final coord = currentModel.hintsCoordinates[state.idx];
    final revealedValue = currentModel.solutionGrid[coord.$1][coord.$2];
    final boardProgress = _commandManager.calculateBoardProgress(currentModel);
    final previousValue = currentModel.valueAt(coord);

    final hintCommand = _commandManager.createUseHintCommand(
      cell: coord,
      revealedValue: revealedValue,
      previousValue: previousValue == 0 ? null : previousValue,
      hintIndex:
          currentModel.hintsCoordinates.length - currentModel.hintsRemaining,
      boardProgressPercentage: boardProgress,
    );

    emit(state.copyWith(
      gameModel: _commandManager.executeCommand(hintCommand, currentModel),
      idx: state.idx + 1,
    ));
  }

  void undoLastMove() {
    if (!_commandManager.hasCommands) return;

    final restoredModel = _commandManager.undo(state.gameModel);

    if (restoredModel == null) return;
    emit(state.copyWith(gameModel: restoredModel));
  }

  bool get canUndo => _commandManager.hasCommands;

  int get undoMovements {
    return _commandManager.commandHistory.where((cmd) {
      return cmd.commandType != 'UseHint';
    }).length;
  }

  void selectCell((int, int) cell) {
    emit(state.copyWith(gameModel: state.gameModel.selectCell(cell)));
  }

  void enterNumber(int number) {
    final currentModel = state.gameModel;

    if (currentModel.originalAt(currentModel.selectedCell)) return;
    final previousValue = currentModel.valueAt(currentModel.selectedCell);
    final boardProgress = _commandManager.calculateBoardProgress(currentModel);

    final command = _commandManager.createPlaceNumberCommand(
      cell: currentModel.selectedCell,
      value: number,
      previousValue: previousValue == 0 ? null : previousValue,
      boardProgressPercentage: boardProgress,
    );

    final newModel = _commandManager.executeCommand(command, currentModel);
    emit(state.copyWith(gameModel: newModel));
  }

  void clearCell() {
    final currentModel = state.gameModel;

    if (currentModel.originalAt(currentModel.selectedCell)) return;

    final removedValue = currentModel.valueAt(currentModel.selectedCell);
    if (removedValue == 0) return;

    final command = _commandManager.createRemoveNumberCommand(
      cell: currentModel.selectedCell,
      removedValue: removedValue,
      boardProgressPercentage: _commandManager.calculateBoardProgress(
        currentModel,
      ),
    );

    final newModel = _commandManager.executeCommand(command, currentModel);
    emit(state.copyWith(gameModel: newModel));
  }
}
