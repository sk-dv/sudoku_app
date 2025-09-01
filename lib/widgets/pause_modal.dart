import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/data/context_utils.dart';

import 'package:sudoku_app/data/token_type.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/text_shadow_button.dart';

class TokenSelector extends StatelessWidget {
  const TokenSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: state.style.background,
            borderRadius: BorderRadius.circular(12),
          ),
          width: context.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'PAUSA',
                    style: TextStyle(
                      fontFamily: 'Brick Sans',
                      fontSize: 40,
                      color: state.style.flatColor,
                      letterSpacing: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  height: 1,
                  color: state.style.flatColor,
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(left: 35),
                  child: Text(
                    'SIMBOLO_\n${state.type.name}',
                    style: TextStyle(
                      fontFamily: 'Brick Sans',
                      fontSize: 20,
                      color: state.style.flatColor,
                      letterSpacing: 5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                      children: TokenType.values.map(
                    (type) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<SudokuGameCubit>().changeSymbol(type);
                          },
                          child: Container(
                            height: 80,
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: context.select<SudokuGameCubit, Color>(
                                (cubit) => cubit.state.type == type
                                    ? state.style.selectedCell
                                    : state.style.topBackground,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: state.style.flatColor,
                              ),
                            ),
                            child: type.token.isEmpty
                                ? Center(
                                    child: Text(
                                      '1',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: state.style.flatColor,
                                        fontFamily: 'Brick Sans',
                                      ),
                                    ),
                                  )
                                : Image.asset(type.token,
                                    width: 40, height: 40),
                          ),
                        ),
                      );
                    },
                  ).toList()),
                ),
                const SizedBox(height: 40),
                Center(
                  child: TextShadowButton(
                    text: 'salir',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Future.delayed(
                        const Duration(milliseconds: 500),
                        context.read<SudokuGameCubit>().back,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }
}
