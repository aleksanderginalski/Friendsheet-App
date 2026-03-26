import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/ai_exceptions.dart';

void main() {
  group('NetworkException', () {
    test('default message and toString', () {
      const e = NetworkException();
      expect(e.message, 'Network error');
      expect(e.toString(), 'NetworkException: Network error');
    });

    test('custom message', () {
      const e = NetworkException('No connection');
      expect(e.message, 'No connection');
      expect(e.toString(), 'NetworkException: No connection');
    });
  });

  group('InvalidKeyException', () {
    test('default message and toString', () {
      const e = InvalidKeyException();
      expect(e.message, 'Invalid API key');
      expect(e.toString(), 'InvalidKeyException: Invalid API key');
    });

    test('custom message', () {
      const e = InvalidKeyException('No API key configured');
      expect(e.message, 'No API key configured');
    });
  });

  group('QuotaExceededException', () {
    test('default message and toString', () {
      const e = QuotaExceededException();
      expect(e.message, 'Quota exceeded');
      expect(e.toString(), 'QuotaExceededException: Quota exceeded');
    });
  });

  group('AIServiceException', () {
    test('default message and toString', () {
      const e = AIServiceException();
      expect(e.message, 'AI service error');
      expect(e.toString(), 'AIServiceException: AI service error');
    });

    test('custom message', () {
      const e = AIServiceException('Upstream failure');
      expect(e.message, 'Upstream failure');
    });
  });

  group('implements Exception', () {
    test('all exception types satisfy Exception interface', () {
      expect(const NetworkException(), isA<Exception>());
      expect(const InvalidKeyException(), isA<Exception>());
      expect(const QuotaExceededException(), isA<Exception>());
      expect(const AIServiceException(), isA<Exception>());
    });
  });
}
