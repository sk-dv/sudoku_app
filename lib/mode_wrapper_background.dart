import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/context_utils.dart';
import 'package:sudoku_app/data/game_step.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

import 'sudoku.dart';
import 'widgets/pixelated_background.dart';
import 'widgets/shadow_icon.dart';

class ModeWrapperBackground extends StatelessWidget {
  const ModeWrapperBackground({
    super.key,
    required this.params,
  });

  final WrapperParams params;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SudokuGameCubit, SudokuGameState>(
      listenWhen: params.listenWhen,
      listener: params.listener?.call ?? (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: state.style.topBackground,
            leadingWidth: context.width * 0.15,
            leading: Container(
              margin: const EdgeInsets.only(left: 15),
              child: params.leading?.call(context, state),
            ),
            actions: [
              ShadowIcon(
                icon: state.style.themeIcon,
                onPressed: context.read<SudokuGameCubit>().changeMode,
              )
            ],
          ),
          body: PixelatedBackground(
            stop: state.step == GameStep.stop,
            primaryColor: state.style.topBackground,
            secondaryColor: state.style.bottomBackground,
            child: params.builder(context, state),
          ),
        );
      },
    );
  }
}
