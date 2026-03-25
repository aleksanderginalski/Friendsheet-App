import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/meetings/meeting_detail_provider.dart';
import 'package:friendsheet/presentation/meetings/meeting_notes_section.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'meeting_notes_section_test.mocks.dart';

@GenerateMocks(
    [PersonRepository, ActivityCategoryRepository, MeetingRepository])
void main() {
  late MockPersonRepository mockPersonRepository;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MeetingDetailProvider provider;

  final testMeeting = Meeting(
    id: 'm1',
    userId: 'u1',
    name: 'Coffee',
    date: DateTime(2026, 1, 1),
    weight: 3,
    participantIds: ['p1'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockMeetingRepository = MockMeetingRepository();
    provider = MeetingDetailProvider(
      personRepository: mockPersonRepository,
      categoryRepository: mockCategoryRepository,
      meetingRepository: mockMeetingRepository,
    );
    // Default: save succeeds
    when(mockMeetingRepository.updateMeeting(any)).thenAnswer((_) async {});
  });

  Widget buildWidget({
    Meeting? meeting,
    void Function(Meeting)? onMeetingUpdated,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<MeetingDetailProvider>.value(
          value: provider,
          child: MeetingNotesSection(
            meeting: meeting ?? testMeeting,
            onMeetingUpdated: onMeetingUpdated ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('MeetingNotesSection', () {
    testWidgets('renders Notes title and input field', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Notes'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('empty input: no note added when add tapped', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // No close buttons — means no note items were added
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('add note: appears in list and calls onMeetingUpdated',
        (tester) async {
      Meeting? updatedMeeting;
      await tester.pumpWidget(buildWidget(
        onMeetingUpdated: (m) => updatedMeeting = m,
      ));

      await tester.enterText(find.byType(TextField), 'Guitar session');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Guitar session'), findsOneWidget);
      expect(updatedMeeting?.notes, equals(['Guitar session']));
    });

    testWidgets('remove note: disappears from list after tapping close',
        (tester) async {
      final meetingWithNote = testMeeting.copyWith(notes: ['Guitar']);
      await tester.pumpWidget(buildWidget(meeting: meetingWithNote));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Guitar'), findsNothing);
    });

    testWidgets('shows snackbar when save fails', (tester) async {
      when(mockMeetingRepository.updateMeeting(any))
          .thenThrow(Exception('network'));

      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextField), 'Note');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(
        find.text('Failed to save notes. Please try again.'),
        findsOneWidget,
      );
    });
  });
}
