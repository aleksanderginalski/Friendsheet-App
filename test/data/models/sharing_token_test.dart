import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/sharing_token.dart';

void main() {
  final DateTime testCreatedAt = DateTime(2026, 3, 19, 10, 0, 0);
  final DateTime testExpiresAt = DateTime(2026, 3, 20, 10, 0, 0);

  group('SharingToken model', () {
    group('fromFirestore', () {
      late FakeFirebaseFirestore fakeFirestore;

      setUp(() {
        fakeFirestore = FakeFirebaseFirestore();
      });

      Future<DocumentSnapshot> seedDoc(Map<String, dynamic> data) async {
        final ref = await fakeFirestore
            .collection('users')
            .doc('u1')
            .collection('sharing_tokens')
            .add(data);
        return ref.get();
      }

      test('maps all fields correctly', () async {
        final doc = await seedDoc({
          'token': 'FR4K9X',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'expiresAt': Timestamp.fromDate(testExpiresAt),
          'isUsed': false,
        });
        final token = SharingToken.fromFirestore(doc);
        expect(token.token, 'FR4K9X');
        expect(token.createdAt, testCreatedAt);
        expect(token.expiresAt, testExpiresAt);
        expect(token.isUsed, isFalse);
        expect(token.id, isNotEmpty);
      });

      test('uses document ID as token id', () async {
        final ref = fakeFirestore
            .collection('users')
            .doc('u1')
            .collection('sharing_tokens')
            .doc('fixed-id');
        await ref.set({
          'token': 'ABC123',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'expiresAt': Timestamp.fromDate(testExpiresAt),
          'isUsed': false,
        });
        final doc = await ref.get();
        final token = SharingToken.fromFirestore(doc);
        expect(token.id, 'fixed-id');
      });

      test('isUsed defaults to false when field absent', () async {
        final doc = await seedDoc({
          'token': 'XY1234',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'expiresAt': Timestamp.fromDate(testExpiresAt),
        });
        final token = SharingToken.fromFirestore(doc);
        expect(token.isUsed, isFalse);
      });

      test('does not throw when createdAt field absent — uses epoch fallback',
          () async {
        final doc = await seedDoc({
          'token': 'NODATE',
          'expiresAt': Timestamp.fromDate(testExpiresAt),
        });
        expect(() => SharingToken.fromFirestore(doc), returnsNormally);
        final token = SharingToken.fromFirestore(doc);
        expect(token.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
      });

      test('does not throw when expiresAt field absent — uses epoch fallback',
          () async {
        final doc = await seedDoc({
          'token': 'NOEXPIRY',
          'createdAt': Timestamp.fromDate(testCreatedAt),
        });
        expect(() => SharingToken.fromFirestore(doc), returnsNormally);
        final token = SharingToken.fromFirestore(doc);
        expect(token.expiresAt, DateTime.fromMillisecondsSinceEpoch(0));
      });
    });

    group('toFirestore', () {
      test('returns map with Timestamp values for createdAt and expiresAt', () {
        final token = SharingToken(
          id: 'tok-1',
          token: 'FR4K9X',
          createdAt: testCreatedAt,
          expiresAt: testExpiresAt,
          isUsed: false,
        );
        final map = token.toFirestore();
        expect(map['token'], 'FR4K9X');
        expect(map['isUsed'], isFalse);
        expect(map['createdAt'], isA<Timestamp>());
        expect(map['expiresAt'], isA<Timestamp>());
        expect(
          (map['createdAt'] as Timestamp).toDate(),
          testCreatedAt,
        );
        expect(
          (map['expiresAt'] as Timestamp).toDate(),
          testExpiresAt,
        );
      });

      test('isUsed true is preserved in toFirestore', () {
        final token = SharingToken(
          id: 'tok-2',
          token: 'USED12',
          createdAt: testCreatedAt,
          expiresAt: testExpiresAt,
          isUsed: true,
        );
        expect(token.toFirestore()['isUsed'], isTrue);
      });
    });

    group('default values', () {
      test('isUsed defaults to false', () {
        final token = SharingToken(
          id: 'id',
          token: 'ABC123',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
        expect(token.isUsed, isFalse);
      });
    });
  });
}
