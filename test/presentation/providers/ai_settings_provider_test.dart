import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/ai_key_repository.dart';
import 'package:friendsheet/presentation/providers/ai_settings_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ai_settings_provider_test.mocks.dart';

@GenerateMocks([AIKeyRepository])
void main() {
  late MockAIKeyRepository mockRepo;
  late AISettingsProvider provider;

  setUp(() {
    mockRepo = MockAIKeyRepository();
    provider = AISettingsProvider(repository: mockRepo);
  });

  group('initial state', () {
    test('all fields are at default values', () {
      expect(provider.isLoading, isFalse);
      expect(provider.maskedKey, isNull);
      expect(provider.errorMessage, isNull);
    });
  });

  group('initialize', () {
    test('maskedKey is null when no key is stored', () async {
      when(mockRepo.loadKey()).thenAnswer((_) async => null);

      await provider.initialize();

      expect(provider.maskedKey, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('maskedKey shows 8 bullets + last 4 chars when key exists', () async {
      when(mockRepo.loadKey()).thenAnswer((_) async => 'sk-abcdefgh1234');

      await provider.initialize();

      expect(provider.maskedKey, '••••••••1234');
    });
  });

  group('saveKey', () {
    test('sets errorMessage when key does not start with sk-', () async {
      await provider.saveKey('invalid-key');

      expect(provider.errorMessage, 'Key must start with "sk-"');
      expect(provider.maskedKey, isNull);
      verifyNever(mockRepo.saveKey(any));
    });

    test('saves key and updates maskedKey on valid key', () async {
      when(mockRepo.saveKey(any)).thenAnswer((_) async {});

      await provider.saveKey('sk-test1234');

      expect(provider.maskedKey, '••••••••1234');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
      verify(mockRepo.saveKey('sk-test1234')).called(1);
    });

    test('key shorter than 4 chars shows full suffix in mask', () async {
      when(mockRepo.saveKey(any)).thenAnswer((_) async {});

      await provider.saveKey('sk-x');

      expect(provider.maskedKey, '••••••••sk-x');
    });
  });

  group('deleteKey', () {
    test('clears maskedKey after deletion', () async {
      when(mockRepo.loadKey()).thenAnswer((_) async => 'sk-test1234');
      when(mockRepo.deleteKey()).thenAnswer((_) async {});
      await provider.initialize();

      await provider.deleteKey();

      expect(provider.maskedKey, isNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('clearError', () {
    test('clears errorMessage', () async {
      await provider.saveKey('bad-key');
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });

    test('does nothing when errorMessage is already null', () {
      expect(() => provider.clearError(), returnsNormally);
    });
  });
}
