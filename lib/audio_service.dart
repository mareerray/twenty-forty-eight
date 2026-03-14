import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  // AudioPool? _mergePool; // 🔰 pool pre-loads the sound, ready to fire instantly

  // // 🔰 Call this once when the game starts
  // Future<void> init() async {
  //   _mergePool = await AudioPool.createFromAsset(
  //     path: 'audio/merge.mp3',
  //     maxPlayers: 4, // 🔰 up to 4 overlapping merge sounds at once
  //   );
  // }

  Future<void> playBgMusic() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource('audio/bg_music.mp3'));
  }

  Future<void> stopBgMusic() async {
    await _bgPlayer.stop();
  }

  // Future<void> playMerge() async {
  //   await _mergePool?.start(); // 🔰 fires instantly, no lag
  // }

  Future<void> playWin() async {
    await _bgPlayer.stop();
    await AudioPlayer().play(AssetSource('audio/win.wav'));
  }

  Future<void> playGameOver() async {
    await _bgPlayer.stop();
    await AudioPlayer().play(AssetSource('audio/gameover.wav'));
  }

  void dispose() {
    _bgPlayer.dispose();
    // _mergePool?.dispose();
  }
}

