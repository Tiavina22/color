import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  int score = 0;
  late Color targetColor;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final Random _random = Random();

  int highScore = 0;
  bool isGameOver = false;
  double difficulty = 5.0; // secondes entre chaque changement

  GameState() {
    targetColor = colors.first;
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
  }

  Future<void> updateHighScore() async {
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore);
    }
  }

  void reset() {
    score = 0;
    isGameOver = false;
    difficulty = 5.0;
    changeTargetColor();
  }

  void changeTargetColor() {
    targetColor = colors[_random.nextInt(colors.length)];
  }

  bool checkColor(Color tappedColor) {
    if (tappedColor == targetColor) {
      score++;
      // Augmenter la difficulté
      difficulty = max(1.0, 5.0 - (score / 20));
      return true;
    }
    isGameOver = true;
    updateHighScore();
    return false;
  }

  String get targetColorName {
    if (targetColor == Colors.red) return 'red';
    if (targetColor == Colors.blue) return 'blue';
    if (targetColor == Colors.green) return 'green';
    if (targetColor == Colors.yellow) return 'yellow';
    if (targetColor == Colors.purple) return 'purple';
    if (targetColor == Colors.orange) return 'orange';
    return '';
  }
}
