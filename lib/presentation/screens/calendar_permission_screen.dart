import 'package:flutter/material.dart';

/// Stub screen for the calendar import flow.
class CalendarPermissionScreen extends StatelessWidget {
  const CalendarPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar Import',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Calendar import coming soon'),
      ),
    );
  }
}
