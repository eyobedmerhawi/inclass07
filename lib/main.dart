import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PetScreen(),
    );
  }
}

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  String _petName = 'Pip';

  int _happiness = 50;
  int _hunger = 50;

  bool _gameOver = false;
  bool _hasWon = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  final TextEditingController _nameController = TextEditingController();

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  String get _mood {
    if (_happiness > 70) {
      return 'Happy';
    } else if (_happiness >= 30) {
      return 'Neutral';
    } else {
      return 'Unhappy';
    }
  }

  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    } else if (_happiness >= 30) {
      return Colors.yellow.shade700;
    } else {
      return Colors.red;
    }
  }

  String get _statusMessage {
    if (_hasWon) {
      return 'You won! $_petName stayed happy!';
    }

    if (_gameOver) {
      return 'Game Over! $_petName needs a restart.';
    }

    if (_hunger > 80) {
      return '$_petName is very hungry!';
    }

    if (_happiness <= 30) {
      return '$_petName wants to play!';
    }

    return 'Hi, I\'m $_petName!';
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _gameOver || _hasWon) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_hunger + 5 > 100) {
          _hunger = 100;
          _happiness = _clampMeter(_happiness - 20);
        } else {
          _hunger += 5;
        }
      });

      _updateOutcome();
    });
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon) {
      return;
    }

    // Loss condition
    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;

      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    // Happiness must stay strictly above 80.
    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    // Start the three-minute win timer.
    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;

      if (!mounted || _gameOver || _happiness <= 80) {
        return;
      }

      setState(() {
        _hasWon = true;
      });

      _hungerTimer?.cancel();
    });
  }

  void _changePetName() {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      return;
    }

    setState(() {
      _petName = newName;
    });

    _nameController.clear();
    FocusScope.of(context).unfocus();
  }

  void _feedPet() {
    if (_gameOver || _hasWon) {
      return;
    }

    final nextHunger = _clampMeter(_hunger - 10);

    final happinessChange = nextHunger < 30 ? -20 : 10;

    final nextHappiness = _clampMeter(_happiness + happinessChange);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
    });

    _updateOutcome();
  }

  void _playWithPet() {
    if (_gameOver || _hasWon) {
      return;
    }

    setState(() {
      _happiness = _clampMeter(_happiness + 10);
      _hunger = _clampMeter(_hunger + 5);
    });

    _updateOutcome();
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    _hungerTimer?.cancel();

    setState(() {
      _petName = 'Pip';
      _happiness = 50;
      _hunger = 50;

      _gameOver = false;
      _hasWon = false;
    });

    _nameController.clear();

    _startHungerTimer();
  }

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameFinished = _gameOver || _hasWon;

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet State Lab')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // PET IMAGE
              ColorFiltered(
                colorFilter: ColorFilter.mode(_moodColor, BlendMode.modulate),
                child: Image.asset(
                  'assets/pet.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              // PET NAME
              Text(
                _petName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // MOOD
              Text(
                'Mood: $_mood',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _moodColor,
                ),
              ),

              const SizedBox(height: 10),

              // PET MESSAGE
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              // PET NAME INPUT
              TextField(
                controller: _nameController,
                enabled: !gameFinished,
                decoration: const InputDecoration(
                  labelText: 'Enter pet name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _changePetName(),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: gameFinished ? null : _changePetName,
                child: const Text('Confirm Name'),
              ),

              const SizedBox(height: 28),

              // HAPPINESS
              Text(
                'Happiness: $_happiness',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(value: _happiness / 100),

              const SizedBox(height: 24),

              // HUNGER
              Text('Hunger: $_hunger', style: const TextStyle(fontSize: 18)),

              const SizedBox(height: 8),

              LinearProgressIndicator(value: _hunger / 100),

              const SizedBox(height: 32),

              // CARE BUTTONS
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: gameFinished ? null : _feedPet,
                    child: const Text('Feed'),
                  ),
                  ElevatedButton(
                    onPressed: gameFinished ? null : _playWithPet,
                    child: const Text('Play'),
                  ),
                  ElevatedButton(
                    onPressed: _resetPet,
                    child: const Text('Reset'),
                  ),
                ],
              ),

              // WIN MESSAGE
              if (_hasWon) ...[
                const SizedBox(height: 24),
                const Text(
                  '🏆 YOU WIN! 🏆',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],

              // GAME OVER MESSAGE
              if (_gameOver) ...[
                const SizedBox(height: 24),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
