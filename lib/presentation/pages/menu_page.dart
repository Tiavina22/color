import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.black, Colors.grey[900]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'CYBER\nCOLORS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 0.9,
                  fontFamily: 'Orbitron',
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.cyanAccent,
                      blurRadius: 10,
                      offset: Offset(0, 0),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.cyanAccent,
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          side: const BorderSide(color: Colors.cyanAccent, width: 2),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          elevation: 10,
          shadowColor: Colors.cyanAccent.withOpacity(0.5),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.cyanAccent),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'RÈGLES DU JEU',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            content: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(16),
              child: const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'COMMENT JOUER:',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '• Tapez sur les carrés de la couleur indiquée\n'
                      '• Soyez rapide avant que le temps ne s\'écoule\n'
                      '• Le jeu devient plus difficile avec votre score',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'DIFFICULTÉ PROGRESSIVE:',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '• Nouvelles couleurs ajoutées\n'
                      '• Temps plus court\n'
                      '• Plus de choix de couleurs',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.cyanAccent,
                  side: const BorderSide(color: Colors.cyanAccent),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'COMPRIS!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }
}
