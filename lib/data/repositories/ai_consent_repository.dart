import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's AI consent decision in SharedPreferences.
/// Consent is stored on-device only — cleared on app uninstall/data wipe.
class AIConsentRepository {
  // Key used to store the consent flag in SharedPreferences.
  static const _consentKey = 'ai_consent_granted';

  /// Returns true if the user has previously granted AI consent.
  Future<bool> hasGrantedConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Persists consent as granted. Subsequent calls to [hasGrantedConsent]
  /// will return true until the app data is cleared.
  Future<void> grantConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
  }
}
