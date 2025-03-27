import 'package:flutter/material.dart';

class AvatarWrapper extends StatelessWidget {
  final bool isDarkMode;

  const AvatarWrapper({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.centerLeft,
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
    );
  }
}
