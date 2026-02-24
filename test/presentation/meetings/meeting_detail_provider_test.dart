import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/activity_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/meetings/meeting_detail_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'meeting_detail_provider_test.mocks.dart';

@GenerateMocks(
    [PersonRepository, ActivityRepository, ActivityCategoryRepository])
void main() {
  late MockPersonRepository mockPersonRepository;
  late MockActivityRepository mockActivityRepository;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MeetingDetailProvider provider;

  final testMeeting = Meeting(
    id: 'm1',
    userId: 'u1',
    name: 'Coffee with Anna',
    date: DateTime(2026, 2, 12),
    weight: 8,
    participantIds: ['p1'],
    activityIds: ['a1'],
    createdAt: DateTime(2026, 2, 12),
    updatedAt: DateTime(2026, 2, 12),
  );

  final testMeetingWithCategories = Meeting(
    id: 'm2',
    userId: 'u1',
    name: 'Hiking',
    date: DateTime(2026, 2, 12),
    weight: 5,
    participantIds: ['p1'],
    activityIds: ['a1'],
    categoryIds: ['cat-gory', 'cat-sport'],
    createdAt: DateTime(2026, 2, 12),
    updatedAt: DateTime(2026, 2, 12),
  );

  final testPerson = Person(
    id: 'p1',
    userId: 'u1',
    firstName: 'Anna',
    lastName: 'Kowalska',
    createdAt: DateTime(2026, 2, 12),
  );

  final testActivity = Activity(
    id: 'a1',
    userId: 'u1',
    name: 'Coffee',
    isGlobal: false,
    createdAt: DateTime(2026, 2, 12),
  );

  final leafCategory = ActivityCategory(
    id: 'cat-gory',
    userId: 'u1',
    name: 'Gory',
    iconIdentifier: 'mountain',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: 'cat-sport',
    createdAt: DateTime(2026, 2, 12),
  );

  final parentCategory = ActivityCategory(
    id: 'cat-sport',
    userId: 'u1',
    name: 'Sport',
    iconIdentifier: 'sports',
    isGlobal: false,
    isSelectableAsActivity: false,
    parentCategoryId: null,
    createdAt: DateTime(2026, 2, 12),
  );

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockActivityRepository = MockActivityRepository();
    mockCategoryRepository = MockActivityCategoryRepository();
    provider = MeetingDetailProvider(
      personRepository: mockPersonRepository,
      activityRepository: mockActivityRepository,
      categoryRepository: mockCategoryRepository,
    );

    // Default stub: no categories
    when(mockCategoryRepository.getCategoriesByIds(any, any))
        .thenAnswer((_) async => []);
  });

  group('MeetingDetailProvider', () {
    test('initialize loads participants and activities', () async {
      when(mockPersonRepository.getPersonsByIds(['p1']))
          .thenAnswer((_) async => [testPerson]);
      when(mockActivityRepository.getActivitiesByIds(['a1']))
          .thenAnswer((_) async => [testActivity]);

      await provider.initialize(testMeeting);

      expect(provider.participants, [testPerson]);
      expect(provider.activities, [testActivity]);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
    });

    test('initialize sets errorMessage on failure', () async {
      when(mockPersonRepository.getPersonsByIds(any))
          .thenThrow(Exception('network error'));
      when(mockActivityRepository.getActivitiesByIds(any))
          .thenAnswer((_) async => []);

      await provider.initialize(testMeeting);

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, false);
    });

    test(
        'initialize returns empty lists when meeting has no participants or activities',
        () async {
      final emptyMeeting = testMeeting.copyWith(
        participantIds: [],
        activityIds: [],
      );

      when(mockPersonRepository.getPersonsByIds([]))
          .thenAnswer((_) async => []);
      when(mockActivityRepository.getActivitiesByIds([]))
          .thenAnswer((_) async => []);

      await provider.initialize(emptyMeeting);

      expect(provider.participants, isEmpty);
      expect(provider.activities, isEmpty);
    });

    test('initialize resolves categoryIds and filters to leaf nodes', () async {
      when(mockPersonRepository.getPersonsByIds(['p1']))
          .thenAnswer((_) async => [testPerson]);
      when(mockActivityRepository.getActivitiesByIds(['a1']))
          .thenAnswer((_) async => [testActivity]);
      when(mockCategoryRepository.getCategoriesByIds(
        ['cat-gory', 'cat-sport'],
        'u1',
      )).thenAnswer((_) async => [leafCategory, parentCategory]);

      await provider.initialize(testMeetingWithCategories);

      // Only the leaf (Gory) should be in categories; Sport is an ancestor.
      expect(provider.categories.length, equals(1));
      expect(provider.categories.first.name, equals('Gory'));
    });

    test('categories is empty when meeting has no categoryIds', () async {
      when(mockPersonRepository.getPersonsByIds(any))
          .thenAnswer((_) async => [testPerson]);
      when(mockActivityRepository.getActivitiesByIds(any))
          .thenAnswer((_) async => [testActivity]);

      await provider.initialize(testMeeting);

      expect(provider.categories, isEmpty);
    });
  });
}
