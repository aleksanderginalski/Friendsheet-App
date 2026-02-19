import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:friendsheet/presentation/widgets/meeting_name_field.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';

void main() {
  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => AddMeetingProvider(),
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
      // Focus the field
      await tester.tap(find.byType(TextField));
      await tester.pump();
      // Simulate focus loss programmatically
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text('Meeting name is required'), findsOneWidget);
    });

    testWidgets('clears error when user starts typing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Trigger error first
      await tester.tap(find.byType(TextField));
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text('Meeting name is required'), findsOneWidget);
      // Now type something
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pump();
      expect(find.text('Meeting name is required'), findsNothing);
    });
  });
}
