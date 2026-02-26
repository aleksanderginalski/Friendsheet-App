import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';
import 'package:friendsheet/presentation/widgets/meeting_date_field.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'meeting_date_field_test.mocks.dart';

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
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => AddMeetingProvider(
            personRepository: mockRepository,
            categoryRepository: mockCategoryRepository,
            meetingRepository: mockMeetingRepository,
            authService: mockAuthService,
          ),
          child: const MeetingDateField(),
        ),
      ),
    );
  }

  group('MeetingDateField', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Meeting Date *'), findsOneWidget);
    });

    testWidgets('displays today as default date', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final expected = DateFormat('dd/MM/yyyy').format(DateTime.now());
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('displays calendar icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('opens date picker on tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNotNull);
    });
  });
}
