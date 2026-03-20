import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/presentation/activities/activities_list_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'activities_list_provider_test.mocks.dart';

@GenerateMocks([ActivityCategoryRepository])
void main() {
  late MockActivityCategoryRepository mockRepository;
  late ActivitiesListProvider provider;

  // Flat list: two root categories and two children.
  final rootA = ActivityCategory(
    id: 'root-a',
    userId: 'u1',
    name: 'Sports',
    iconIdentifier: 'sports_tennis',
    isGlobal: false,
    isSelectableAsActivity: false,
    parentCategoryId: null,
    createdAt: DateTime(2026, 1, 1),
  );
  final rootB = ActivityCategory(
    id: 'root-b',
    userId: 'u1',
    name: 'Food',
    iconIdentifier: 'restaurant',
    isGlobal: false,
    isSelectableAsActivity: false,
    parentCategoryId: null,
    createdAt: DateTime(2026, 1, 2),
  );
  final childA1 = ActivityCategory(
    id: 'child-a1',
    userId: 'u1',
    name: 'Tennis',
    iconIdentifier: 'sports_tennis',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: 'root-a',
    createdAt: DateTime(2026, 1, 3),
  );
  final childA2 = ActivityCategory(
    id: 'child-a2',
    userId: 'u1',
    name: 'Basketball',
    iconIdentifier: 'sports_basketball',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: 'root-a',
    createdAt: DateTime(2026, 1, 4),
  );

  final flatList = [rootA, rootB, childA1, childA2];

  setUp(() {
    mockRepository = MockActivityCategoryRepository();
    provider = ActivitiesListProvider(repository: mockRepository);
  });

  group('ActivitiesListProvider', () {
    test('initialize loads root categories sorted alphabetically', () async {
      when(mockRepository.getAllCategories('u1'))
          .thenAnswer((_) async => flatList);

      await provider.initialize('u1');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.rootCategories.length, equals(2));
      expect(
        provider.rootCategories.every((c) => c.parentCategoryId == null),
        isTrue,
      );
      expect(
        provider.rootCategories.map((c) => c.name).toList(),
        equals(['Food', 'Sports']),
      );
    });

    test('childrenOf returns children for known parentId, empty for unknown',
        () async {
      when(mockRepository.getAllCategories('u1'))
          .thenAnswer((_) async => flatList);

      await provider.initialize('u1');

      final children = provider.childrenOf('root-a');
      expect(children.length, equals(2));
      expect(children.every((c) => c.parentCategoryId == 'root-a'), isTrue);
      expect(provider.childrenOf('nonexistent'), isEmpty);
    });

    test('toggleExpanded returns true after first toggle, false after second',
        () async {
      when(mockRepository.getAllCategories('u1'))
          .thenAnswer((_) async => flatList);

      await provider.initialize('u1');

      expect(provider.isExpanded('root-a'), isFalse);
      provider.toggleExpanded('root-a');
      expect(provider.isExpanded('root-a'), isTrue);
      provider.toggleExpanded('root-a');
      expect(provider.isExpanded('root-a'), isFalse);
    });

    test('setSearchQuery with non-empty value expands all root categories',
        () async {
      when(mockRepository.getAllCategories('u1'))
          .thenAnswer((_) async => flatList);

      await provider.initialize('u1');
      provider.setSearchQuery('sport');

      for (final root in provider.rootCategories) {
        expect(provider.isExpanded(root.id), isTrue);
      }
    });

    test('setSearchQuery cleared collapses all sections', () async {
      when(mockRepository.getAllCategories('u1'))
          .thenAnswer((_) async => flatList);

      await provider.initialize('u1');
      provider.setSearchQuery('sport');
      provider.setSearchQuery('');

      for (final root in provider.rootCategories) {
        expect(provider.isExpanded(root.id), isFalse);
      }
    });

    test('addCategory calls repository and re-initializes', () async {
      when(mockRepository.getAllCategories('u1'))
          .thenAnswer((_) async => flatList);
      when(mockRepository.addCategory(any)).thenAnswer((_) async {});

      await provider.addCategory('u1', 'Tennis', 'sports_tennis', 'root-a');

      verify(mockRepository.addCategory(any)).called(1);
      verify(mockRepository.getAllCategories('u1')).called(greaterThan(0));
    });

    test('deleteCategory calls deleteWithChildren on repository', () async {
      when(mockRepository.deleteWithChildren('u1', 'root-a'))
          .thenAnswer((_) async {});
      when(mockRepository.getAllCategories('u1'))
          .thenAnswer((_) async => flatList);

      await provider.deleteCategory('u1', 'root-a');

      verify(mockRepository.deleteWithChildren('u1', 'root-a')).called(1);
      verifyNever(mockRepository.deleteCategory(any, any));
    });

    test('initialize sets errorMessage on exception', () async {
      when(mockRepository.getAllCategories('u1'))
          .thenThrow(Exception('network error'));

      await provider.initialize('u1');

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    group('hasSearchResults', () {
      test('returns true when query is empty or matches any category',
          () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');

        // Empty query.
        expect(provider.hasSearchResults, isTrue);

        // Matches child (exact and partial).
        provider.setSearchQuery('Tennis');
        expect(provider.hasSearchResults, isTrue);
        provider.setSearchQuery('ball'); // matches Basketball
        expect(provider.hasSearchResults, isTrue);

        // Matches root category name.
        provider.setSearchQuery('Sports');
        expect(provider.hasSearchResults, isTrue);
      });

      test('returns false when query matches no child categories', () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');
        provider.setSearchQuery('zzznomatch');

        expect(provider.hasSearchResults, isFalse);
      });
    });

    group('activityNameExists', () {
      test('returns false when list is empty', () {
        expect(provider.activityNameExists('Kino'), isFalse);
      });

      test('returns false when no name matches', () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');

        expect(provider.activityNameExists('Cinema'), isFalse);
      });

      test('returns true case-insensitively and after trimming', () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');

        expect(provider.activityNameExists('Tennis'), isTrue);
        expect(provider.activityNameExists('tennis'), isTrue);
        expect(provider.activityNameExists('SPORTS'), isTrue);
        expect(provider.activityNameExists(' Tennis '), isTrue);
      });

      test('returns false when only match is excluded by excludeId', () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');

        // Editing 'Tennis' (child-a1) with the same name → should not report duplicate.
        expect(
          provider.activityNameExists('Tennis', excludeId: 'child-a1'),
          isFalse,
        );
      });

      test(
          'returns true when different activity has same name despite excludeId',
          () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');

        // Editing 'Basketball' (child-a2) but entering 'Tennis' → conflict.
        expect(
          provider.activityNameExists('Tennis', excludeId: 'child-a2'),
          isTrue,
        );
      });
    });

    group('filteredCategories', () {
      test('empty query returns all categories', () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');

        expect(provider.filteredCategories.length, equals(flatList.length));
      });

      test('query matching parent returns parent only, no children', () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');
        provider.setSearchQuery('Sports');

        final filtered = provider.filteredCategories;
        expect(filtered.length, equals(1));
        expect(filtered.first.id, equals('root-a'));
      });

      test('query matching child returns parent + only matching child',
          () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');
        provider.setSearchQuery('Tennis');

        final filtered = provider.filteredCategories;
        expect(filtered.length, equals(2));
        expect(filtered.any((c) => c.id == 'root-a'), isTrue);
        expect(filtered.any((c) => c.id == 'child-a1'), isTrue);
        expect(filtered.any((c) => c.id == 'child-a2'), isFalse);
      });

      test('query matching neither hides both parent and children', () async {
        when(mockRepository.getAllCategories('u1'))
            .thenAnswer((_) async => flatList);

        await provider.initialize('u1');
        provider.setSearchQuery('zzznomatch');

        expect(provider.filteredCategories, isEmpty);
      });
    });
  });
}
