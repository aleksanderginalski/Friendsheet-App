import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/ai_consent_repository.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/screens/ai_consent_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_consent_screen_test.mocks.dart';

@GenerateMocks([AIConsentRepository])
void main() {
  late MockAIConsentRepository mockRepo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    mockRepo = MockAIConsentRepository();
    when(mockRepo.grantConsent()).thenAnswer((_) async {});
  });

  Widget buildScreen() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AIConsentScreen(repository: mockRepo),
    );
  }

  group('AIConsentScreen — content', () {
    testWidgets('shows all three section headers and agree button',
        (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('Always sent to OpenAI'), findsOneWidget);
      expect(find.text('Sent only when you explicitly ask'), findsOneWidget);
      expect(find.text('Never sent to OpenAI'), findsOneWidget);
      expect(find.text('I understand and agree'), findsOneWidget);
      expect(find.text('Read full Privacy Policy'), findsOneWidget);
    });
  });

  group('AIConsentScreen — agree flow', () {
    testWidgets('tapping agree button calls grantConsent', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.tap(find.text('I understand and agree'));
      await tester.pumpAndSettle();

      verify(mockRepo.grantConsent()).called(1);
    });
  });
}
