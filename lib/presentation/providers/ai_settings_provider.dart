import 'package:flutter/foundation.dart';

import '../../data/repositories/ai_key_repository.dart';

/// Manages state for the AI Settings screen.
/// Handles key validation, masked display, and secure storage via [AIKeyRepository].
class AISettingsProvider extends ChangeNotifier {
  AISettingsProvider({required AIKeyRepository repository})
      : _repository = repository;

  final AIKeyRepository _repository;

  bool _isLoading = false;
  String? _maskedKey;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get maskedKey => _maskedKey;
  String? get errorMessage => _errorMessage;

  /// Loads the stored key and updates [maskedKey] if one exists.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final key = await _repository.loadKey();
    _maskedKey = key != null ? _mask(key) : null;

    _isLoading = false;
    notifyListeners();
  }

  /// Validates [rawKey], saves it, and updates [maskedKey].
  /// Sets [errorMessage] if the key does not start with 'sk-'.
  Future<void> saveKey(String rawKey) async {
    if (!rawKey.startsWith('sk-')) {
      _errorMessage = 'Key must start with "sk-"';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.saveKey(rawKey);
      _maskedKey = _mask(rawKey);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes the stored key and clears [maskedKey].
  Future<void> deleteKey() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteKey();
      _maskedKey = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current [errorMessage].
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // Returns a masked representation showing only the last 4 characters.
  String _mask(String key) {
    final suffix = key.length >= 4 ? key.substring(key.length - 4) : key;
    return '••••••••$suffix';
  }
}
