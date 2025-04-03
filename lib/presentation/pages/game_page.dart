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

class GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  final GameState _gameState = GameState();
  Timer? _gameTimer;
  double _remainingTime = 5.0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _progressController;
  bool _showCountdown = true;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startCountdown();
  }

  void _startCountdown() {
    setState(() => _showCountdown = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown = 2);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _countdown = 1);
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => _showCountdown = false);
          _startGame();
        });
      });
    });
  }

  void _startGame() {
    _gameState.reset();
    _remainingTime = _gameState.timeLimit;
    _resetTimer();
  }

  void _resetTimer() {
    _gameTimer?.cancel();
    _remainingTime = _gameState.timeLimit;
    _progressController.value = 1.0;

    // Ralentir la fréquence de mise à jour à 100ms et ajuster la réduction du temps
    _gameTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) return;
      setState(() {
        // Réduire de 0.1 au lieu de 0.05 pour une mise à jour plus régulière
        _remainingTime -= 0.1;
        _progressController.value = _remainingTime / _gameState.timeLimit;

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
        // Ajouter un léger délai avant de changer la couleur
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _gameState.changeTargetColor();
              _resetTimer();
            });
          }
        });
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
                  _startCountdown();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressController.value,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              _progressController.value > 0.3 ? Colors.cyanAccent : Colors.red,
            ),
            minHeight: 10,
          );
        },
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'GAME OVER',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Score: ${_gameState.score}',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _startCountdown(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              side: const BorderSide(color: Colors.cyanAccent),
            ),
            child: const Text('REJOUER'),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('MENU PRINCIPAL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridColors = List.generate(9, (index) {
      // Assurer une meilleure distribution des couleurs
      return index < _gameState.colors.length
          ? _gameState.colors[index]
          : _gameState.colors[Random().nextInt(_gameState.colors.length)];
    })..shuffle();

    // Assurer qu'il y a au moins une couleur cible
    if (!gridColors.contains(_gameState.targetColor)) {
      gridColors[Random().nextInt(gridColors.length)] = _gameState.targetColor;
    }

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
            onPressed: _startCountdown,
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
            _showCountdown
                ? Center(
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 100,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : _gameState.isGameOver
                ? _buildGameOverScreen()
                : Column(
                  children: [
                    _buildProgressBar(),
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
