import 'package:flutter/material.dart';

class SecondaryButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SecondaryButtonWidget({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
