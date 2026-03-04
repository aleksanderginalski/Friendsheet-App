import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/screens/splash_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'splash_screen_test.mocks.dart';

@GenerateMocks([VideoPlayerControllerInterface])
void main() {
  late MockVideoPlayerControllerInterface mockController;

  setUp(() {
    mockController = MockVideoPlayerControllerInterface();
    when(mockController.initialize()).thenAnswer((_) async {});
    when(mockController.play()).thenAnswer((_) async {});
    when(mockController.dispose()).thenAnswer((_) async {});
    when(mockController.isInitialized).thenReturn(false);
  });

  Widget buildSplash() {
    return MaterialApp(
      home: SplashScreen(
        nextScreen: const Scaffold(),
        controller: mockController,
      ),
    );
  }

  group('SplashScreen', () {
    testWidgets('renders Friendsheet text', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump();

      expect(find.text('Friendsheet'), findsOneWidget);
    });

    testWidgets('has correct background color #FAFAF7', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFFFAFAF7));
    });
  });
}
