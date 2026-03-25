import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/ai_consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AIConsentRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = AIConsentRepository();
  });

  group('hasGrantedConsent', () {
    test('returns false when no consent has been stored', () async {
      expect(await repository.hasGrantedConsent(), isFalse);
    });
  });

  group('grantConsent', () {
    test('persists consent so hasGrantedConsent returns true', () async {
      await repository.grantConsent();
      expect(await repository.hasGrantedConsent(), isTrue);
    });
  });
}
