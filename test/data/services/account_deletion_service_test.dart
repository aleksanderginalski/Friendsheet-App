import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/account_deletion_service.dart';
import 'package:friendsheet/data/services/google_calendar_service.dart';
import 'package:friendsheet/services/hive_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_deletion_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  GoogleCalendarService,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockGoogleCalendarService mockCalendarService;
  late FakeFirebaseFirestore fakeFirestore;
  late AccountDeletionService service;
  late Directory tempDir;

  const uid = 'test-user-uid';

  // Seeds a document in the given subcollection so we can verify it was deleted.
  Future<void> seedSubcollectionDoc(
    FakeFirebaseFirestore firestore,
    String subcollection,
    String docId,
  ) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection(subcollection)
        .doc(docId)
        .set({'data': 'value'});
  }

  // Stubs the Google Sign-In + reauthentication flow to succeed.
  void stubReauthSuccess() {
    when(mockGoogleSignIn.signInSilently())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleSignInAuthentication);
    when(mockGoogleSignInAuthentication.idToken).thenReturn('fake-id-token');
    when(mockGoogleSignInAuthentication.accessToken)
        .thenReturn('fake-access-token');
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(
      mockUser.reauthenticateWithCredential(any),
    ).thenAnswer((_) async => mockUserCredential);
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    await HiveService.initialize(testPath: tempDir.path);
  });

  tearDownAll(() async {
    // Close all open Hive boxes before deleting the temp directory so the OS
    // releases file locks (required on Windows).
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockCalendarService = MockGoogleCalendarService();
    fakeFirestore = FakeFirebaseFirestore();

    service = AccountDeletionService(
      firebaseAuth: mockAuth,
      firestore: fakeFirestore,
      googleSignIn: mockGoogleSignIn,
      calendarService: mockCalendarService,
    );

    SharedPreferences.setMockInitialValues({});
    when(mockCalendarService.revokeAccess()).thenAnswer((_) => Future.value());
    when(mockUser.delete()).thenAnswer((_) => Future.value());
  });

  group('deleteAccount — happy path', () {
    test(
        'reauthenticates, deletes Firestore subcollections and user doc, '
        'deletes auth user, clears local data', () async {
      stubReauthSuccess();

      // Seed data in all three subcollections and the user doc.
      await seedSubcollectionDoc(fakeFirestore, 'meetings', 'mtg-1');
      await seedSubcollectionDoc(fakeFirestore, 'persons', 'per-1');
      await seedSubcollectionDoc(fakeFirestore, 'activity_categories', 'cat-1');
      await fakeFirestore.collection('users').doc(uid).set({'name': 'Alice'});

      await service.deleteAccount(uid);

      // All subcollection docs must be gone.
      final meetings = await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('meetings')
          .get();
      expect(meetings.docs, isEmpty);

      final persons = await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('persons')
          .get();
      expect(persons.docs, isEmpty);

      final categories = await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('activity_categories')
          .get();
      expect(categories.docs, isEmpty);

      // User document itself must be deleted.
      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      expect(userDoc.exists, isFalse);

      // Firebase Auth user must be deleted.
      verify(mockUser.delete()).called(1);

      // Calendar service revoke must be called to clear secure storage.
      verify(mockCalendarService.revokeAccess()).called(1);
    });
  });

  group('deleteAccount — reauthentication fails', () {
    test(
        'throws when sign-in returns null, no Firestore ops or user.delete() called',
        () async {
      // Both silent and interactive sign-in return null — user cancelled.
      when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
      when(mockAuth.currentUser).thenReturn(mockUser);

      expect(
        () => service.deleteAccount(uid),
        throwsA(isA<Exception>()),
      );

      // Auth user must never be deleted.
      verifyNever(mockUser.delete());
      // Calendar service must not have been touched.
      verifyNever(mockCalendarService.revokeAccess());
    });
  });

  group('deleteAccount — Firebase Auth delete fails', () {
    test('throws and does not clear local data when user.delete() throws',
        () async {
      stubReauthSuccess();

      // Make the Firebase Auth deletion step fail.
      when(mockUser.delete())
          .thenThrow(Exception('auth/requires-recent-login'));

      expect(
        () => service.deleteAccount(uid),
        throwsA(isA<Exception>()),
      );

      // Local data must not be cleared — revoke must not be called.
      verifyNever(mockCalendarService.revokeAccess());
    });
  });
}
