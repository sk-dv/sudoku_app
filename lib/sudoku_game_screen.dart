import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/service_locator.dart';
import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/keyboard_mode.dart';
import 'package:sudoku_app/widgets/pixeled_background.dart';
import 'package:sudoku_app/widgets/shadow_icon.dart';
import 'package:sudoku_app/widgets/sudoku_board.dart';
import 'package:sudoku_app/widgets/token_selector.dart';

class SudokuGameScreen extends StatelessWidget {
  const SudokuGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SudokuGameCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<SudokuGameCubit, SudokuGameState>(
          listenWhen: (previous, current) => previous.step != current.step,
          listener: (context, state) {
            if (state.step == GameStep.stop) {
              showModalBottomSheet(
                context: context,
                builder: (context) => const TokenSelector(),
              ).whenComplete(context.read<SudokuGameCubit>().toggleGame);
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: locator<SudokuStyle>().topBackground,
                leadingWidth: MediaQuery.of(context).size.width * 0.15,
                leading: Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: ShadowIcon(
                    icon: state.step.icon,
                    onPressed: context.read<SudokuGameCubit>().toggleGame,
                  ),
                ),
                actions: [
                  ShadowIcon(
                    icon: locator<SudokuStyle>().themeIcon,
                    onPressed: () {},
                  )
                ],
              ),
              body: PixeledBackground(
                stop: state.step == GameStep.stop,
                primaryColor: locator<SudokuStyle>().topBackground,
                secondaryColor: locator<SudokuStyle>().bottomBackground,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SudokuBoard(),
                        const SizedBox(height: 20),
                        ImageKeyboard(type: state.type),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
