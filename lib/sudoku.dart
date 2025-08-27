import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/context_utils.dart';
import 'package:sudoku_app/menu_screen.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/pixeled_background.dart';
import 'data/game_step.dart';
import 'widgets/shadow_icon.dart';

class Sudoku extends StatelessWidget {
  const Sudoku({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SudokuGameCubit()..setupStyle(context),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<SudokuGameCubit, SudokuGameState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: state.style.topBackground,
                leadingWidth: context.width * 0.15,
                leading: Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: ShadowIcon(
                    icon: state.step.icon,
                    onPressed: context.read<SudokuGameCubit>().toggleGame,
                  ),
                ),
                actions: [
                  ShadowIcon(
                    icon: state.style.themeIcon,
                    onPressed: context.read<SudokuGameCubit>().changeMode,
                  )
                ],
              ),
              body: PixeledBackground(
                stop: state.step == GameStep.stop,
                primaryColor: state.style.topBackground,
                secondaryColor: state.style.bottomBackground,
                child: const MenuScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
