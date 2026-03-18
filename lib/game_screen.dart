import 'package:flutter/material.dart';
import 'services/audio_service.dart';
import 'game_model.dart';
import 'widgets/game_ui.dart';
import 'widgets/game_dialogs.dart';
import 'game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with GameDialogs {
  final AudioService _audio = AudioService();
  late GameModel _gameModel;
  bool _didShowWelcome = false;
  bool _didShowWin = false; 

  @override
  GameModel get gameModel => _gameModel;  

  @override
  AudioService get audio => _audio;

  @override
  void initState() {
    super.initState();
    _gameModel = GameModel();

    // 🔰 Load saved best score and WAIT for it before showing anything
    gameModel.loadBestScore().then((_) {
      setState(() {}); // refresh UI with loaded score
    // Show dialog after saved best score is loaded
    // using addPostFrameCallback ensures context is ready and the dialog can be shown safely.
    // we only show the dialog once, from initState via the post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_didShowWelcome) {
          _didShowWelcome = true;
          showWelcomeDialog();
        }
      });
    });
  }

  // ============ Swipe handler — Also handling Game State ====================
  void _handleSwipe(DragEndDetails details) async {
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

    // ── Phase 2: addingTile ────────────────────────
    gameModel.state = GameState.addingTile;
    gameModel.addRandomTile();
    setState(() {}); // new tile appears
    await Future.delayed(const Duration(milliseconds: 150)); // wait for pop-in

    // 🔰 Reset isMerged so the pop animation doesn't repeat
    for (var row in _gameModel.grid) {
      for (var cell in row) {
        if (cell != null) cell.remove('isMerged');
      }
    }
    setState(() {}); // 🔰 scale goes back to 1.0

    // Check if player just hit 2048
    bool hasWon = gameModel.grid.any(
      (row) => row.any((cell) => cell?['value'] == 2048) 
    );
    // 🔰 Play win sound if 2048 tile is on the board (even if game continues)
    if (hasWon && !_didShowWin) {
      _didShowWin = true;
      if (gameModel.score > gameModel.bestScore) {
        gameModel.bestScore = gameModel.score;
        await gameModel.saveBestScore();
      }
      await _audio.playWin();  // 🔰 sound first
      showWinDialog();         // 🔰 then dialog
    }

    // ── Phase 3: CHECK GAME OVER ─────────────────
    if (gameModel.gameOver) {
      gameModel.state = GameState.gameOver;
      await _audio.playGameOver(); // 🔰 sound first, THEN dialog

      if (gameModel.score > gameModel.bestScore) {
        gameModel.bestScore = gameModel.score;
        await gameModel.saveBestScore();
      }
      showGameOverDialog();
      return;
    }

    // ── Phase 4: Back to PLAYING ─────────────────
    gameModel.state = GameState.playing;
    setState(() {});
  }

  // ============ Restart game ====================
  @override
  void restartGame() {
    setState(() {
      gameModel.startGame(); // Resets grid, score, and sets state to 'playing'
      _audio.playBgMusic();  // Ensures background music starts over
      _didShowWin = false;  // Resets the flag so the win dialog can show again
    });
  }

  @override
  void dispose() {
    _audio.dispose(); // 🔰 clean up players
    super.dispose();
  }


  // ================= BUILD UI ===========================
  @override
  Widget build(BuildContext context) {
    return GameUI(
      gameModel: gameModel,
      audio: _audio,
      onSwipe: _handleSwipe,
      onMuteToggle: () {
        setState(() {
          _audio.toggleMute();
        });
      },
      onReplay: () {
        restartGame();
      },
    );
  }
}
