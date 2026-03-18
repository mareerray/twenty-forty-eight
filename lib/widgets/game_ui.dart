import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../game_model.dart';
import 'tile_data.dart';

class GameUI extends StatelessWidget {
  final GameModel gameModel;
  final AudioService audio;
  final void Function(DragEndDetails) onSwipe;
  final VoidCallback onMuteToggle;
  final VoidCallback onReplay;

  const GameUI({
    super.key,
    required this.gameModel,
    required this.audio,
    required this.onSwipe,
    required this.onMuteToggle,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          children: [
            const Icon(Icons.grid_on_outlined, color: Colors.white, size: 30),
            const SizedBox(width: 8),
            Text('2048 Game',
              style: GoogleFonts.tiltPrism(
                color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(audio.isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white),
            onPressed: onMuteToggle,
            tooltip: audio.isMuted ? 'Unmute' : 'Mute',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── HUD ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text('𓆩✧𓆪',
                    style: GoogleFonts.figtree(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)
                  ),
                  Text(gameModel.score.toString(),
                    style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ]),
                Column(children: [
                  Text('REPLAY',
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6f7b5a),
                      letterSpacing: 2)
                  ),
                  IconButton(
                    onPressed: onReplay,
                    icon: const Icon(Icons.replay_circle_filled, color: Color(0xFF6f7b5a)),
                    iconSize: 38,
                    tooltip: 'Replay Game',
                  ),
                ]),
                Column(children: [
                  Text('𓆩♕𓆪',
                    style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  Text(gameModel.bestScore.toString(),
                    style: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ]),
              ],
            ),

            const SizedBox(height: 20),

            // ── Game container ──
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
              child: GestureDetector(
                onPanEnd: onSwipe,
                child: Column(
                  children: [
                    // ── Grid ──
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
                              color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // empty background cells
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
                                // animated tiles
                                for (var tile in gameModel.getTiles())
                                  AnimatedPositioned(
                                    key: ValueKey(tile['id']),
                                    duration: const Duration(milliseconds: 150),
                                    curve: Curves.easeInOut,
                                    left: padding + tile['col'] * (cellSize + gap),
                                    top: padding + tile['row'] * (cellSize + gap),
                                    width: cellSize,
                                    height: cellSize,
                                    child: AnimatedScale(
                                      scale: tile['isMerged'] ? 1.1 : 1.0, // 🔰 pop animation for merged tile
                                      duration: const Duration(milliseconds: 150),
                                      curve: Curves.easeOutBack,
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
                                              color: Colors.white),
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

                    // ── Swipe Pad ──
                    Container(
                      width: double.infinity,
                      height: 165,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_up_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.keyboard_arrow_left_rounded,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Text('SWIPE',
                                  style: GoogleFonts.figtree(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.6),
                                      letterSpacing: 2)),
                              const SizedBox(width: 12),
                              Icon(Icons.keyboard_arrow_right_rounded,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary),
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
