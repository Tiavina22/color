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
      title: 'Speed Tap Colors',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      home: const MenuPage(),
    );
  }
}
