import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sharing_token.dart';

enum TokenValidationError { notFound, expired, alreadyUsed, serverError }

/// Result of a token validation attempt.
/// On success: [ownerUid] and [tokenId] are set.
/// On failure: [error] is set.
class TokenValidationResult {
  final String? ownerUid;
  final String? tokenId;
  final TokenValidationError? error;

  const TokenValidationResult.success({
    required this.ownerUid,
    required this.tokenId,
  }) : error = null;

  const TokenValidationResult.failure(this.error)
      : ownerUid = null,
        tokenId = null;

  bool get isSuccess => error == null;
}

/// Manages sharing tokens for peer-to-peer meeting sharing (FEATURE-012).
/// Tokens are stored in `users/{uid}/sharing_tokens/{tokenId}`.
/// Each token is 6-char alphanumeric, expires after 24h, and is single-use.
class SharingTokenRepository {
  SharingTokenRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference _tokensRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('sharing_tokens');

  /// Returns an existing active token if one exists, otherwise generates a new one.
  /// Cleans up expired/used tokens before checking for an active one.
  Future<SharingToken> generateToken(String userId) async {
    await _cleanupExpiredOrUsed(userId);

    final existing = await getActiveToken(userId);
    if (existing != null) return existing;

    final now = DateTime.now();
    final token = SharingToken(
      id: '',
      token: _generateTokenString(),
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );

    final docRef = await _tokensRef(userId).add(token.toFirestore());
    return token.copyWith(id: docRef.id);
  }

  /// Returns the first active token (not expired, not used), or null if none exists.
  /// Queries only by expiresAt to avoid requiring a composite index.
  /// isUsed is checked client-side — at most 1 token exists at a time.
  Future<SharingToken?> getActiveToken(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot =
        await _tokensRef(userId).where('expiresAt', isGreaterThan: now).get();

    final active = snapshot.docs
        .map((doc) => SharingToken.fromFirestore(doc))
        .where((t) => !t.isUsed)
        .toList();

    if (active.isEmpty) return null;
    return active.first;
  }

  /// Deletes a specific token document by id.
  Future<void> deleteToken(String userId, String tokenId) async {
    await _tokensRef(userId).doc(tokenId).delete();
  }

  /// Validates a token by value across all users (collection group query).
  /// Returns the owner's uid and token doc id on success, or an error on failure.
  /// Does NOT mark the token as used — call markAsUsed() after saving the Person.
  Future<TokenValidationResult> validateAndClaimToken(String tokenValue) async {
    final snapshot = await _firestore
        .collectionGroup('sharing_tokens')
        .where('token', isEqualTo: tokenValue)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return const TokenValidationResult.failure(TokenValidationError.notFound);
    }

    final doc = snapshot.docs.first;
    final token = SharingToken.fromFirestore(doc);
    // Extract owner uid from path: users/{uid}/sharing_tokens/{tokenId}
    final ownerUid = doc.reference.parent.parent!.id;

    if (DateTime.now().isAfter(token.expiresAt)) {
      return const TokenValidationResult.failure(TokenValidationError.expired);
    }
    if (token.isUsed) {
      return const TokenValidationResult.failure(
          TokenValidationError.alreadyUsed);
    }

    return TokenValidationResult.success(ownerUid: ownerUid, tokenId: doc.id);
  }

  /// Marks a token as used. Called by US-090 after successful account linking.
  Future<void> markAsUsed(String userId, String tokenId) async {
    await _tokensRef(userId).doc(tokenId).update({'isUsed': true});
  }

  // Deletes all tokens that are expired or already used.
  Future<void> _cleanupExpiredOrUsed(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());

    final expiredSnapshot = await _tokensRef(userId)
        .where('expiresAt', isLessThanOrEqualTo: now)
        .get();
    final usedSnapshot =
        await _tokensRef(userId).where('isUsed', isEqualTo: true).get();

    final allDocs = [
      ...expiredSnapshot.docs,
      ...usedSnapshot.docs,
    ];

    if (allDocs.isEmpty) return;

    // Deduplicate by id in case a doc matches both conditions.
    final seen = <String>{};
    final batch = _firestore.batch();
    for (final doc in allDocs) {
      if (seen.add(doc.id)) {
        batch.delete(doc.reference);
      }
    }
    await batch.commit();
  }

  // Generates a 6-character uppercase alphanumeric token string.
  String _generateTokenString() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
