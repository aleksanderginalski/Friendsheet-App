import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/google_calendar.dart';
import '../../l10n/app_localizations.dart';
import '../providers/calendar_settings_provider.dart';

/// Screen that explains calendar access and triggers the OAuth grant flow.
///
/// [onConnected] is called with the fetched calendars after a successful
/// OAuth grant. When null, the screen simply pops on success.
class CalendarPermissionScreen extends StatefulWidget {
  final void Function(List<GoogleCalendar> calendars)? onConnected;

  const CalendarPermissionScreen({super.key, this.onConnected});

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

    // Capture provider reference before await — context must not be used
    // after the widget is potentially deactivated by onConnected navigation.
    final provider = context.read<CalendarSettingsProvider>();

    try {
      final calendars = await provider.connectCalendar();
      if (!mounted) return;
      if (widget.onConnected != null) {
        widget.onConnected!(calendars);
      } else {
        Navigator.of(context).pop();
      }
    } on CalendarAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.calendarPermissionError;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.calendarPermissionTitle,
          style: const TextStyle(color: Colors.white),
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
              Text(
                l10n.calendarPermissionHeading,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.calendarPermissionDescription,
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
                child: Text(l10n.calendarPermissionConnectButton),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.calendarPermissionNotNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
