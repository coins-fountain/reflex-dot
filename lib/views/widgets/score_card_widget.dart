import 'package:flutter/material.dart';

class ScoreCardWidget extends StatelessWidget {
  final String label;
  final int score;

  const ScoreCardWidget({super.key, required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
