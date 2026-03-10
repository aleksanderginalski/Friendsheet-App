import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../providers/meeting_inbox_provider.dart';
import '../screens/main_screen.dart';

/// Shown when all ImportCandidates have been processed.
/// Navigates back to MainScreen and clears the inbox state.
class ImportSuccessScreen extends StatelessWidget {
  const ImportSuccessScreen({super.key, required this.confirmedCount});

  final int confirmedCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 96,
                ),
                const SizedBox(height: 24),
                Text(
                  'Import complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You added $confirmedCount '
                  'meeting${confirmedCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _goToMeetings(context),
                  child: const Text('GO TO MEETINGS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToMeetings(BuildContext context) {
    context.read<MeetingInboxProvider>().clear();
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MainScreen(authService: AuthService()),
      ),
      (_) => false,
    );
  }
}
