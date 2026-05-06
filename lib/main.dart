import 'package:flutter/material.dart';
import 'slot_machine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('🎰 Слот-машина'),
        ),
        body: const SlotMachine(),
      ),
    );
  }
}