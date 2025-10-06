import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_app/sudoku_game_cubit.dart';

class FloatingBottomNavigation extends StatelessWidget {
  const FloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        final isDark = state.style.mode.isDark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 60,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF2E2E52).withValues(alpha: 0.95),
                            const Color(0xFF1E1E42).withValues(alpha: 0.95),
                          ]
                        : [
                            const Color(0xFFFFFAFA).withValues(alpha: 0.95),
                            const Color(0xFFFFF0F5).withValues(alpha: 0.95),
                          ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : const Color(0xFF880E4F).withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : const Color(0xFF880E4F).withValues(alpha: 0.35),
                      offset: const Offset(0, 8),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : const Color(0xFF880E4F).withValues(alpha: 0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.apps_rounded,
                      label: 'NIVELES',
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.today_rounded,
                      label: 'HOY',
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: Icons.show_chart_rounded,
                      label: 'STATS',
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameCubit, SudokuGameState>(
      builder: (context, state) {
        final isDark = state.style.mode.isDark;
        final selectedColor = state.style.selectedCell;
        final normalColor = state.style.borderColor.withValues(alpha: 0.6);

        return Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  transform: Matrix4.translationValues(
                    0,
                    isSelected ? -8 : 0,
                    0,
                  ),
                  child: Container(
                    width: isSelected ? 40 : 30,
                    height: isSelected ? 40 : 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFF5A67D8),
                                      const Color(0xFF4A57C8),
                                    ]
                                  : [
                                      const Color(0xFFE91E63),
                                      const Color(0xFFD81B60),
                                    ],
                            )
                          : null,
                      color: isSelected ? null : Colors.transparent,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: selectedColor.withValues(alpha: 0.5),
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : normalColor,
                        size: isSelected ? 24 : 18,
                      ),
                    ),
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 8 : 7,
                    color: isSelected ? selectedColor : normalColor,
                    fontFamily: 'Brick Sans',
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 0.3,
                  ),
                  child: Container(
                    margin:  EdgeInsets.only(bottom: isSelected ? 6 : 0),
                    child: Text(label),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
