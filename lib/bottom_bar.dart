import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final bool isDarkMode;

  const BottomBar({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, size: 20, color: Colors.amber),
                const SizedBox(width: 4),
                Text('892', style: TextStyle(color: textColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.tag, size: 20, color: Colors.white),
                SizedBox(width: 4),
                Text('TheSudoku', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
                child: Text('A', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
