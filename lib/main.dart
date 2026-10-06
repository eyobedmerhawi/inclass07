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
  bool _isPaused = false;

  bool _petPulse = false;

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

    if (_isPaused) {
      return 'Session paused.';
    }

    if (_hunger > 80) {
      return '$_petName is very hungry!';
    }

    if (_happiness <= 30) {
      return '$_petName wants to play!';
    }

    return 'Hi, I\'m $_petName!';
  }

  void _animatePet() {
    if (!mounted) {
      return;
    }

    setState(() {
      _petPulse = !_petPulse;
    });
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    if (_isPaused || _gameOver || _hasWon) {
      return;
    }

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _isPaused || _gameOver || _hasWon) {
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

      _animatePet();
      _updateOutcome();
    });
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon || _isPaused) {
      return;
    }

    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;

      _hungerTimer?.cancel();
      _hungerTimer = null;

      setState(() {
        _gameOver = true;
      });

      return;
    }

    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;

      if (!mounted || _gameOver || _isPaused || _happiness <= 80) {
        return;
      }

      setState(() {
        _hasWon = true;
      });

      _hungerTimer?.cancel();
      _hungerTimer = null;
    });
  }

  void _changePetName() {
    if (_isPaused || _gameOver || _hasWon) {
      return;
    }

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
    if (_isPaused || _gameOver || _hasWon) {
      return;
    }

    final nextHunger = _clampMeter(_hunger - 10);
    final happinessChange = nextHunger < 30 ? -20 : 10;

    final nextHappiness = _clampMeter(_happiness + happinessChange);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
    });

    _animatePet();
    _updateOutcome();
  }

  void _playWithPet() {
    if (_isPaused || _gameOver || _hasWon) {
      return;
    }

    setState(() {
      _happiness = _clampMeter(_happiness + 10);
      _hunger = _clampMeter(_hunger + 5);
    });

    _animatePet();
    _updateOutcome();
  }

  void _pauseSession() {
    if (_gameOver || _hasWon || _isPaused) {
      return;
    }

    _hungerTimer?.cancel();
    _hungerTimer = null;

    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _isPaused = true;
    });
  }

  void _resumeSession() {
    if (_gameOver || _hasWon || !_isPaused) {
      return;
    }

    setState(() {
      _isPaused = false;
    });

    _startHungerTimer();
    _updateOutcome();
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    _hungerTimer?.cancel();
    _hungerTimer = null;

    setState(() {
      _petName = 'Pip';
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
      _isPaused = false;
      _petPulse = false;
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
    final controlsDisabled = gameFinished || _isPaused;

    // Respect the user's system accessibility preference.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 350);

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet State Lab')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // VISUAL EFFECT #1:
              // Pet gently changes size when its state changes.
              AnimatedScale(
                scale: reduceMotion ? 1.0 : (_petPulse ? 1.06 : 1.0),
                duration: animationDuration,
                curve: Curves.easeInOut,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(_moodColor, BlendMode.modulate),
                  child: Image.asset(
                    'assets/pet.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _petName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Mood: $_mood',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _moodColor,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _nameController,
                enabled: !controlsDisabled,
                decoration: const InputDecoration(
                  labelText: 'Enter pet name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _changePetName(),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: controlsDisabled ? null : _changePetName,
                child: const Text('Confirm Name'),
              ),

              const SizedBox(height: 28),

              Text(
                'Happiness: $_happiness',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 8),

              // VISUAL EFFECT #2:
              // Smoothly animate the happiness meter.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _happiness / 100),
                duration: animationDuration,
                builder: (context, value, child) {
                  return LinearProgressIndicator(value: value);
                },
              ),

              const SizedBox(height: 24),

              Text('Hunger: $_hunger', style: const TextStyle(fontSize: 18)),

              const SizedBox(height: 8),

              // VISUAL EFFECT #2:
              // Smoothly animate the hunger meter.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _hunger / 100),
                duration: animationDuration,
                builder: (context, value, child) {
                  return LinearProgressIndicator(value: value);
                },
              ),

              const SizedBox(height: 32),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: controlsDisabled ? null : _feedPet,
                    child: const Text('Feed'),
                  ),
                  ElevatedButton(
                    onPressed: controlsDisabled ? null : _playWithPet,
                    child: const Text('Play'),
                  ),
                  ElevatedButton(
                    onPressed: _resetPet,
                    child: const Text('Reset'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: gameFinished
                    ? null
                    : (_isPaused ? _resumeSession : _pauseSession),
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(_isPaused ? 'Resume' : 'Pause'),
              ),

              if (_hasWon) ...[
                const SizedBox(height: 24),
                const Text(
                  '🏆 YOU WIN! 🏆',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],

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
