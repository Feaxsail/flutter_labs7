import 'package:audioplayers/audioplayers.dart';

class SoundService {
  
  static final AudioPlayer _bgPlayer = AudioPlayer();
  static bool _isMuted = false;

  static bool get isMuted => _isMuted;

  
  static Future<void> playBackground() async {
    if (_isMuted) return;
    
    await _bgPlayer.setSource(AssetSource('sounds/background.mp3'));
    await _bgPlayer.setVolume(0.4);
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.resume();
  }

  static Future<void> _playEffect(String path, {double volume = 1.0}) async {
    if (_isMuted) return;
    final player = AudioPlayer();
    await player.setSource(AssetSource('sounds/$path'));
    await player.setVolume(volume);
    await player.resume();
    // Освобождаем память после завершения звука
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  static Future<void> playWin()     => _playEffect('win.mp3');
  static Future<void> playJackpot() => _playEffect('jackpot.mp3');
  static Future<void> playLose()    => _playEffect('lose.mp3');
  static Future<void> playClick()   => _playEffect('click.mp3');

 
  static Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      await _bgPlayer.pause();
    } else {
      await _bgPlayer.resume();
    }
  }
}