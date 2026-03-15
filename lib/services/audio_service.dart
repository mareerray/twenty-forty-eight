import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  bool isMuted = false; // 🔰 mute state

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _bgPlayer.stop(); // 🔰 stop music immediately when muted
    } else {
      playBgMusic(); // 🔰 resume music when unmuted
    }
  }

  Future<void> playBgMusic() async {
    if (isMuted) return; // 🔰 do nothing if muted
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource('audio/bg_theme.mp3'));
  }

  Future<void> stopBgMusic() async {
    await _bgPlayer.stop();
  }

  Future<void> playWin() async {
    if (isMuted) return; // 🔰 do nothing if muted
    await _bgPlayer.stop();
    await AudioPlayer().play(AssetSource('audio/win.wav'));
  }

  Future<void> playGameOver() async {
    if (isMuted) return; // 🔰 do nothing if muted
    await _bgPlayer.stop();
    await AudioPlayer().play(AssetSource('audio/gameover.wav'));
  }

  void dispose() {
    _bgPlayer.dispose();
  }
}

