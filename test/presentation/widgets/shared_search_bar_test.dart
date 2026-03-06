import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/widgets/shared_search_bar.dart';

void main() {
  Widget buildBar({
    required ValueChanged<String> onChanged,
    String hintText = 'Search...',
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SharedSearchBar(
          onChanged: onChanged,
          hintText: hintText,
          controller: controller,
        ),
      ),
    );
  }

  group('SharedSearchBar', () {
    testWidgets('renders hint text correctly', (tester) async {
      await tester.pumpWidget(buildBar(
        onChanged: (_) {},
        hintText: 'Search here...',
      ));

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.hintText, equals('Search here...'));
    });

    testWidgets('uses default hint text when not specified', (tester) async {
      await tester.pumpWidget(buildBar(onChanged: (_) {}));

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.hintText, equals('Search...'));
    });

    testWidgets('calls onChanged when text is typed', (tester) async {
      String? captured;
      await tester.pumpWidget(buildBar(onChanged: (v) => captured = v));

      await tester.enterText(find.byType(TextField), 'hello');

      expect(captured, equals('hello'));
    });

    testWidgets('does not show clear button when no controller provided',
        (tester) async {
      await tester.pumpWidget(buildBar(onChanged: (_) {}));

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('does not show clear button when controller text is empty',
        (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildBar(
        onChanged: (_) {},
        controller: controller,
      ));

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('shows clear button when controller has text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildBar(
        onChanged: (_) {},
        controller: controller,
      ));

      controller.text = 'abc';
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets(
        'shows clear button immediately when controller is initialised with text',
        (tester) async {
      final controller = TextEditingController(text: 'hello');
      await tester.pumpWidget(buildBar(
        onChanged: (_) {},
        controller: controller,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button resets controller text', (tester) async {
      final controller = TextEditingController(text: 'hello');
      await tester.pumpWidget(buildBar(
        onChanged: (_) {},
        controller: controller,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('clear button calls onChanged with empty string',
        (tester) async {
      final controller = TextEditingController(text: 'hello');
      String? captured;
      await tester.pumpWidget(buildBar(
        onChanged: (v) => captured = v,
        controller: controller,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(captured, equals(''));
    });

    testWidgets('has search prefix icon', (tester) async {
      await tester.pumpWidget(buildBar(onChanged: (_) {}));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
