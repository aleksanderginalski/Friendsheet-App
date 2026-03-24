import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/pending_meeting_package_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/import/meeting_inbox_screen.dart';
import 'package:friendsheet/presentation/providers/meeting_inbox_provider.dart';
import 'package:friendsheet/presentation/providers/shared_package_inbox_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_inbox_screen_test.mocks.dart';

@GenerateMocks([
  PendingMeetingPackageRepository,
  MeetingRepository,
  PersonRepository,
  ActivityCategoryRepository,
])
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Firebase mock needed because AuthService singleton accesses
    // FirebaseAuth.instance in onDismissed callback.
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  late MockPendingMeetingPackageRepository mockPackageRepo;
  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;

  PendingMeetingPackage makePackage() => PendingMeetingPackage(
        id: 'pkg1',
        senderUid: 'sender-uid',
        senderFirstName: 'Ania',
        senderLastName: 'Kowalska',
        sentAt: DateTime(2026, 3, 20),
        meetings: [
          SharedMeeting(
            name: 'Kino',
            date: DateTime(2026, 3, 15),
            weight: 3,
          ),
        ],
      );

  Future<SharedPackageInboxProvider> makePackageProvider() async {
    when(mockPackageRepo.fetchPackages(any))
        .thenAnswer((_) async => [makePackage()]);
    when(mockMeetingRepo.getMeetingsByUser(any))
        .thenAnswer((_) => Stream.value([]));
    when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockPackageRepo = MockPendingMeetingPackageRepository();
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
  });

  Widget buildScreen(SharedPackageInboxProvider packageProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeetingInboxProvider()),
        ChangeNotifierProvider.value(value: packageProvider),
      ],
      child: const MaterialApp(home: MeetingInboxScreen()),
    );
  }

  group('swipe-to-delete package', () {
    testWidgets('shows confirmation dialog when package card is swiped left',
        (tester) async {
      final packageProvider = await makePackageProvider();
      await tester.pumpWidget(buildScreen(packageProvider));
      await tester.pumpAndSettle();

      await tester.fling(
        find.text('Ania Kowalska'),
        const Offset(-300, 0),
        800,
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete package?'), findsOneWidget);
      expect(
        find.text(
            'Are you sure you want to delete this package? It cannot be recovered.'),
        findsOneWidget,
      );
    });

    testWidgets('cancel closes dialog and keeps the package visible',
        (tester) async {
      final packageProvider = await makePackageProvider();
      await tester.pumpWidget(buildScreen(packageProvider));
      await tester.pumpAndSettle();

      await tester.fling(
        find.text('Ania Kowalska'),
        const Offset(-300, 0),
        800,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Ania Kowalska'), findsOneWidget);
      verifyNever(mockPackageRepo.deletePackage(any, any));
    });

    testWidgets('confirm deletes the package from Firestore and removes tile',
        (tester) async {
      when(mockPackageRepo.deletePackage(any, any)).thenAnswer((_) async {});
      final packageProvider = await makePackageProvider();
      await tester.pumpWidget(buildScreen(packageProvider));
      await tester.pumpAndSettle();

      await tester.fling(
        find.text('Ania Kowalska'),
        const Offset(-300, 0),
        800,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Ania Kowalska'), findsNothing);
      verify(mockPackageRepo.deletePackage(any, 'pkg1')).called(1);
    });
  });
}
