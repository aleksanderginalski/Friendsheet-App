import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/pending_meeting_package_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/import/package_persons_screen.dart';
import 'package:friendsheet/presentation/providers/shared_package_inbox_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package_persons_screen_test.mocks.dart';

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

  PendingMeetingPackage makePackage({
    String? senderNickname,
    List<SharedPerson> participants = const [],
  }) =>
      PendingMeetingPackage(
        id: 'pkg1',
        senderUid: 'sender-uid',
        senderFirstName: 'Ania',
        senderLastName: 'Kowalska',
        senderNickname: senderNickname,
        sentAt: DateTime(2026, 3, 20),
        meetings: [
          SharedMeeting(
            name: 'Kino',
            date: DateTime(2026, 3, 21),
            weight: 3,
            participants: participants,
          ),
        ],
      );

  Person makeExistingPerson(
          {String firstName = 'Ania', String lastName = 'Kowalska'}) =>
      Person(
        id: 'p-existing',
        userId: 'u1',
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime(2026),
        nicknames: const [],
      );

  Future<SharedPackageInboxProvider> makeProvider({
    required PendingMeetingPackage pkg,
    List<Person> existingPersons = const [],
  }) async {
    when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
    when(mockMeetingRepo.getMeetingsByUser('u1'))
        .thenAnswer((_) => Stream.value([]));
    when(mockPersonRepo.getPersonsByUser(any))
        .thenAnswer((_) async => existingPersons);
    when(mockCategoryRepo.getAllCategories(any)).thenAnswer((_) async => []);

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
          home: PackagePersonsScreen(package: pkg, userId: 'u1'),
        ),
      );

  setUp(() {
    mockPackageRepo = MockPendingMeetingPackageRepository();
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
  });

  group('opt-in tile — sender nickname hint', () {
    testWidgets(
        'shows "Suggested nickname" text when sender has nickname and no conflict',
        (tester) async {
      final pkg = makePackage(senderNickname: 'Anka');
      final provider = await makeProvider(pkg: pkg);

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.text('Suggested nickname: Anka'), findsOneWidget);
    });

    testWidgets(
        'does not show "Suggested nickname" when sender has no nickname',
        (tester) async {
      final pkg = makePackage();
      final provider = await makeProvider(pkg: pkg);

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.textContaining('Suggested nickname'), findsNothing);
    });
  });

  group('conflict tile — sender nickname hint and pre-fill', () {
    testWidgets(
        'shows "Suggested nickname" hint and pre-fills field when conflict exists and sender has nickname',
        (tester) async {
      final pkg = makePackage(senderNickname: 'Anka');
      final provider = await makeProvider(
        pkg: pkg,
        existingPersons: [makeExistingPerson()],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      // Suggested nickname hint visible on conflict tile.
      expect(find.text('Suggested nickname: Anka'), findsOneWidget);

      // Tap "Add with Nickname" to reveal the text field.
      await tester.tap(find.text('Add with Nickname'));
      await tester.pump();

      // Field is pre-filled with sender's suggested nickname.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'Anka');
    });

    testWidgets(
        'does not show "Suggested nickname" hint when conflict exists but sender has no nickname',
        (tester) async {
      final pkg = makePackage();
      final provider = await makeProvider(
        pkg: pkg,
        existingPersons: [makeExistingPerson()],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.textContaining('Suggested nickname'), findsNothing);
    });
  });
}
