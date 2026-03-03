import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/export_service.dart';
import 'package:friendsheet/presentation/providers/export_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'export_provider_test.mocks.dart';

@GenerateMocks([ExportService])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockExportService mockExportService;
  late ExportProvider provider;

  setUp(() {
    mockExportService = MockExportService();
    provider = ExportProvider(exportService: mockExportService);
  });

  tearDown(() {
    provider.dispose();
  });

  group('ExportProvider initial state', () {
    test('isLoading is false', () {
      expect(provider.isLoading, isFalse);
    });

    test('errorMessage is null', () {
      expect(provider.errorMessage, isNull);
    });

    test('lastExportPath is null', () {
      expect(provider.lastExportPath, isNull);
    });
  });

  group('exportData()', () {
    test('happy path — isLoading transitions false→true→false, path set',
        () async {
      const exportedPath =
          '/storage/emulated/0/friendsheet_export_2026-03-03.json';
      when(mockExportService.exportToDevice('user-1'))
          .thenAnswer((_) async => exportedPath);

      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      await provider.exportData('user-1');

      // First notification: isLoading=true; second: isLoading=false.
      expect(states, equals([true, false]));
      expect(provider.lastExportPath, equals(exportedPath));
      expect(provider.errorMessage, isNull);
    });

    test(
        'error case — service throws ExportException → errorMessage set, isLoading false',
        () async {
      when(mockExportService.exportToDevice('user-1'))
          .thenThrow(const ExportException('disk full'));

      await provider.exportData('user-1');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, equals('disk full'));
      expect(provider.lastExportPath, isNull);
    });

    test('error case — service throws generic exception → errorMessage set',
        () async {
      when(mockExportService.exportToDevice('user-1'))
          .thenThrow(Exception('unexpected'));

      await provider.exportData('user-1');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, equals('Export failed'));
    });

    test('no-op when already loading', () async {
      // Simulate an in-progress export by calling without await.
      when(mockExportService.exportToDevice('user-1')).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return '/some/path';
      });

      // First call — starts loading.
      final first = provider.exportData('user-1');
      expect(provider.isLoading, isTrue);

      // Second call while loading — must be a no-op.
      await provider.exportData('user-1');

      await first;

      // exportToDevice must have been called exactly once.
      verify(mockExportService.exportToDevice('user-1')).called(1);
    });
  });

  group('clearError()', () {
    test('resets errorMessage to null', () async {
      when(mockExportService.exportToDevice('user-1'))
          .thenThrow(const ExportException('oops'));

      await provider.exportData('user-1');
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });
  });
}
