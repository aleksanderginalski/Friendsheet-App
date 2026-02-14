import 'package:flutter_test/flutter_test.dart';

import 'package:friendsheet/main.dart';

void main() {
  testWidgets('Friendsheet app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const FriendsheetApp());

    // Verify that our placeholder UI is displayed
    expect(find.text('🎯 Friendsheet MVP'), findsOneWidget);
    expect(find.text('Ready for US-003: Git & CI/CD Setup'), findsOneWidget);

    // Verify app title in AppBar
    expect(find.text('Friendsheet - Track Your Meetings'), findsOneWidget);
  });
}
