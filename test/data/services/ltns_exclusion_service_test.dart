import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/ltns_exclusion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LtnsExclusionService', () {
    test('getExcludedIds — returns empty set when no exclusions saved',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LtnsExclusionService(prefs: prefs);

      final ids = await service.getExcludedIds();

      expect(ids, isEmpty);
    });

    test('setExcluded true — adds person to exclusion set', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LtnsExclusionService(prefs: prefs);

      await service.setExcluded('p1', excluded: true);
      final ids = await service.getExcludedIds();

      expect(ids, contains('p1'));
    });

    test('setExcluded false — removes person from exclusion set', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LtnsExclusionService(prefs: prefs);

      await service.setExcluded('p1', excluded: true);
      await service.setExcluded('p1', excluded: false);
      final ids = await service.getExcludedIds();

      expect(ids, isNot(contains('p1')));
    });

    test('toggle full cycle — add then remove leaves set empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LtnsExclusionService(prefs: prefs);

      await service.setExcluded('p1', excluded: true);
      await service.setExcluded('p2', excluded: true);
      await service.setExcluded('p1', excluded: false);
      final ids = await service.getExcludedIds();

      expect(ids, isNot(contains('p1')));
      expect(ids, contains('p2'));
    });

    test('multiple persons — only excluded ones are in the set', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LtnsExclusionService(prefs: prefs);

      await service.setExcluded('p1', excluded: true);
      await service.setExcluded('p2', excluded: true);
      final ids = await service.getExcludedIds();

      expect(ids, containsAll(['p1', 'p2']));
      expect(ids.length, 2);
    });

    test('setExcluded false on non-excluded person — no error, set unchanged',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LtnsExclusionService(prefs: prefs);

      await service.setExcluded('p1', excluded: true);
      // p2 was never added — removing it should be a no-op.
      await service.setExcluded('p2', excluded: false);
      final ids = await service.getExcludedIds();

      expect(ids, contains('p1'));
      expect(ids, isNot(contains('p2')));
    });

    test('persists across separate service instances using same prefs',
        () async {
      final prefs = await SharedPreferences.getInstance();

      final service1 = LtnsExclusionService(prefs: prefs);
      await service1.setExcluded('p1', excluded: true);

      // Second instance reads same prefs.
      final service2 = LtnsExclusionService(prefs: prefs);
      final ids = await service2.getExcludedIds();

      expect(ids, contains('p1'));
    });
  });
}
