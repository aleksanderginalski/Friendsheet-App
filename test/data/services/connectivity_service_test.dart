// test/data/services/connectivity_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/connectivity_service.dart';

void main() {
  tearDown(() {
    // Reset singleton to default so tests do not bleed into each other.
    ConnectivityService().isOnlineNotifier.value = true;
  });

  group('ConnectivityService', () {
    test('isOnline is true by default', () {
      expect(ConnectivityService().isOnline, isTrue);
    });

    test('isOnline reflects isOnlineNotifier.value', () {
      ConnectivityService().isOnlineNotifier.value = false;
      expect(ConnectivityService().isOnline, isFalse);
    });

    test('factory returns the same singleton instance', () {
      expect(ConnectivityService(), same(ConnectivityService()));
    });
  });
}
