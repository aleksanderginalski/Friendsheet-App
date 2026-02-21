import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import 'home_screen.dart';
import 'meetings_list_screen.dart';

/// Main screen with bottom navigation, hosting all top-level tabs.
class MainScreen extends StatefulWidget {
  final AuthService authService;

  const MainScreen({super.key, required this.authService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out?\n\n'
          'You\'ll need to sign in again to access your meetings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );

    // AuthWrapper stream automatically navigates to LoginScreen after sign-out.
    if (confirmed == true && context.mounted) {
      try {
        await widget.authService.signOut();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FRIENDSHEET'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      // IndexedStack keeps all tab widgets alive, preserving scroll state.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(authService: widget.authService),
          const MeetingsListScreen(),
          const Scaffold(
            body: Center(child: Text('Persons - Coming Soon')),
          ),
          const Scaffold(
            body: Center(child: Text('Activities - Coming Soon')),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4CAF50),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Persons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Activities',
          ),
        ],
      ),
    );
  }
}