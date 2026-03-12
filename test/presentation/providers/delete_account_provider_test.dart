import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/account_deletion_service.dart';
import 'package:friendsheet/presentation/providers/delete_account_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'delete_account_provider_test.mocks.dart';

@GenerateMocks([AccountDeletionService])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockAccountDeletionService mockDeletionService;
  late DeleteAccountProvider provider;

  const uid = 'test-user-uid';

  setUp(() {
    mockDeletionService = MockAccountDeletionService();
    provider = DeleteAccountProvider(deletionService: mockDeletionService);
  });

  tearDown(() {
    provider.dispose();
  });

  group('initial state', () {
    test('isLoading is false', () {
      expect(provider.isLoading, isFalse);
    });

    test('errorMessage is null', () {
      expect(provider.errorMessage, isNull);
    });
  });

  group('deleteAccount — success', () {
    test('calls deletionService.deleteAccount with correct uid', () async {
      when(mockDeletionService.deleteAccount(uid))
          .thenAnswer((_) => Future.value());

      await provider.deleteAccount(uid);

      verify(mockDeletionService.deleteAccount(uid)).called(1);
    });

    test('isLoading transitions false→true during call', () async {
      final loadingStates = <bool>[];

      when(mockDeletionService.deleteAccount(uid)).thenAnswer((_) async {
        // Capture isLoading state while the call is in progress.
        loadingStates.add(provider.isLoading);
        return;
      });

      provider.addListener(() {
        if (!loadingStates.contains(provider.isLoading)) {
          loadingStates.add(provider.isLoading);
        }
      });

      await provider.deleteAccount(uid);

      // isLoading must have been true at some point during the call.
      expect(loadingStates, contains(true));
    });

    test('errorMessage remains null on success', () async {
      when(mockDeletionService.deleteAccount(uid))
          .thenAnswer((_) => Future.value());

      await provider.deleteAccount(uid);

      expect(provider.errorMessage, isNull);
    });
  });

  group('deleteAccount — error', () {
    test('sets errorMessage when service throws', () async {
      when(mockDeletionService.deleteAccount(uid))
          .thenThrow(Exception('delete failed'));

      await provider.deleteAccount(uid);

      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('delete failed'));
    });

    test('sets isLoading to false after error', () async {
      when(mockDeletionService.deleteAccount(uid))
          .thenThrow(Exception('delete failed'));

      await provider.deleteAccount(uid);

      expect(provider.isLoading, isFalse);
    });

    test('notifies listeners on error', () async {
      when(mockDeletionService.deleteAccount(uid))
          .thenThrow(Exception('delete failed'));

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.deleteAccount(uid);

      expect(notified, isTrue);
    });
  });

  group('deleteAccount — no-op when already loading', () {
    test('ignores second call while first is in progress', () async {
      // Make the first call pause until we trigger it.
      var firstCallCompleted = false;
      when(mockDeletionService.deleteAccount(uid)).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        firstCallCompleted = true;
        return;
      });

      // Start first call without awaiting.
      final firstCall = provider.deleteAccount(uid);

      // Second call while first is still in progress — should be a no-op.
      await provider.deleteAccount(uid);
      await firstCall;

      // Service must be called exactly once despite two provider invocations.
      verify(mockDeletionService.deleteAccount(uid)).called(1);
      expect(firstCallCompleted, isTrue);
    });
  });

  group('clearError', () {
    test('clears errorMessage and notifies listeners', () async {
      when(mockDeletionService.deleteAccount(uid))
          .thenThrow(Exception('some error'));
      await provider.deleteAccount(uid);
      expect(provider.errorMessage, isNotNull);

      var notified = false;
      provider.addListener(() => notified = true);
      provider.clearError();

      expect(provider.errorMessage, isNull);
      expect(notified, isTrue);
    });
  });
}
