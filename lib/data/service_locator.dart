import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:sudoku_app/data/style.dart';

final locator = GetIt.instance;

void setupStyle(BuildContext context) {
  locator.allowReassignment = true;
  final mode = MediaQuery.of(context).platformBrightness;
  locator.registerLazySingleton<SudokuStyle>(() {
    return mode == Brightness.dark ? SudokuDarkStyle() : SudokuLightStyle();
  });
}
