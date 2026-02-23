import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/persons/persons_list_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'persons_list_provider_test.mocks.dart';

@GenerateMocks([PersonRepository, AuthService])
void main() {
  late MockPersonRepository mockPersonRepository;
  late MockAuthService mockAuthService;
  late PersonsListProvider provider;

  final testPersons = [
    Person(
      id: 'p1',
      userId: 'u1',
      firstName: 'Zofia',
      lastName: 'Nowak',
      createdAt: DateTime(2026, 1, 1),
    ),
    Person(
      id: 'p2',
      userId: 'u1',
      firstName: 'Anna',
      lastName: 'Kowalska',
      createdAt: DateTime(2026, 1, 2),
    ),
    Person(
      id: 'p3',
      userId: 'u1',
      firstName: 'Bartosz',
      lastName: null,
      createdAt: DateTime(2026, 1, 3),
    ),
  ];

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockAuthService = MockAuthService();
    when(mockAuthService.currentUserId).thenReturn('u1');
    provider = PersonsListProvider(
      personRepository: mockPersonRepository,
      authService: mockAuthService,
    );
  });

  group('PersonsListProvider', () {
    test('initialize loads persons and clears isLoading', () async {
      when(mockPersonRepository.getPersonsByUser('u1'))
          .thenAnswer((_) async => testPersons);

      await provider.initialize();

      expect(provider.isLoading, isFalse);
      expect(provider.persons.length, equals(3));
      expect(provider.errorMessage, isNull);
    });

    test('persons returns alphabetically sorted list', () async {
      when(mockPersonRepository.getPersonsByUser('u1'))
          .thenAnswer((_) async => testPersons);

      await provider.initialize();

      final names = provider.persons.map((p) => p.firstName).toList();
      expect(names, equals(['Anna', 'Bartosz', 'Zofia']));
    });

    test('setSearchQuery filters by name (case-insensitive, partial match)',
        () async {
      when(mockPersonRepository.getPersonsByUser('u1'))
          .thenAnswer((_) async => testPersons);

      await provider.initialize();
      provider.setSearchQuery('anna');

      expect(provider.persons.length, equals(1));
      expect(provider.persons.first.firstName, equals('Anna'));
    });

    test('setSearchQuery with empty string returns full list', () async {
      when(mockPersonRepository.getPersonsByUser('u1'))
          .thenAnswer((_) async => testPersons);

      await provider.initialize();
      provider.setSearchQuery('zofia');
      provider.setSearchQuery('');

      expect(provider.persons.length, equals(3));
    });

    test('initialize sets errorMessage on exception', () async {
      when(mockPersonRepository.getPersonsByUser('u1'))
          .thenThrow(Exception('network error'));

      await provider.initialize();

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });
}
