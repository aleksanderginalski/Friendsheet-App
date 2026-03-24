import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/ai_key_repository.dart';
import 'package:friendsheet/presentation/providers/ai_settings_provider.dart';
import 'package:friendsheet/presentation/screens/ai_settings_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'ai_settings_screen_test.mocks.dart';

@GenerateMocks([AIKeyRepository])
void main() {
  late MockAIKeyRepository mockRepo;

  setUp(() {
    mockRepo = MockAIKeyRepository();
    // Default: no key stored.
    when(mockRepo.loadKey()).thenAnswer((_) async => null);
  });

  Widget buildScreen({AISettingsProvider? provider}) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => provider ?? AISettingsProvider(repository: mockRepo),
        child: const AISettingsScreen(),
      ),
    );
  }

  group('AISettingsScreen — no key saved', () {
    testWidgets('shows key input field and Save button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete Key'), findsNothing);
    });

    testWidgets('shows error message when errorMessage is set', (tester) async {
      final provider = AISettingsProvider(repository: mockRepo);
      await tester.pumpWidget(buildScreen(provider: provider));
      await tester.pumpAndSettle();

      // Trigger validation error directly via provider.
      await provider.saveKey('invalid');
      await tester.pump();

      expect(find.text('Key must start with "sk-"'), findsOneWidget);
    });
  });

  group('AISettingsScreen — key already saved', () {
    testWidgets('shows masked key and Delete Key button', (tester) async {
      when(mockRepo.loadKey()).thenAnswer((_) async => 'sk-test1234');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('••••••••1234'), findsOneWidget);
      expect(find.text('Delete Key'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('AISettingsScreen — delete flow', () {
    testWidgets('shows confirmation dialog on Delete Key tap', (tester) async {
      when(mockRepo.loadKey()).thenAnswer((_) async => 'sk-test1234');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Key'));
      await tester.pumpAndSettle();

      expect(find.text('Delete API Key?'), findsOneWidget);
    });

    testWidgets('CANCEL does not call deleteKey', (tester) async {
      when(mockRepo.loadKey()).thenAnswer((_) async => 'sk-test1234');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Key'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      verifyNever(mockRepo.deleteKey());
    });

    testWidgets('DELETE calls deleteKey and shows input view', (tester) async {
      when(mockRepo.loadKey()).thenAnswer((_) async => 'sk-test1234');
      when(mockRepo.deleteKey()).thenAnswer((_) async {});

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Key'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      verify(mockRepo.deleteKey()).called(1);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
