// test/helpers/test_factories.dart
//
// Factory functions for domain model instances with sensible defaults.
// Use these to reduce boilerplate in test files — override only what matters.

import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/friend_group.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/models/sharing_token.dart';

/// Creates a [Person] with canonical defaults for testing.
/// Canonical defaults: id='p-1', userId='user-1'.
Person makePerson({
  String id = 'p-1',
  String userId = 'user-1',
  String firstName = 'Anna',
  String? lastName = 'Kowalska',
  DateTime? createdAt,
  List<String> nicknames = const [],
}) {
  return Person(
    id: id,
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    nicknames: nicknames,
  );
}

/// Creates a [Meeting] with canonical defaults for testing.
/// Canonical defaults: id='m-1', userId='user-1'.
Meeting makeMeeting({
  String id = 'm-1',
  String userId = 'user-1',
  String name = 'Coffee with Anna',
  DateTime? date,
  int weight = 3,
  List<String> participantIds = const ['p-1'],
  List<String> categoryIds = const [],
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = date ?? DateTime(2026, 1, 1);
  return Meeting(
    id: id,
    userId: userId,
    name: name,
    date: now,
    weight: weight,
    participantIds: participantIds,
    categoryIds: categoryIds,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

/// Creates an [ActivityCategory] with canonical defaults for testing.
/// Canonical defaults: id='cat-1', userId='user-1'.
ActivityCategory makeCategory({
  String id = 'cat-1',
  String userId = 'user-1',
  String name = 'Sport',
  String iconIdentifier = 'sport_icon',
  bool isGlobal = false,
  bool isSelectableAsActivity = false,
  String? parentCategoryId,
  DateTime? createdAt,
}) {
  return ActivityCategory(
    id: id,
    userId: userId,
    name: name,
    iconIdentifier: iconIdentifier,
    isGlobal: isGlobal,
    isSelectableAsActivity: isSelectableAsActivity,
    parentCategoryId: parentCategoryId,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

/// Creates a [FriendGroup] with canonical defaults for testing.
/// Canonical defaults: id='g-1', userId='user-1'.
/// Note: FriendGroup does not store userId on the model itself,
/// it is stored in the Firestore path only.
FriendGroup makeGroup({
  String id = 'g-1',
  String name = 'Hiking Crew',
  String? iconIdentifier,
  List<String> personIds = const [],
  DateTime? createdAt,
}) {
  return FriendGroup(
    id: id,
    name: name,
    iconIdentifier: iconIdentifier,
    personIds: personIds,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

/// Creates a [SharingToken] with canonical defaults for testing.
/// Canonical defaults: id='t-1', userId='user-1', token='ABC123'.
/// Note: SharingToken does not store userId on the model itself,
/// it is stored in the Firestore path only.
SharingToken makeToken({
  String id = 't-1',
  String token = 'ABC123',
  DateTime? createdAt,
  DateTime? expiresAt,
  bool isUsed = false,
}) {
  final now = createdAt ?? DateTime(2026, 1, 1);
  return SharingToken(
    id: id,
    token: token,
    createdAt: now,
    expiresAt: expiresAt ?? now.add(const Duration(hours: 24)),
    isUsed: isUsed,
  );
}
