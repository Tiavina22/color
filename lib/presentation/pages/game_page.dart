import 'dart:async';
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
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _gameState.reset();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _gameState.changeTargetColor();
      });
    });
  }

  void _onColorTap(Color tappedColor) async {
    setState(() {
      if (!_gameState.checkColor(tappedColor)) {
        _timer?.cancel();
        _audioPlayer.play(AssetSource('sounds/gameover.mp3'));
        _showGameOverDialog();
      } else {
        _audioPlayer.play(AssetSource('sounds/correct.mp3'));
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: ${_gameState.score}'),
            const SizedBox(width: 20),
            Text('Best: ${_gameState.highScore}'),
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
                        final color =
                            _gameState.colors[index % _gameState.colors.length];
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
