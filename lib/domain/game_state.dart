import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  List<Color> colors = [Colors.red, Colors.blue, Colors.green];
  late Color targetColor;
  late String targetColorName;

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
    changeTargetColor();
  }

  void changeTargetColor() {
    final random = colors.toList()..shuffle();
    targetColor = random.first;
    targetColorName = _getColorName(targetColor);
  }

  bool checkColor(Color tappedColor) {
    if (tappedColor == targetColor) {
      score++;
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
    return '';
  }
}
