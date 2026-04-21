import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/pending_meeting_package_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/import/package_activities_screen.dart';
import 'package:friendsheet/presentation/providers/shared_package_inbox_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package_activities_screen_test.mocks.dart';

@GenerateMocks([
  PendingMeetingPackageRepository,
  MeetingRepository,
  PersonRepository,
  ActivityCategoryRepository,
])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockPendingMeetingPackageRepository mockPackageRepo;
  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;

  final sportCategory = ActivityCategory(
    id: 'cat-sport',
    userId: 'u1',
    name: 'Sport',
    iconIdentifier: 'sports',
    isGlobal: false,
    isSelectableAsActivity: true,
    createdAt: DateTime(2026),
  );

  PendingMeetingPackage makePackage({List<String> categoryNames = const []}) =>
      PendingMeetingPackage(
        id: 'pkg1',
        senderUid: 'sender-uid',
        senderFirstName: 'Ania',
        senderLastName: 'Kowalska',
        sentAt: DateTime(2026, 3, 20),
        meetings: [
          SharedMeeting(
            name: 'Kino',
            date: DateTime(2026, 3, 21),
            weight: 3,
            categoryNames: categoryNames,
          ),
        ],
      );

  Future<SharedPackageInboxProvider> makeProvider({
    required PendingMeetingPackage pkg,
    List<ActivityCategory> existingCategories = const [],
  }) async {
    when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
    when(mockMeetingRepo.getMeetingsByUser('u1'))
        .thenAnswer((_) => Stream.value([]));
    when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
    when(mockCategoryRepo.getAllCategories(any))
        .thenAnswer((_) async => existingCategories);

    final provider = SharedPackageInboxProvider(
      packageRepository: mockPackageRepo,
      meetingRepository: mockMeetingRepo,
      personRepository: mockPersonRepo,
      categoryRepository: mockCategoryRepo,
    );
    await provider.initialize('u1');
    return provider;
  }

  Widget buildScreen(
    SharedPackageInboxProvider provider,
    PendingMeetingPackage pkg,
  ) =>
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PackageActivitiesScreen(package: pkg, userId: 'u1'),
        ),
      );

  setUp(() {
    mockPackageRepo = MockPendingMeetingPackageRepository();
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
  });

  group('conflict tile — Create as New disabled', () {
    testWidgets(
        'Create as New button is disabled when activity name exactly matches existing category',
        (tester) async {
      final pkg = makePackage(categoryNames: ['Sport']);
      final provider = await makeProvider(
        pkg: pkg,
        existingCategories: [sportCategory],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Create as New'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('disabled Create as New button shows tooltip with explanation',
        (tester) async {
      final pkg = makePackage(categoryNames: ['Sport']);
      final provider = await makeProvider(
        pkg: pkg,
        existingCategories: [sportCategory],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(
        find.byWidgetPredicate((w) =>
            w is Tooltip &&
            w.message ==
                'An activity with this name already exists. '
                    'Rename it or link to existing.'),
        findsOneWidget,
      );
    });
  });
}
