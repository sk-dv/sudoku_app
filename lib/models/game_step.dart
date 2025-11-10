import 'package:flutter/material.dart';

enum GameStep {
  stop,
  play;

  GameStep get toggle {
    return this == GameStep.stop ? GameStep.play : GameStep.stop;
  }

  IconData get icon {
    return this == GameStep.stop ? Icons.play_arrow : Icons.pause;
  }
}
