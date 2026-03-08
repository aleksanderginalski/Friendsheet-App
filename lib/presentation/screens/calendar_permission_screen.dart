import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/google_calendar.dart';
import '../providers/calendar_settings_provider.dart';

/// Screen that explains calendar access and triggers the OAuth grant flow.
class CalendarPermissionScreen extends StatefulWidget {
  const CalendarPermissionScreen({super.key});

  @override
  State<CalendarPermissionScreen> createState() =>
      _CalendarPermissionScreenState();
}

class _CalendarPermissionScreenState extends State<CalendarPermissionScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleConnect() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<CalendarSettingsProvider>().connectCalendar();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on CalendarAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred';
          _isLoading = false;
        });
      }
    }
  }

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_month,
                size: 64,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connect Google Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Friendsheet needs read-only access to your Google Calendar '
                'to import past events as meetings. No data is stored — '
                'only event titles, dates, and attendee names are used.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              if (_isLoading) const CircularProgressIndicator(),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleConnect,
                child: const Text('Connect Google Calendar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
