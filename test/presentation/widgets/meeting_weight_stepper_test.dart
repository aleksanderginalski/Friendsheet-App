import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/widgets/meeting_weight_stepper.dart';

void main() {
  // Helper to build widget with given state
  Widget buildStepper({
    required int value,
    required bool canDecrement,
    required bool canIncrement,
    VoidCallback? onDecrement,
    VoidCallback? onIncrement,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MeetingWeightStepper(
          value: value,
          canDecrement: canDecrement,
          canIncrement: canIncrement,
          onDecrement: onDecrement ?? () {},
          onIncrement: onIncrement ?? () {},
        ),
      ),
    );
  }

  group('MeetingWeightStepper', () {
    testWidgets('displays current value', (tester) async {
      await tester.pumpWidget(buildStepper(
        value: 8,
        canDecrement: true,
        canIncrement: true,
      ));

      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('decrement button disabled at minimum value', (tester) async {
      await tester.pumpWidget(buildStepper(
        value: 1,
        canDecrement: false,
        canIncrement: true,
      ));

      final decrementButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove),
      );
      expect(decrementButton.onPressed, isNull);
    });

    testWidgets('increment button disabled at maximum value', (tester) async {
      await tester.pumpWidget(buildStepper(
        value: 21,
        canDecrement: true,
        canIncrement: false,
      ));

      final incrementButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add),
      );
      expect(incrementButton.onPressed, isNull);
    });

    testWidgets('calls onIncrement when increment button tapped',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(buildStepper(
        value: 3,
        canDecrement: true,
        canIncrement: true,
        onIncrement: () => called = true,
      ));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      expect(called, isTrue);
    });

    testWidgets('calls onDecrement when decrement button tapped',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(buildStepper(
        value: 3,
        canDecrement: true,
        canIncrement: true,
        onDecrement: () => called = true,
      ));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
      expect(called, isTrue);
    });
  });
}
