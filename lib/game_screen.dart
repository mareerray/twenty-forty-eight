import 'package:flutter/material.dart';
import 'game_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
    State<GameScreen> createState() => _GameScreenState();
  }

  class _GameScreenState extends State<GameScreen> {
    late GameModel gameModel;
    bool _didShowWelcome = false;
    bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    gameModel = GameModel();

    // 🔰 Load saved best score and WAIT for it before showing anything
    gameModel.loadBestScore().then((_) {
      setState(() {}); // refresh UI with loaded score
    // Show dialog after saved best score is loaded
    // using addPostFrameCallback ensures context is ready and the dialog can be shown safely.
    // we only show the dialog once, from initState via the post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_didShowWelcome) {
          _didShowWelcome = true;
          _showWelcomeDialog();
        }
      });
    });
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFF8c80a2);
      case 4: return const Color(0xFF51577c);
      case 8: return const Color(0xFF764a7d);
      case 16: return const Color(0xFF512DA8);
      case 32: return const Color(0xFF7338B7);
      case 64: return const Color(0xFF4F2E54);
      case 128: return const Color(0xFF7b1fa2);
      case 256: return const Color(0xFF4a148c);
      case 512: return const Color(0xFF880e4f);
      case 1024: return const Color(0xFFad1457);
      case 2048: return const Color(0xFFc2185b);
      default: return const Color(0xFFCCCCCC);
      // #5d4a7d, #6a7d4a, #764a7d, #4a517d
    }
  }

  // ============ Extracted swipe handler — used by both grid and swipe pad ====================
  void _handleSwipe(DragEndDetails details) async {
    if (_isMoving) return;

    double dx = details.velocity.pixelsPerSecond.dx;
    double dy = details.velocity.pixelsPerSecond.dy;

    if (dx.abs() < 100 && dy.abs() < 100) return;

    _isMoving = true;

    // 🔰 Step 1: Make the move based on swipe direction
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        gameModel.moveRight();
      } else {
        gameModel.moveLeft();
      }
    } else {
      if (dy > 0) {
        gameModel.moveDown();
      } else {
        gameModel.moveUp();
      }
    }
    // 🔰 Step 2: ALWAYS check game over after ANY move direction
    if (gameModel.gameOver) {
      if (gameModel.score > gameModel.bestScore) {
        gameModel.bestScore = gameModel.score; // 🔰 update best score on game over
        await gameModel.saveBestScore(); // 🔰 Save to device when new best is set!
      }
      _showGameOverDialog(); 
    }

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
    _isMoving = false;
  }

  // ============= Show welcome dialog on first load ====================
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap the button
      builder: (context) {
        return AlertDialog(
          title: Text('Welcome to 2048', style: GoogleFonts.tiltPrism(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal:\n'
                  'Combine tiles to reach 2048 .\n',
                  style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                SizedBox(height: 8),
                Text(
                  'How to play:\n'
                  '• Swipe up, down, left or right.\n'
                  '• All tiles move in that direction.\n'
                  '• Same numbers that touch will merge.\n'
                  '• After each move, a new tile (2 or 4) appears.\n',
                  style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                SizedBox(height: 8),
                Text(
                  'Game over:\n'
                  'No empty spaces and no merges left.\n',
                  style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                gameModel.startGame();
                setState(() {});
              },
              child: Text('Let\'s play!',
                style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
          ],
        );
      },
    );
  }

  // =============== Show game over dialog ============================
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over!',
              style: GoogleFonts.tiltPrism(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
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
                gameModel.startGame();
                setState(() {});
              },
              child: Text('Play Again',
                  style: GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ================= BUILD UI ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar with title and icon ──────────────────────────────
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          children: [
            Icon(Icons.grid_on_outlined, color: Colors.white, size: 30),
            SizedBox(width: 8),
            Text('2048 Game', 
              style: GoogleFonts.tiltPrism(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      // ── HUD: score & best score ──────────────────────────────
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('𓆩✧𓆪', style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)), 
                  Text(gameModel.score.toString(), style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold))
                ]
              ),
              // Restart icon button
              Column(
                children: [
                  Text(
                    'REPLAY',
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6f7b5a),
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        gameModel.startGame();
                        setState(() {});
                      },
                      icon: const Icon(Icons.replay_circle_filled, color: Color(0xFF6f7b5a)),
                      iconSize: 38,
                      tooltip: 'Restart',
                    ),
                  ),
                ],
              ),              
              Column(
                children: [
                  Text('𓆩♕𓆪', style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold)), 
                  Text(gameModel.bestScore.toString(), style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold))
                ]
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // ── Game container ──────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 500,
            ),

            // ── The grid container ──────────────────────────────
            // One GestureDetector covers BOTH grid and swipe pad
            child: GestureDetector(
              onPanEnd: _handleSwipe, // use the extracted method from before
              child: Column(
                children: [
              
                  // ── Grid (square) ──────────────────────────────
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        physics: const NeverScrollableScrollPhysics(), // disable scrolling
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          int row = index ~/ 4;
                          int col = index % 4;
                          int? value = gameModel.grid[row][col];
                          return Container(
                            decoration: BoxDecoration(
                              color: value == null ? Colors.grey[200] : _getTileColor(value),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                value?.toString() ?? '',
                                style: GoogleFonts.figtree(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 5),
              
                  // ── Swipe Pad ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    height: 165,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_arrow_up_rounded,
                            size: 32, color: Theme.of(context).colorScheme.primary),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard_arrow_left_rounded,
                                size: 32, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              'SWIPE',
                              style: GoogleFonts.figtree(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha:0.6),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.keyboard_arrow_right_rounded,
                                size: 32, color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            size: 32, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),            
          ),
        ],
      ),
    ),
  );
  }
}