import 'package:flutter/material.dart';
import 'game_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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

  // Show dialog after first frame is rendered
  // using addPostFrameCallback ensures context is ready and the dialog can be shown safely.
  // we only show the dialog once, from initState via the post-frame callback
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_didShowWelcome) {
      _didShowWelcome = true;
      _showWelcomeDialog();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and icon
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

      // HUD: score & best score
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('Score', style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold)), 
                  Text(gameModel.score.toString(), style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold))
                ]
              ),
              // Column(
              //   children: [
              //     Text('|', style: GoogleFonts.figtree(fontSize: 30)),
              //   ],
              // ), 
              Column(
                children: [
                  Text('Best Score', style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold)), 
                  Text(gameModel.bestScore.toString(), style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold))
                ]
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Game container
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 700,
            ),
            child: AspectRatio(
              aspectRatio: 1.0, // square

              // =========== The grid container ======================
              child: GestureDetector(
                onPanEnd: (DragEndDetails details) async {
                    // BLOCK if already moving
                    if (_isMoving) return;
                    
                    double dx = details.velocity.pixelsPerSecond.dx;
                    double dy = details.velocity.pixelsPerSecond.dy;
                    
                    if (dx.abs() < 100 && dy.abs() < 100) return;
                    
                    _isMoving = true;  // LOCK
                    
                    // Do ONE move
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
                    
                    setState(() {});
                    
                    // Unlock after 300ms (fast!)
                    await Future.delayed(Duration(milliseconds: 300));
                    _isMoving = false;
                  },                
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
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
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Restart button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            onPressed: () {
              gameModel.startGame();
              setState(() {});
            },
            child: Text('Restart', 
              style: GoogleFonts.figtree(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    ),
  );
  }
}