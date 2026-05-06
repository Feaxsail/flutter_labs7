import 'dart:html';

class SoundService {
  static AudioElement? _backgroundMusic;
  static bool _isMuted = false;
  static bool get isMuted => _isMuted;

  // Запуск фоновой музыки
  static void playBackground() {
    _backgroundMusic = AudioElement('assets/assets/sounds/background.mp3');
    _backgroundMusic!.loop = true;
    _backgroundMusic!.volume = 0.4;
    if (!_isMuted) {
      _backgroundMusic!.play();
    }
  }

  // Внутренний метод для одноразовых звуков
  static void _playSound(String path, {double volume = 1.0}) {
    if (_isMuted) return;
    final audio = AudioElement('assets/assets/sounds/$path');
    audio.volume = volume;
    audio.play();
  }

  // Публичные методы для событий
  static void playWin() => _playSound('win.mp3', volume: 0.8);
  static void playJackpot() => _playSound('jackpot.mp3', volume: 1.0);
  static void playLose() => _playSound('lose.mp3', volume: 0.7);
  static void playClick() => _playSound('click.mp3', volume: 0.5);

  // Переключатель звука
  static void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _backgroundMusic?.pause();
    } else {
      _backgroundMusic?.play();
    }
  }
}