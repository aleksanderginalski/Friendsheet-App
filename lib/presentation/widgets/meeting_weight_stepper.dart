// lib/presentation/widgets/meeting_weight_stepper.dart

import 'package:flutter/material.dart';

/// A stepper widget for selecting meeting weight using Fibonacci values.
/// Displays current value with increment/decrement buttons.
/// Buttons are disabled at min (1) and max (21) boundaries.
class MeetingWeightStepper extends StatelessWidget {
  final int value;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const MeetingWeightStepper({
    super.key,
    required this.value,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: canDecrement ? onDecrement : null,
        ),
        SizedBox(
          width: 64,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: canIncrement ? onIncrement : null,
        ),
      ],
    );
  }
}
