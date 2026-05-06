import 'dart:math';
import 'package:flutter/material.dart';
import 'slot_row.dart';
import 'sound_service.dart'; // 👈 Импорт сервиса

class SlotMachine extends StatefulWidget {
  const SlotMachine({super.key});

  @override
  State<SlotMachine> createState() => _SlotMachineState();
}

class _SlotMachineState extends State<SlotMachine> {
  final _random = Random();
  final _symbols = [
    'assets/images/cherry.png',
    'assets/images/lemon.png',
    'assets/images/seven.png',
  ];

  int _coins = 10;
  String _slot1 = 'assets/images/cherry.png';
  String _slot2 = 'assets/images/lemon.png';
  String _slot3 = 'assets/images/seven.png';
  String _message = 'Крутите барабаны!';
  bool _isSpinning = false;
  bool _backgroundStarted = false; // 👈 Политика автоплея браузера

  // Состояние для перерисовки кнопки mute
  bool _isMuted = false;

  Future<String> _spinReel({
    required int totalTicks,
    required void Function(String) onTick,
  }) async {
    for (int i = 0; i < totalTicks; i++) {
      double progress = i / totalTicks;
      int durationMs;
      if (progress < 0.5) durationMs = 40;
      else if (progress < 0.8) durationMs = 100;
      else durationMs = 200;

      String nextSymbol = _symbols[_random.nextInt(_symbols.length)];
      onTick(nextSymbol);
      await Future.delayed(Duration(milliseconds: durationMs));
    }
    return _symbols[_random.nextInt(_symbols.length)];
  }

  Future<void> _spin() async {
    if (_coins <= 0 || _isSpinning) return;

    // 👈 Обход политики браузера: запускаем музыку только после 1-го клика
    if (!_backgroundStarted) {
      SoundService.playBackground();
      _backgroundStarted = true;
    }

    setState(() {
      _isSpinning = true;
      _message = '';
    });

    SoundService.playClick(); // 👈 Звук нажатия

    _slot1 = await _spinReel(
      totalTicks: 10,
      onTick: (symbol) => setState(() => _slot1 = symbol),
    );
    _slot2 = await _spinReel(
      totalTicks: 13,
      onTick: (symbol) => setState(() => _slot2 = symbol),
    );
    _slot3 = await _spinReel(
      totalTicks: 16,
      onTick: (symbol) => setState(() => _slot3 = symbol),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isSpinning = false;
      if (_slot1 == _slot2 && _slot2 == _slot3) {
        if (_slot1 == 'assets/images/seven.png') {
          _coins += 10;
          _message = '🎉 ДЖЕКПОТ! +10 монет!';
          SoundService.playJackpot(); // 👈 Звук джекпота
        } else {
          _coins += 3;
          _message = 'Победа! 🎉 +3 монеты';
          SoundService.playWin(); // 👈 Звук победы
        }
      } else {
        _coins -= 1;
        _message = 'Попробуй ещё раз 😔';
        SoundService.playLose(); // 👈 Звук проигрыша
      }
    });
  }

  void _reset() {
    setState(() {
      _coins = 10;
      _slot1 = 'assets/images/cherry.png';
      _slot2 = 'assets/images/lemon.png';
      _slot3 = 'assets/images/seven.png';
      _message = 'Крутите барабаны!';
      _isSpinning = false;
    });
  }

  // 👈 Метод переключения звука
  void _toggleMute() {
    SoundService.toggleMute();
    setState(() {
      _isMuted = SoundService.isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 👈 Кнопка mute в самом верху
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _toggleMute,
              icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
              label: Text(_isMuted ? 'Вкл звук' : 'Выкл звук'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMuted ? Colors.redAccent : Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '💰 Монеты: $_coins',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isSpinning ? 0.6 : 1.0,
            child: SlotRow(slot1: _slot1, slot2: _slot2, slot3: _slot3),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              height: 24,
              child: Text(
                _message,
                key: ValueKey(_message),
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (_coins > 0 && !_isSpinning) ? _spin : null,
            child: Text(_isSpinning ? '🎰 КРУТИТСЯ...' : '🎰 КРУТИТЬ'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSpinning ? null : _reset,
            child: const Text('🔄 Начать заново'),
          ),
        ],
      ),
    );
  }
}