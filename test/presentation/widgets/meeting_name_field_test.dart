import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/activity_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';
import 'package:friendsheet/presentation/widgets/meeting_name_field.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'meeting_name_field_test.mocks.dart';

@GenerateMocks([
  PersonRepository,
  ActivityRepository,
  ActivityCategoryRepository,
  MeetingRepository,
  AuthService,
])
void main() {
  late MockPersonRepository mockRepository;
  late MockActivityRepository mockActivityRepository;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockAuthService mockAuthService;

  setUp(() {
    mockRepository = MockPersonRepository();
    mockActivityRepository = MockActivityRepository();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockAuthService = MockAuthService();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => AddMeetingProvider(
            personRepository: mockRepository,
            activityRepository: mockActivityRepository,
            categoryRepository: mockCategoryRepository,
            meetingRepository: mockMeetingRepository,
            authService: mockAuthService,
          ),
          child: const MeetingNameField(),
        ),
      ),
    );
  }

  group('MeetingNameField', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Meeting Name *'), findsOneWidget);
    });

    testWidgets('displays character counter', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('0/50'), findsOneWidget);
    });

    testWidgets('counter updates when text is entered', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      expect(find.text('5/50'), findsOneWidget);
    });

    testWidgets('shows error when field is empty and loses focus',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byType(TextField));
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text('Meeting name is required'), findsOneWidget);
    });

    testWidgets('clears error when user starts typing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byType(TextField));
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text('Meeting name is required'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pump();
      expect(find.text('Meeting name is required'), findsNothing);
    });
  });
}
