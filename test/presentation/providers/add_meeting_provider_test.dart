import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';

void main() {
  late AddMeetingProvider provider;

  setUp(() {
    provider = AddMeetingProvider();
  });

  group('AddMeetingProvider - weight', () {
    test('default weight is 3', () {
      expect(provider.weight, equals(3));
    });

    test('canDecrement is true at default value', () {
      expect(provider.canDecrement, isTrue);
    });

    test('canIncrement is true at default value', () {
      expect(provider.canIncrement, isTrue);
    });

    test('incrementWeight moves to next Fibonacci value', () {
      provider.incrementWeight();
      expect(provider.weight, equals(5));
    });

    test('decrementWeight moves to previous Fibonacci value', () {
      provider.decrementWeight();
      expect(provider.weight, equals(2));
    });

    test('canDecrement is false at minimum value 1', () {
      // Navigate to minimum
      for (int i = 0; i < 10; i++) {
        provider.decrementWeight();
      }
      expect(provider.weight, equals(1));
      expect(provider.canDecrement, isFalse);
    });

    test('canIncrement is false at maximum value 21', () {
      // Navigate to maximum
      for (int i = 0; i < 10; i++) {
        provider.incrementWeight();
      }
      expect(provider.weight, equals(21));
      expect(provider.canIncrement, isFalse);
    });

    test('weight does not change below minimum', () {
      for (int i = 0; i < 10; i++) {
        provider.decrementWeight();
      }
      provider.decrementWeight();
      expect(provider.weight, equals(1));
    });

    test('weight does not change above maximum', () {
      for (int i = 0; i < 10; i++) {
        provider.incrementWeight();
      }
      provider.incrementWeight();
      expect(provider.weight, equals(21));
    });

    test('reset restores default weight 3', () {
      provider.incrementWeight();
      provider.incrementWeight();
      provider.reset();
      expect(provider.weight, equals(3));
    });
  });
}
