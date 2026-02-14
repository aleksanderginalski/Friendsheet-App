import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Test function to verify Firestore connection
/// Metafora: To jak wysłanie "ping" żeby sprawdzić czy internet działa
Future<void> testFirestoreConnection() async {
  try {
    // Try to write a test document
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('test').doc('connection_test').set({
      'message': 'Firebase connection successful!',
      'timestamp': FieldValue.serverTimestamp(),
    });

    debugPrint('✅ Firestore connection test: SUCCESS');

    // Clean up - delete test document
    await firestore.collection('test').doc('connection_test').delete();
    debugPrint('✅ Test document cleaned up');
  } catch (e) {
    debugPrint('❌ Firestore connection test: FAILED');
    debugPrint('Error: $e');
  }
}
