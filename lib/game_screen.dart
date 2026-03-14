import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'audio_service.dart';
import 'game_model.dart';
import 'tile_data.dart';
import 'game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
    State<GameScreen> createState() => _GameScreenState();
  }

  class _GameScreenState extends State<GameScreen> {
    final AudioService _audio = AudioService();

    late GameModel gameModel;
    bool _didShowWelcome = false;

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

  // ============ Swipe handler — Also handling Game State ====================
  void _handleSwipe(DragEndDetails details) async {
    // 🔰 Only accept swipes when actually playing
    if (gameModel.state != GameState.playing) return;

    double dx = details.velocity.pixelsPerSecond.dx;
    double dy = details.velocity.pixelsPerSecond.dy;

    if (dx.abs() < 100 && dy.abs() < 100) return;

    // ── Phase 1: MOVING ──────────────────────────
    gameModel.state = GameState.moving;

    bool moved = false;
    if (dx.abs() > dy.abs()) {
      moved = dx > 0
          ? gameModel.moveRight(addTile: false)
          : gameModel.moveLeft(addTile: false);
    } else {
      moved = dy > 0
          ? gameModel.moveDown(addTile: false)
          : gameModel.moveUp(addTile: false);
    }

    setState(() {}); // tiles slide
    await Future.delayed(const Duration(milliseconds: 150)); // wait for slide

    if (!moved) {
      gameModel.state = GameState.playing; // nothing moved, go back
      return;
    }

    // ── Phase 2: SPAWNING ────────────────────────
    gameModel.state = GameState.spawning;
    gameModel.addRandomTile();
    setState(() {}); // new tile appears
    await Future.delayed(const Duration(milliseconds: 150)); // wait for pop-in

    // Check if player just hit 2048
    bool hasWon = gameModel.grid.any(
      (row) => row.any((cell) => cell?['value'] == 2048)
    );
    // 🔰 Play win sound if 2048 tile is on the board (even if game continues)
    if (hasWon) _audio.playWin();

    // ── Phase 3: CHECK GAME OVER ─────────────────
    if (gameModel.gameOver) {
      gameModel.state = GameState.gameOver;
      await _audio.playGameOver(); // 🔰 sound first, THEN dialog

      if (gameModel.score > gameModel.bestScore) {
        gameModel.bestScore = gameModel.score;
        await gameModel.saveBestScore();
      }
      _showGameOverDialog();
      return;
    }

    // ── Phase 4: Back to PLAYING ─────────────────
    gameModel.state = GameState.playing;
    setState(() {});
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
                _audio.playBgMusic(); // 🔰 music starts
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
                _audio.playBgMusic(); // 🔰 music restarts
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

  @override
  void dispose() {
    _audio.dispose(); // 🔰 clean up players
    super.dispose();
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
        actions: [
          // 🔰 Mute/unmute button in the top right corner
          IconButton(
            icon: Icon(
              _audio.isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _audio.toggleMute(); // 🔰 setState so icon switches instantly
              });
            },
            tooltip: _audio.isMuted ? 'Unmute' : 'Mute',
          ),
        ],
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
                        _audio.playBgMusic(); // 🔰 music restarts
                        setState(() {});
                      },
                      icon: const Icon(Icons.replay_circle_filled, color: Color(0xFF6f7b5a)),
                      iconSize: 38,
                      tooltip: 'Replay Game',
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double size = constraints.maxWidth;
                        double padding = 8.0;
                        double gap = 4.0;
                        double cellSize = (size - padding * 2 - gap * 3) / 4;

                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              // 🔰 Background empty cells (always visible)
                              for (int r = 0; r < 4; r++)
                                for (int c = 0; c < 4; c++)
                                  Positioned(
                                    left: padding + c * (cellSize + gap),
                                    top: padding + r * (cellSize + gap),
                                    width: cellSize,
                                    height: cellSize,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),

                              // 🔰 Animated tiles on top
                              for (var tile in gameModel.getTiles())
                                AnimatedPositioned(
                                  key: ValueKey(tile['id']), // 🔰 use the stable ID for the key
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  left: padding + tile['col'] * (cellSize + gap),
                                  top: padding + tile['row'] * (cellSize + gap),
                                  width: cellSize,
                                  height: cellSize,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: getTileColor(tile['value']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        tile['value'].toString(),
                                        style: GoogleFonts.figtree(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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