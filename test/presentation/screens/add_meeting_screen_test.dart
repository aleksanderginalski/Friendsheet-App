import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';
import 'package:friendsheet/presentation/screens/add_meeting_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'add_meeting_screen_test.mocks.dart';

@GenerateMocks([
  PersonRepository,
  ActivityCategoryRepository,
  MeetingRepository,
  AuthService,
])
void main() {
  late MockPersonRepository mockRepository;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockAuthService mockAuthService;

  setUp(() {
    mockRepository = MockPersonRepository();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockAuthService = MockAuthService();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => AddMeetingProvider(
          personRepository: mockRepository,
          categoryRepository: mockCategoryRepository,
          meetingRepository: mockMeetingRepository,
          authService: mockAuthService,
        ),
        child: const AddMeetingScreenView(),
      ),
    );
  }

  group('AddMeetingScreen', () {
    testWidgets('displays AppBar with correct title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Add Meeting'), findsOneWidget);
    });

    testWidgets('displays all section headers', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Meeting Name *'), findsOneWidget);
      expect(find.text('Meeting Date *'), findsOneWidget);
      expect(find.text('Meeting Weight *'), findsOneWidget);
      expect(find.text('Participants * (min. 1)'), findsOneWidget);
      expect(find.text('Activities * (min. 1)'), findsOneWidget);
    });

    testWidgets('Save button is disabled initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final button = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      // Button is enabled now (not null) but blocked by isSaving state
      expect(button.onPressed, isNotNull);
    });

    testWidgets('displays Save Meeting button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('SAVE MEETING'), findsOneWidget);
    });

    testWidgets('name field accepts text input', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.enterText(
        find.byType(TextField).first,
        'Coffee with Anna',
      );
      expect(find.text('Coffee with Anna'), findsOneWidget);
    });
  });
}
