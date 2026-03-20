import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/pending_meeting_package_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PendingMeetingPackageRepository repository;

  const userId = 'user-1';

  CollectionReference pendingRef() => fakeFirestore
      .collection('users')
      .doc(userId)
      .collection('pending_meetings');

  // Seeds a minimal valid package document and returns its generated ID.
  Future<String> seedPackage({
    String senderFirstName = 'Ania',
    String senderLastName = 'Kowalska',
  }) async {
    final ref = await pendingRef().add({
      'senderUid': 'sender-uid',
      'senderFirstName': senderFirstName,
      'senderLastName': senderLastName,
      'sentAt': Timestamp.fromDate(DateTime(2026, 3, 20)),
      'meetings': [
        {
          'name': 'Test Meeting',
          'date': Timestamp.fromDate(DateTime(2026, 3, 15)),
          'weight': 3,
          'participants': <Map<String, dynamic>>[],
          'categoryNames': <String>['Cinema'],
        }
      ],
    });
    return ref.id;
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = PendingMeetingPackageRepository(firestore: fakeFirestore);
  });

  group('fetchPackages', () {
    test('returns empty list when subcollection is empty', () async {
      final result = await repository.fetchPackages(userId);

      expect(result, isEmpty);
    });

    test('returns package with correct fields from Firestore', () async {
      final docId = await seedPackage();

      final result = await repository.fetchPackages(userId);

      expect(result, hasLength(1));
      expect(result.first.id, docId);
      expect(result.first.senderFirstName, 'Ania');
      expect(result.first.senderLastName, 'Kowalska');
      expect(result.first.meetings, hasLength(1));
      expect(result.first.meetings.first.name, 'Test Meeting');
    });
  });

  group('deletePackage', () {
    test('removes the document from Firestore', () async {
      final id = await seedPackage();

      await repository.deletePackage(userId, id);

      final snapshot = await pendingRef().get();
      expect(snapshot.docs, isEmpty);
    });
  });
}
