import 'package:flutter/material.dart';
import 'presentation/pages/menu_page.dart';

void main() {
  runApp(const SpeedTapColors());
}

class SpeedTapColors extends StatelessWidget {
  const SpeedTapColors({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Colors',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.cyanAccent,
            backgroundColor: Colors.black,
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      home: const MenuPage(),
    );
  }
}
