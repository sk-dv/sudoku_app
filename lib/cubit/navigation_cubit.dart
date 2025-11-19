import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/models/sudoku_game_model.dart';
import 'package:sudoku_app/screens/level_selection_screen.dart';

enum AppRoute {
  menu,
  game;

  bool get isMenu => this == AppRoute.menu;
  bool get isGame => this == AppRoute.game;
}

class NavigationState extends Equatable {
  final AppRoute route;
  final DifficultLevel? difficulty;
  final SudokuGameModel? gameModel;

  const NavigationState({
    required this.route,
    this.difficulty,
    this.gameModel,
  });

  factory NavigationState.initial() {
    return const NavigationState(route: AppRoute.menu);
  }

  NavigationState copyWith({
    AppRoute? route,
    DifficultLevel? difficulty,
    SudokuGameModel? gameModel,
    bool clearGame = false,
  }) {
    return NavigationState(
      route: route ?? this.route,
      difficulty: difficulty ?? this.difficulty,
      gameModel: clearGame ? null : (gameModel ?? this.gameModel),
    );
  }

  @override
  List<Object?> get props => [route, difficulty, gameModel];
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.initial());

  void goToGame(DifficultLevel difficulty, [SudokuGameModel? gameModel]) {
    emit(state.copyWith(
      route: AppRoute.game,
      difficulty: difficulty,
      gameModel: gameModel,
      clearGame: gameModel == null,
    ));
  }

  void goToMenu() {
    emit(state.copyWith(
      route: AppRoute.menu,
      clearGame: true,
    ));
  }
}
