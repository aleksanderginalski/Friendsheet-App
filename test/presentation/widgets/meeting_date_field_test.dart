import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:friendsheet/presentation/widgets/meeting_date_field.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';
import 'package:intl/intl.dart';

void main() {
  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => AddMeetingProvider(),
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
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      // Date picker dialog should be visible
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
