import 'dart:math';

import 'package:flutter/material.dart';

/// Simple number/letter learning game for students.
class LearningGameScreen extends StatefulWidget {
  const LearningGameScreen({super.key});

  @override
  State<LearningGameScreen> createState() => _LearningGameScreenState();
}

class _LearningGameScreenState extends State<LearningGameScreen> {
  final _rng = Random();
  late int _a;
  late int _b;
  late String _mode; // 'numbers' or 'alphabet'
  String _feedback = '';
  int _score = 0;
  String _input = '';

  @override
  void initState() {
    super.initState();
    _mode = 'numbers';
    _newChallenge();
  }

  void _newChallenge() {
    if (_mode == 'numbers') {
      _a = _rng.nextInt(10) + 1;
      _b = _rng.nextInt(10) + 1;
    } else {
      _a = _rng.nextInt(26); // letter index
      _b = 0;
    }
    _input = '';
    setState(() {});
  }

  void _checkAnswer() {
    if (_mode == 'numbers') {
      final expected = _a + _b;
      final guess = int.tryParse(_input.trim());
      if (guess == expected) {
        _score++;
        _feedback = 'Great job! $_a + $_b = $expected';
      } else {
        _feedback = 'Almost. Correct answer: $expected';
      }
    } else {
      final letter = String.fromCharCode(65 + _a); // A-Z
      if (_input.trim().toUpperCase() == letter) {
        _score++;
        _feedback = 'Yes! That is letter $letter';
      } else {
        _feedback = 'That was $letter. Keep practicing!';
      }
    }
    _newChallenge();
  }

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + _a);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.videogame_asset, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Learning Game',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'numbers', label: Text('Numbers')),
                    ButtonSegment(value: 'alphabet', label: Text('Alphabet')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (value) {
                    _mode = value.first;
                    _score = 0;
                    _feedback = '';
                    _newChallenge();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mode == 'numbers'
                          ? 'What is the sum?'
                          : 'Which letter is this?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _mode == 'numbers'
                            ? '$_a + $_b = ?'
                            : letter,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: ValueKey('input_$_mode'),
                      onChanged: (val) => _input = val,
                      keyboardType: _mode == 'numbers'
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Your answer',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _checkAnswer,
                        child: const Text('Check'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_feedback.isNotEmpty)
              Text(
                _feedback,
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            const SizedBox(height: 8),
            Text('Score: $_score', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
