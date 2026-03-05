// test/presentation/widgets/empty_state_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/widgets/empty_state_widget.dart';

void main() {
  Widget buildWidget({required String imagePath, required String message}) {
    return MaterialApp(
      home: Scaffold(
        body: EmptyStateWidget(
          imagePath: imagePath,
          message: message,
        ),
      ),
    );
  }

  group('EmptyStateWidget', () {
    testWidgets('renders Image.asset with correct imagePath', (tester) async {
      const path = 'assets/images/empty_state_meetings.png';
      await tester.pumpWidget(buildWidget(imagePath: path, message: 'Test'));

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, path);
    });

    testWidgets('renders message text', (tester) async {
      const msg = 'No meetings yet — tap + to add your first one!';
      await tester.pumpWidget(buildWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: msg,
      ));

      expect(find.text(msg), findsOneWidget);
    });

    testWidgets('renders different messages correctly', (tester) async {
      const meetingsMsg = 'No meetings yet — tap + to add your first one!';
      const friendsMsg = 'No friends added yet — tap + to get started!';

      await tester.pumpWidget(buildWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: meetingsMsg,
      ));
      expect(find.text(meetingsMsg), findsOneWidget);
      expect(find.text(friendsMsg), findsNothing);

      await tester.pumpWidget(buildWidget(
        imagePath: 'assets/images/empty_state_friends.png',
        message: friendsMsg,
      ));
      expect(find.text(friendsMsg), findsOneWidget);
      expect(find.text(meetingsMsg), findsNothing);
    });
  });
}
