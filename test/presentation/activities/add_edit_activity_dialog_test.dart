import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/presentation/activities/activities_list_provider.dart';
import 'package:friendsheet/presentation/activities/add_edit_activity_dialog.dart';
import 'package:provider/provider.dart';

import '../../helpers/firebase_test_helpers.dart';

void main() {
  setUpAll(() async {
    // Firebase Core mock required: AuthService() accesses FirebaseAuth.instance
    // at field init time when the singleton is created.
    await setupTestFirebase();
  });

  final existingCategory = ActivityCategory(
    id: 'cat-1',
    userId: 'u1',
    name: 'Tennis',
    iconIdentifier: 'sports_tennis',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: null,
    createdAt: DateTime(2026, 1, 1),
  );

  Widget buildDialog({
    ActivityCategory? initialCategory,
    required bool nameExistsResult,
    List<ActivityCategory> availableParents = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<ActivitiesListProvider>.value(
          value: _StubActivitiesListProvider(
            nameExistsResult: nameExistsResult,
          ),
          child: Builder(
            builder: (context) => AddEditActivityDialog(
              initialCategory: initialCategory,
              availableParents: availableParents,
            ),
          ),
        ),
      ),
    );
  }

  group('AddEditActivityDialog duplicate validation', () {
    testWidgets('Add mode: duplicate name shows error message', (tester) async {
      await tester.pumpWidget(
        buildDialog(initialCategory: null, nameExistsResult: true),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Tennis');
      await tester.tap(find.text('SAVE'));
      await tester.pump();

      expect(
        find.text('Activity with this name already exists'),
        findsOneWidget,
      );
    });

    testWidgets('Edit mode: duplicate name shows error message',
        (tester) async {
      await tester.pumpWidget(
        buildDialog(initialCategory: existingCategory, nameExistsResult: true),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Basketball');
      await tester.tap(find.text('SAVE'));
      await tester.pump();

      expect(
        find.text('Activity with this name already exists'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Edit mode: own name does not show duplicate error (excludeId works)',
        (tester) async {
      // nameExistsResult: false simulates excludeId correctly excluding self.
      await tester.pumpWidget(
        buildDialog(initialCategory: existingCategory, nameExistsResult: false),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Tennis');
      await tester.tap(find.text('SAVE'));
      await tester.pump();

      expect(
        find.text('Activity with this name already exists'),
        findsNothing,
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Stub provider — extends ActivitiesListProvider so Consumer resolves
// correctly. Overrides activityNameExists to return a controlled value.
// addCategory and updateCategory are no-ops so no Firestore calls are made.
// ---------------------------------------------------------------------------

class _StubActivitiesListProvider extends ActivitiesListProvider {
  final bool nameExistsResult;

  _StubActivitiesListProvider({required this.nameExistsResult})
      : super(
          repository: ActivityCategoryRepository(
            firestore: FakeFirebaseFirestore(),
          ),
          meetingRepository: MeetingRepository(
            firestore: FakeFirebaseFirestore(),
          ),
        );

  @override
  bool activityNameExists(String name, {String? excludeId}) => nameExistsResult;

  @override
  Future<void> addCategory(
    String userId,
    String name,
    String iconIdentifier,
    String? parentCategoryId,
  ) async {}

  @override
  Future<void> updateCategory(
    String userId,
    String categoryId,
    String name,
    String iconIdentifier,
    String? parentCategoryId,
  ) async {}
}
