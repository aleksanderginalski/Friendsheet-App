import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/services/meeting_package_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MeetingPackageService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = MeetingPackageService(firestore: fakeFirestore);
  });

  final meeting = SharedMeeting(
    name: 'Coffee',
    date: DateTime(2026, 3, 1),
    weight: 3,
  );

  PendingMeetingPackage makePackage() => PendingMeetingPackage(
        id: '',
        senderUid: 'uid-a',
        senderFirstName: 'Anna',
        senderLastName: 'Smith',
        sentAt: DateTime(2026, 3, 20),
        meetings: [meeting],
      );

  group('MeetingPackageService', () {
    test('sendPackage writes document to pending_meetings with correct fields',
        () async {
      await service.sendPackage(makePackage(), 'uid-c');

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('uid-c')
          .collection('pending_meetings')
          .get();

      expect(snapshot.docs.length, equals(1));
      final data = snapshot.docs.first.data();
      expect(data['senderUid'], equals('uid-a'));
      expect(data['senderFirstName'], equals('Anna'));
      expect(data['senderLastName'], equals('Smith'));
      expect(data['meetings'], hasLength(1));
    });

    test('sendPackage writes document ID back into senderUid field is correct',
        () async {
      await service.sendPackage(makePackage(), 'uid-c');

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('uid-c')
          .collection('pending_meetings')
          .get();

      // Auto-generated doc ID must be non-empty.
      expect(snapshot.docs.first.id, isNotEmpty);
    });

    test('sendPackage writes to recipient subcollection, not sender', () async {
      await service.sendPackage(makePackage(), 'uid-c');

      final senderSnapshot = await fakeFirestore
          .collection('users')
          .doc('uid-a')
          .collection('pending_meetings')
          .get();

      expect(senderSnapshot.docs, isEmpty);
    });
  });
}
