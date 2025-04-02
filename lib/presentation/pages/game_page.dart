import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/game_state.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  final GameState _gameState = GameState();
  Timer? _timer;
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _gameState.loadHighScore();
    _startGame();
  }

  void _startGame() {
    _gameState.reset();
    _timer?.cancel();
    _updateTimer();
  }

  void _updateTimer() {
    _timer = Timer.periodic(
      Duration(milliseconds: (_gameState.difficulty * 1000).toInt()),
      (timer) {
        setState(() {
          _gameState.changeTargetColor();
          _controller.forward(from: 0.0);
        });
      },
    );
  }

  void _onColorTap(Color tappedColor) async {
    setState(() {
      if (!_gameState.checkColor(tappedColor)) {
        _timer?.cancel();
        _playGameOverSound();
      } else {
        _playCorrectSound();
        _updateTimer();
      }
    });
  }

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  Future<void> _playGameOverSound() async {
    await _audioPlayer.play(AssetSource('sounds/gameover.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Score: ${_gameState.score}'),
            Text('High Score: ${_gameState.highScore}'),
          ],
        ),
      ),
      body: _gameState.isGameOver ? _buildGameOverScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Game Over!', style: Theme.of(context).textTheme.headlineLarge),
          Text(
            'Score: ${_gameState.score}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startGame,
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final color = _gameState.colors[index % _gameState.colors.length];
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
