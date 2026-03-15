import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twenty-Forty-Eight Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6f7b5a),
          primary: const Color(0xFF6f7b5a),
          secondary: const Color(0xFF673AB7),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF6f7b5a)), 
          titleLarge: TextStyle(color: Color(0xFF673AB7)), 
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
