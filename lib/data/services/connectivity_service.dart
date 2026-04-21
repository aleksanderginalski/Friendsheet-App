import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Singleton service that tracks network connectivity state.
///
/// Exposes [isOnlineNotifier] so widgets can react to connectivity changes
/// without polling. Call [initialize] once from MainScreen.initState().
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOnline => isOnlineNotifier.value;

  /// Checks current connectivity and subscribes to changes.
  /// Safe to call multiple times — cancels the previous subscription first.
  Future<void> initialize() async {
    _subscription?.cancel();

    final results = await Connectivity().checkConnectivity();
    isOnlineNotifier.value = _isOnline(results);

    _subscription = Connectivity().onConnectivityChanged.listen(
      (results) {
        isOnlineNotifier.value = _isOnline(results);
      },
    );
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.every((r) => r == ConnectivityResult.none);

  void dispose() {
    _subscription?.cancel();
    isOnlineNotifier.dispose();
  }
}
