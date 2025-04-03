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

    _gameTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (!mounted) return;
      setState(() {
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
    if (_remainingTime <= 0) return;

    setState(() {
      if (!_gameState.checkColor(tappedColor)) {
        _gameTimer?.cancel();
        _audioPlayer.play(AssetSource('sounds/gameover.mp3'));
        _showGameOverDialog();
      } else {
        _audioPlayer.play(AssetSource('sounds/correct.mp3'));
        _gameState.changeTargetColor();
        _resetTimer();
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoText('SCORE', _gameState.score.toString()),
            const SizedBox(width: 20),
            _buildInfoText('BEST', _gameState.highScore.toString()),
            const SizedBox(width: 20),
            _buildInfoText('TIME', _remainingTime.toStringAsFixed(1)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: _startGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.black, Colors.grey[900]!],
          ),
        ),
        child:
            _gameState.isGameOver
                ? const Center(
                  child: Text(
                    'GAME OVER\nTAP REFRESH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                )
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Tap the ${_gameState.targetColorName} squares!',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.cyanAccent),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
