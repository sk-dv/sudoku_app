import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const Header({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back, color: textColor),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tag, size: 16, color: textColor),
                    const SizedBox(width: 4),
                    Text('TheSudoku', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => toggleTheme(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: textColor),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pause, color: textColor),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings, color: textColor),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
