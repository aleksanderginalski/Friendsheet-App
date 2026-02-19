import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:friendsheet/presentation/screens/add_meeting_screen.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';

void main() {
  Widget buildTestWidget() {
    return const MaterialApp(
      home: AddMeetingScreen(),
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

      expect(button.onPressed, isNull);
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
