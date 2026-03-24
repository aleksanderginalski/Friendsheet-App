import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/ai_key_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ai_key_repository_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late AIKeyRepository repository;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    repository = AIKeyRepository(storage: mockStorage);
  });

  group('saveKey', () {
    test('writes key to secure storage under openai_api_key', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      await repository.saveKey('sk-abc1234');

      verify(mockStorage.write(
        key: 'openai_api_key',
        value: 'sk-abc1234',
      )).called(1);
    });
  });

  group('loadKey', () {
    test('returns null when no key is stored', () async {
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      final result = await repository.loadKey();

      expect(result, isNull);
    });

    test('returns stored key value', () async {
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'sk-abc1234');

      final result = await repository.loadKey();

      expect(result, 'sk-abc1234');
    });
  });

  group('deleteKey', () {
    test('deletes key from secure storage under openai_api_key', () async {
      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

      await repository.deleteKey();

      verify(mockStorage.delete(key: 'openai_api_key')).called(1);
    });
  });
}
