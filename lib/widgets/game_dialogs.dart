import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../game_model.dart';
import '../game_screen.dart';

mixin GameDialogs on State<GameScreen> {
  GameModel get gameModel;
  AudioService get audio;
  void restartGame();

  // ============= Show welcome dialog on first load ====================
  void showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Welcome to 2048',
            style: GoogleFonts.tiltPrism(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary
            )
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goal:\nCombine tiles to reach 2048 .\n',
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color)
                ),
                const SizedBox(height: 8),
                Text(
                  'How to play:\n'
                  '• Swipe up, down, left or right.\n'
                  '• All tiles move in that direction.\n'
                  '• Same numbers that touch will merge.\n'
                  '• After each move, a new tile (2 or 4) appears.\n',
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 8),
                Text('Game over:\nNo empty spaces and no merges left.\n',
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color)
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: Text("Let's play!",
                style: GoogleFonts.figtree(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
          ],
        );
      },
    );
  }

  // =============== Show win dialog ================================
  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('You reached 2048! 🎉',
            style: GoogleFonts.tiltPrism(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary)
          ),
          content: Text(
            ' 𓆩✧𓆪 Score: ${gameModel.score}\n 𓆩♕𓆪 Best score: ${gameModel.bestScore}',
            style: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Keep Playing',
                style: GoogleFonts.figtree(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: Text('New Game',
                style: GoogleFonts.figtree(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
          ],
        );
      },
    );
  }

  // =============== Show game over dialog ============================
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over!',
            style: GoogleFonts.tiltPrism(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary)
          ),
          content: Text(
            ' 𓆩✧𓆪 Your score: ${gameModel.score}\n 𓆩♕𓆪 Best score: ${gameModel.bestScore}',
            style: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
              child: Text('Play Again',
                style: GoogleFonts.figtree(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
          ],
        );
      },
    );
  }
}
