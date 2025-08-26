import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_app/data/service_locator.dart';
import 'package:sudoku_app/data/style.dart';
import 'package:sudoku_app/data/token_type.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';
import 'package:sudoku_app/widgets/text_shadow_button.dart';

class TokenSelector extends StatelessWidget {
  const TokenSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: locator<SudokuStyle>().background,
        borderRadius: BorderRadius.circular(12),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'PAUSA',
              style: TextStyle(
                fontFamily: 'Overbit Regular',
                fontSize: 40,
                color: locator<SudokuStyle>().flatColor,
                letterSpacing: 5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              height: 1,
              color: locator<SudokuStyle>().flatColor),
          const SizedBox(height: 20),
          BlocSelector<SudokuGameCubit, SudokuGameState, String>(
            selector: (state) => state.type.name,
            builder: (context, name) {
              return Container(
                margin: const EdgeInsets.only(left: 35),
                child: Text(
                  'SIMBOLO_\n$name',
                  style: TextStyle(
                    fontFamily: 'Overbit Regular',
                    fontSize: 20,
                    color: locator<SudokuStyle>().flatColor,
                    letterSpacing: 5,
                  ),
                  textAlign: TextAlign.left,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
                children: TokenType.values.map((type) {
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
                            ? locator<SudokuStyle>().selectedCell
                            : locator<SudokuStyle>().topBackground,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: locator<SudokuStyle>().flatColor,
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
                                color: locator<SudokuStyle>().flatColor,
                                fontFamily: 'Overbit Regular',
                              ),
                            ),
                          )
                        : Image.asset(type.token, width: 40, height: 40),
                  ),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 40),
          const Center(child: TextShadowButton(text: 'salir')),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
