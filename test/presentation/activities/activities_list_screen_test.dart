import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/presentation/activities/activities_list_provider.dart';
import 'package:friendsheet/presentation/activities/activities_list_screen.dart';
import 'package:friendsheet/presentation/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Firebase Core mock required: ActivitiesListScreen.initState creates
    // AuthService(), which accesses FirebaseAuth.instance at field init.
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  final rootA = ActivityCategory(
    id: 'root-a',
    userId: 'u1',
    name: 'Sport',
    iconIdentifier: 'sport',
    isGlobal: false,
    isSelectableAsActivity: false,
    parentCategoryId: null,
    createdAt: DateTime(2026, 1, 1),
  );

  Widget buildScreen(_StubActivitiesListProvider stub) {
    return MaterialApp(
      home: ChangeNotifierProvider<ActivitiesListProvider>.value(
        value: stub,
        child: const ActivitiesListScreen(),
      ),
    );
  }

  group('ActivitiesListScreen', () {
    testWidgets('shows EmptyStateWidget when categories list is empty',
        (tester) async {
      final stub = _StubActivitiesListProvider();

      await tester.pumpWidget(buildScreen(stub));
      await tester.pump();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(
        find.text('No activities yet — tap + to create your first category!'),
        findsOneWidget,
      );
    });

    testWidgets(
        'shows EmptyStateWidget with no-results message when search has no matches',
        (tester) async {
      final stub = _StubActivitiesListProvider(
        categories: [rootA],
        query: 'zzznomatch',
        hasSearchResults: false,
      );

      await tester.pumpWidget(buildScreen(stub));
      await tester.pump();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No activities found'), findsOneWidget);
    });

    testWidgets('does not show EmptyStateWidget when categories exist',
        (tester) async {
      final stub = _StubActivitiesListProvider(categories: [rootA]);

      await tester.pumpWidget(buildScreen(stub));
      await tester.pump();

      expect(find.byType(EmptyStateWidget), findsNothing);
    });

    testWidgets('shows category name in tree when categories exist',
        (tester) async {
      final stub = _StubActivitiesListProvider(categories: [rootA]);

      await tester.pumpWidget(buildScreen(stub));
      await tester.pump();

      expect(find.text('Sport'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Stub provider — extends ActivitiesListProvider so Consumer resolves
// correctly. State is fully controlled via constructor fields; no real
// Firebase calls are made (initialize is a no-op).
// ---------------------------------------------------------------------------

class _StubActivitiesListProvider extends ActivitiesListProvider {
  final List<ActivityCategory> _cats;
  final String _query;
  final bool _resultsExist;

  _StubActivitiesListProvider({
    List<ActivityCategory> categories = const [],
    String query = '',
    bool? hasSearchResults,
  })  : _cats = categories,
        _query = query,
        _resultsExist = hasSearchResults ?? query.isEmpty,
        super(
          repository: ActivityCategoryRepository(
            firestore: FakeFirebaseFirestore(),
          ),
        );

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  List<ActivityCategory> get rootCategories =>
      _cats.where((c) => c.parentCategoryId == null).toList();

  @override
  List<ActivityCategory> childrenOf(String parentId) =>
      _cats.where((c) => c.parentCategoryId == parentId).toList();

  @override
  bool isExpanded(String categoryId) => false;

  @override
  String get searchQuery => _query;

  @override
  bool get hasSearchResults => _resultsExist;

  @override
  Future<void> initialize(String userId) async {}
}
