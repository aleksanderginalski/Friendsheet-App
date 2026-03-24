import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the user's OpenAI API key in Flutter Secure Storage.
/// The key is stored on-device only — never written to Firestore, logs,
/// or any external service.
class AIKeyRepository {
  AIKeyRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // Storage key for the OpenAI API key.
  static const _apiKeyStorageKey = 'openai_api_key';

  /// Writes [key] to secure storage. Overwrites any existing value.
  Future<void> saveKey(String key) async {
    await _storage.write(key: _apiKeyStorageKey, value: key);
  }

  /// Returns the stored key, or null if no key has been saved.
  Future<String?> loadKey() async {
    return _storage.read(key: _apiKeyStorageKey);
  }

  /// Removes the stored key from secure storage.
  Future<void> deleteKey() async {
    await _storage.delete(key: _apiKeyStorageKey);
  }
}
