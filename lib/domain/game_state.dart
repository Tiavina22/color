import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class GameState {
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  List<Color> colors = [Colors.red, Colors.blue, Colors.green];
  late Color targetColor;
  late String targetColorName;
  double timeLimit = 5.0; // Temps initial en secondes

  GameState() {
    _loadHighScore();
    reset();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      highScore = score;
      await prefs.setInt('highScore', highScore);
    }
  }

  void reset() {
    score = 0;
    isGameOver = false;
    timeLimit = 5.0; // Réinitialiser le temps limite
    colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
    ]; // Réinitialiser les couleurs
    changeTargetColor();
  }

  void changeTargetColor() {
    final random = colors.toList()..shuffle();
    targetColor = random.first;
    targetColorName = _getColorName(targetColor);
  }

  void updateDifficulty() {
    // Ajouter de nouvelles couleurs basées sur le score
    if (score == 5 && !colors.contains(Colors.yellow)) {
      colors.add(Colors.yellow);
    }
    if (score == 10 && !colors.contains(Colors.purple)) {
      colors.add(Colors.purple);
    }
    if (score == 15 && !colors.contains(Colors.orange)) {
      colors.add(Colors.orange);
    }

    // Réduire le temps disponible
    timeLimit = max(1.0, 5.0 - (score ~/ 10) * 0.5);
  }

  bool checkColor(Color tappedColor) {
    if (tappedColor == targetColor) {
      score++;
      updateDifficulty();
      _saveHighScore();
      return true;
    }
    isGameOver = true;
    _saveHighScore();
    return false;
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    return '';
  }
}
