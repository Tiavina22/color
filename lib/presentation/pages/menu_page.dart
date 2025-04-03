import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.blue.shade800],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Speed Tap Colors',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black38,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              _buildMenuButton(
                'JOUER',
                Icons.play_arrow,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GamePage()),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuButton('RÈGLES', Icons.rule, () => _showRules(context)),
              const SizedBox(height: 20),
              _buildMenuButton(
                'QUITTER',
                Icons.exit_to_app,
                () => SystemNavigator.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Règles du jeu'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Comment jouer:'),
                  SizedBox(height: 10),
                  Text('• Tapez sur les carrés de la couleur indiquée'),
                  Text('• Soyez rapide avant que le temps ne s\'écoule'),
                  Text('• Le jeu devient plus difficile avec votre score'),
                  SizedBox(height: 20),
                  Text('Difficulté progressive:'),
                  Text('• Nouvelles couleurs ajoutées'),
                  Text('• Temps plus court'),
                  Text('• Plus de choix de couleurs'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Compris!'),
              ),
            ],
          ),
    );
  }
}
