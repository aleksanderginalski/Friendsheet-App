import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('stores role and content', () {
      const msg = ChatMessage(role: 'user', content: 'Hello');
      expect(msg.role, 'user');
      expect(msg.content, 'Hello');
    });

    test('copyWith replaces content and preserves role', () {
      const original = ChatMessage(role: 'assistant', content: 'Hi there');
      final updated = original.copyWith(content: 'Updated reply');
      expect(updated.role, 'assistant');
      expect(updated.content, 'Updated reply');
    });

    test('copyWith without argument keeps existing content', () {
      const original = ChatMessage(role: 'user', content: 'Original');
      final copy = original.copyWith();
      expect(copy.content, 'Original');
      expect(copy.role, 'user');
    });
  });
}
