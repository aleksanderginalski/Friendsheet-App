import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/sharing_token_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SharingTokenRepository repository;

  const userId = 'user-1';

  CollectionReference tokensRef() => fakeFirestore
      .collection('users')
      .doc(userId)
      .collection('sharing_tokens');

  // Seeds a token document directly in Firestore.
  Future<String> seedToken({
    String token = 'ABCDEF',
    bool isUsed = false,
    DateTime? expiresAt,
  }) async {
    final now = DateTime.now();
    final ref = await tokensRef().add({
      'token': token,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(
        expiresAt ?? now.add(const Duration(hours: 24)),
      ),
      'isUsed': isUsed,
    });
    return ref.id;
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = SharingTokenRepository(firestore: fakeFirestore);
  });

  group('generateToken', () {
    test('creates a document in sharing_tokens subcollection', () async {
      await repository.generateToken(userId);

      final snapshot = await tokensRef().get();
      expect(snapshot.docs, hasLength(1));
    });

    test('returned token has 6-character alphanumeric string', () async {
      final token = await repository.generateToken(userId);
      expect(token.token, matches(RegExp(r'^[A-Z0-9]{6}$')));
    });

    test('returned token has expiresAt 24h after createdAt', () async {
      final token = await repository.generateToken(userId);
      final diff = token.expiresAt.difference(token.createdAt);
      expect(diff.inHours, 24);
    });

    test('returns existing active token on second call — idempotent', () async {
      final first = await repository.generateToken(userId);
      final second = await repository.generateToken(userId);

      expect(second.token, first.token);

      // Only one document should exist.
      final snapshot = await tokensRef().get();
      expect(snapshot.docs, hasLength(1));
    });

    test('generates new token when existing token is expired', () async {
      // Seed an expired token.
      await seedToken(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final token = await repository.generateToken(userId);

      // The expired token should be deleted and a new one created.
      final snapshot = await tokensRef().get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.id, token.id);
    });

    test('generates new token when existing token is used', () async {
      await seedToken(isUsed: true);

      await repository.generateToken(userId);

      // The used token should be cleaned up and a new one created.
      final snapshot = await tokensRef().get();
      expect(snapshot.docs, hasLength(1));
      final doc = snapshot.docs.first;
      expect(doc['isUsed'], isFalse);
    });
  });

  group('getActiveToken', () {
    test('returns null when no token exists', () async {
      final result = await repository.getActiveToken(userId);
      expect(result, isNull);
    });

    test('returns active token when one exists', () async {
      await seedToken(token: 'XY1234');
      final result = await repository.getActiveToken(userId);
      expect(result, isNotNull);
      expect(result!.token, 'XY1234');
    });

    test('returns null when token is expired', () async {
      await seedToken(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      final result = await repository.getActiveToken(userId);
      expect(result, isNull);
    });

    test('returns null when token isUsed is true', () async {
      await seedToken(isUsed: true);
      final result = await repository.getActiveToken(userId);
      expect(result, isNull);
    });
  });

  group('deleteToken', () {
    test('removes the token document', () async {
      final id = await seedToken();
      await repository.deleteToken(userId, id);

      final snapshot = await tokensRef().get();
      expect(snapshot.docs, isEmpty);
    });
  });

  group('markAsUsed', () {
    test('sets isUsed to true on the token document', () async {
      final id = await seedToken();
      await repository.markAsUsed(userId, id);

      final doc = await tokensRef().doc(id).get();
      expect(doc['isUsed'], isTrue);
    });
  });

  group('validateAndClaimToken', () {
    test('returns notFound when no token matches the value', () async {
      final result = await repository.validateAndClaimToken('ZZZZZZ');

      expect(result.isSuccess, isFalse);
      expect(result.error, TokenValidationError.notFound);
    });

    test('returns expired when token expiresAt is in the past', () async {
      await seedToken(
        token: 'EXPIRD',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final result = await repository.validateAndClaimToken('EXPIRD');

      expect(result.isSuccess, isFalse);
      expect(result.error, TokenValidationError.expired);
    });

    test('returns alreadyUsed when token isUsed is true', () async {
      await seedToken(token: 'USEDDD', isUsed: true);

      final result = await repository.validateAndClaimToken('USEDDD');

      expect(result.isSuccess, isFalse);
      expect(result.error, TokenValidationError.alreadyUsed);
    });

    test('returns success with ownerUid and tokenId for a valid token',
        () async {
      final tokenId = await seedToken(token: 'VALID1');

      final result = await repository.validateAndClaimToken('VALID1');

      expect(result.isSuccess, isTrue);
      expect(result.ownerUid, userId);
      expect(result.tokenId, tokenId);
    });
  });

  group('cleanup (via generateToken)', () {
    test('deletes expired and used tokens before generating a new one',
        () async {
      // Seed: one expired, one used, one active.
      await seedToken(
        token: 'EXPIRD',
        expiresAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      await seedToken(token: 'ISUSED', isUsed: true);
      final activeId = await seedToken(token: 'ACTIVE');

      // generateToken should return the existing active token.
      final result = await repository.generateToken(userId);
      expect(result.id, activeId);

      // Only the active token should remain.
      final snapshot = await tokensRef().get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.id, activeId);
    });
  });
}
