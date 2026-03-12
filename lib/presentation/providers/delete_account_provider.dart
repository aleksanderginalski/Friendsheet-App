// lib/presentation/providers/delete_account_provider.dart

import 'package:flutter/material.dart';

import '../../data/services/account_deletion_service.dart';
import '../../data/services/auth_service.dart';
import '../../main.dart' show appNavigatorKey;
import '../screens/login_screen.dart';

/// Manages the delete-account flow: delegates to [AccountDeletionService],
/// exposes loading/error state, and navigates to [LoginScreen] on success.
class DeleteAccountProvider extends ChangeNotifier {
  DeleteAccountProvider({required AccountDeletionService deletionService})
      : _deletionService = deletionService;

  final AccountDeletionService _deletionService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Deletes the account identified by [uid].
  /// No-op if a deletion is already in progress.
  /// Navigates to [LoginScreen] (clearing the back-stack) on success.
  /// Sets [errorMessage] on failure so the caller can show an error and retry.
  Future<void> deleteAccount(String uid) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deletionService.deleteAccount(uid);

      // Use appNavigatorKey so navigation succeeds even if this widget is
      // already unmounted by the time the async operation completes.
      // AuthService singleton is safe to access here — it outlives any widget.
      appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(authService: AuthService()),
        ),
        (_) => false,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the stored error message after the UI has consumed it.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
