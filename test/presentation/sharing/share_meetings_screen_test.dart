import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/data/services/meeting_package_service.dart';
import 'package:friendsheet/presentation/sharing/share_meetings_provider.dart';
import 'package:friendsheet/presentation/sharing/share_meetings_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'share_meetings_screen_test.mocks.dart';

@GenerateMocks([
  MeetingRepository,
  PersonRepository,
  ActivityCategoryRepository,
  AuthService,
  MeetingPackageService,
])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;
  late MockAuthService mockAuthService;
  late MockMeetingPackageService mockPackageService;

  setUp(() {
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
    mockAuthService = MockAuthService();
    mockPackageService = MockMeetingPackageService();
  });

  final targetPerson = Person(
    id: 'target-id',
    userId: 'u1',
    firstName: 'Anna',
    createdAt: DateTime(2026),
    nicknames: const [],
  );

  final testMeeting = Meeting(
    id: 'm1',
    userId: 'u1',
    name: 'Coffee',
    date: DateTime(2026, 3, 1),
    weight: 3,
    participantIds: const ['target-id'],
    createdAt: DateTime(2026, 3, 1),
    updatedAt: DateTime(2026, 3, 1),
  );

  Future<Widget> buildScreen(List<Meeting> meetings) async {
    when(mockAuthService.currentUserId).thenReturn('u1');
    when(mockAuthService.userDisplayName).thenReturn(null);
    when(mockMeetingRepo.getMeetingsByParticipant(any, any))
        .thenAnswer((_) async => meetings);
    when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
    when(mockCategoryRepo.getCategories(any))
        .thenAnswer((_) => Stream.value([]));

    final provider = ShareMeetingsProvider(
      meetingRepository: mockMeetingRepo,
      personRepository: mockPersonRepo,
      categoryRepository: mockCategoryRepo,
      authService: mockAuthService,
      meetingPackageService: mockPackageService,
      targetPersonId: 'target-id',
      recipientUid: 'uid-c',
    );

    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        home: ShareMeetingsScreen(person: targetPerson),
      ),
    );
  }

  group('toggles position', () {
    testWidgets('include-options toggles appear above the meeting list',
        (tester) async {
      await tester.pumpWidget(await buildScreen([testMeeting]));
      await tester.pumpAndSettle();

      // SwitchListTile belongs to _OptionsCard; CheckboxListTile 'Coffee' is a meeting row.
      final toggleY = tester
          .getTopLeft(
              find.widgetWithText(SwitchListTile, 'Include other participants'))
          .dy;
      final meetingY =
          tester.getTopLeft(find.widgetWithText(CheckboxListTile, 'Coffee')).dy;

      expect(toggleY, lessThan(meetingY));
    });
  });
}
