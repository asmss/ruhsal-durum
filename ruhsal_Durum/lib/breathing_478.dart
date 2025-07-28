import 'dart:async';
import 'package:flutter/material.dart';

class Breathing478 extends StatefulWidget {
  const Breathing478({super.key});

  @override
  State<Breathing478> createState() => _Breathing478State();
}

class _Breathing478State extends State<Breathing478>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String _stage = "Hazır mısın?";
  int _secondsLeft = 0;
  Timer? _timer;
  bool _isRunning = false;
  int _breathCount = 0;

  final List<_BreathPhase> _phases = [
    _BreathPhase("Nefes Al", 4),
    _BreathPhase("Nefesi Tut", 7),
    _BreathPhase("Nefesi Ver", 8),
  ];
  int _currentPhaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 100.0, end: 200.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startBreathingCycle() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _currentPhaseIndex = 0;
      _breathCount = 0;
    });

    _runPhase();
  }

  void _stopBreathingCycle() {
    setState(() {
      _isRunning = false;
      _stage = "Duraklatıldı";
      _secondsLeft = 0;
    });
    _timer?.cancel();
    _controller.reverse();
  }

  void _runPhase() {
    if (!_isRunning) return;

    final phase = _phases[_currentPhaseIndex];

    setState(() {
      _stage = phase.name;
      _secondsLeft = phase.duration;
    });

    if (_stage == "Nefes Al") {
      _controller.forward();
    } else if (_stage == "Nefesi Ver") {
      _controller.reverse();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 0) {
        timer.cancel();
        _currentPhaseIndex++;

        if (_currentPhaseIndex >= _phases.length) {
          _currentPhaseIndex = 0;
          _breathCount++;
        }

        _runPhase();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Daire animasyonu
            Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: _animation.value,
                    height: _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.4),
                    ),
                    child: Center(
                      child: Text(
                        _secondsLeft > 0 ? '$_secondsLeft' : '',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _stage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Text(
                    'Tekrar Sayısı: $_breathCount',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _isRunning
                      ? ElevatedButton.icon(
                    onPressed: _stopBreathingCycle,
                    icon: const Icon(Icons.pause),
                    label: const Text("Duraklat"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                  )
                      : ElevatedButton.icon(
                    onPressed: _startBreathingCycle,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Başla"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathPhase {
  final String name;
  final int duration;

  _BreathPhase(this.name, this.duration);
}
