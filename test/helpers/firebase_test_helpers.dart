// test/helpers/firebase_test_helpers.dart
//
// Shared Firebase initialisation for widget/integration tests.
// Call setupTestFirebase() inside setUpAll() to initialise Firebase Core with
// platform mocks so Firestore/Auth instances are available without a real app.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Initialises Firebase with platform mocks for use in tests.
/// Must be called inside setUpAll() in each test file that needs Firebase.
Future<void> setupTestFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
}
