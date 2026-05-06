import 'package:flutter/material.dart';
import 'dart:math';
import 'sound_service.dart';

class SlotMachine extends StatefulWidget {
  const SlotMachine({super.key});

  @override
  State<SlotMachine> createState() => _SlotMachineState();
}

class _SlotMachineState extends State<SlotMachine> {
  int _coins = 100;
  List<String> _slots = ['🍒', '🍒', '🍒'];
  final List<String> _symbols = ['🍒', '🍋', '🍇', '🍊', '💎', '7️⃣'];
  
  bool _isMuted = false;
  // ✅ Флаг _backgroundStarted удалён. Запуск музыки теперь в initState.

  @override
  void initState() {
    super.initState();
    // 🎵 Запускаем фон сразу. audioplayers корректно обрабатывает задержки.
    SoundService.playBackground();
  }

  Future<void> _spin() async {
    if (_coins <= 0) return;

    // 🔊 await добавлен, так как метод теперь асинхронный
    await SoundService.playClick();

    setState(() {
      _coins -= 10;
      _slots = List.generate(3, (_) => _symbols[Random().nextInt(_symbols.length)]);
    });

    await Future.delayed(const Duration(seconds: 1));

    bool isJackpot = _slots[0] == _slots[1] && _slots[1] == _slots[2];
    bool isWin = _slots[0] == _slots[1] || _slots[1] == _slots[2] || _slots[0] == _slots[2];

    // 🏆 await добавлен ко всем звуковым вызовам
    if (_coins == 0) {
      await SoundService.playLose();
    } else if (isJackpot) {
      _coins += 100;
      await SoundService.playJackpot();
    } else if (isWin) {
      _coins += 20;
      await SoundService.playWin();
    } else {
      await SoundService.playLose();
    }

    setState(() {});
  }

  void _toggleMute() {
    SoundService.toggleMute();
    setState(() {
      _isMuted = SoundService.isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Слот-машина'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                  onPressed: _toggleMute,
                  tooltip: _isMuted ? 'Включить звук' : 'Выключить звук',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Монеты: $_coins',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _slots.map((slot) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  alignment: Alignment.center,
                  child: Text(slot, style: const TextStyle(fontSize: 40)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _coins > 0 ? _spin : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.orange,
              ),
              child: const Text('КРУТИТЬ', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}