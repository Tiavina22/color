import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/game_state.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final GameState _gameState = GameState();
  Timer? _gameTimer;
  double _remainingTime = 5.0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _gameState.reset();
    _remainingTime = _gameState.timeLimit;
    _resetTimer();
  }

  void _resetTimer() {
    _gameTimer?.cancel();
    _remainingTime = _gameState.timeLimit;

    // Changement à 50ms pour une animation plus fluide mais avec moins d'impact sur les performances
    _gameTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (!mounted) return;
      setState(() {
        // Réduire de 0.05 au lieu de 0.1 pour un décompte plus lent
        _remainingTime -= 0.05;

        if (_remainingTime <= 0) {
          _gameState.isGameOver = true;
          _gameTimer?.cancel();
          _audioPlayer.play(AssetSource('sounds/gameover.mp3'));
          _showGameOverDialog();
        }
      });
    });
  }

  void _onColorTap(Color tappedColor) async {
    if (_remainingTime <= 0) return; // Empêcher les clics après le temps écoulé

    setState(() {
      if (!_gameState.checkColor(tappedColor)) {
        _gameTimer?.cancel();
        _audioPlayer.play(AssetSource('sounds/gameover.mp3'));
        _showGameOverDialog();
      } else {
        _audioPlayer.play(AssetSource('sounds/correct.mp3'));
        _gameState
            .changeTargetColor(); // Changer la couleur cible immédiatement
        _resetTimer(); // Réinitialiser le timer
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Game Over!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Score: ${_gameState.score}'),
                Text('Best Score: ${_gameState.highScore}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridColors = List.generate(9, (index) {
      if (index == 0) {
        return _gameState.targetColor;
      }
      return _gameState.colors[Random().nextInt(_gameState.colors.length)];
    })..shuffle();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: ${_gameState.score}'),
            const SizedBox(width: 20),
            Text('Best: ${_gameState.highScore}'),
            const SizedBox(width: 20),
            Text('Time: ${_remainingTime.toStringAsFixed(1)}s'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _startGame),
        ],
      ),
      body:
          _gameState.isGameOver
              ? const Center(child: Text('Tap refresh to play again!'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Tap the ${_gameState.targetColorName} squares!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final color = gridColors[index];
                        return GestureDetector(
                          onTap: () => _onColorTap(color),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
