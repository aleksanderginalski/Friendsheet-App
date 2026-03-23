import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_meeting_package.freezed.dart';
part 'pending_meeting_package.g.dart';

/// Top-level document written to users/{C_uid}/pending_meetings/{packageId}.
/// Contains sender identity and the list of meetings being shared.
@freezed
class PendingMeetingPackage with _$PendingMeetingPackage {
  const PendingMeetingPackage._();

  const factory PendingMeetingPackage({
    required String id,
    required String senderUid,
    required String senderFirstName,
    required String senderLastName,
    String? senderNickname,
    required DateTime sentAt,
    required List<SharedMeeting> meetings,
  }) = _PendingMeetingPackage;

  factory PendingMeetingPackage.fromJson(Map<String, dynamic> json) =>
      _$PendingMeetingPackageFromJson(json);

  /// Deserializes a Firestore document into a PendingMeetingPackage.
  factory PendingMeetingPackage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingMeetingPackage(
      id: doc.id,
      senderUid: data['senderUid'] as String,
      senderFirstName: data['senderFirstName'] as String,
      senderLastName: data['senderLastName'] as String,
      senderNickname: data['senderNickname'] as String?,
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      meetings: (data['meetings'] as List<dynamic>)
          .map((e) => _sharedMeetingFromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this package to a Firestore-compatible map.
  /// Dates are stored as Timestamps; nested objects are converted manually.
  Map<String, dynamic> toFirestore() {
    return {
      'senderUid': senderUid,
      'senderFirstName': senderFirstName,
      'senderLastName': senderLastName,
      if (senderNickname != null) 'senderNickname': senderNickname,
      'sentAt': Timestamp.fromDate(sentAt),
      'meetings': meetings.map(_sharedMeetingToMap).toList(),
    };
  }
}

/// A single meeting included in a PendingMeetingPackage.
/// Participants and categories are optional depending on sender's choices.
@freezed
class SharedMeeting with _$SharedMeeting {
  const factory SharedMeeting({
    required String name,
    required DateTime date,
    required int weight,
    // Empty when sender chose not to include other participants.
    @Default([]) List<SharedPerson> participants,
    // Empty when sender chose not to include activities.
    @Default([]) List<String> categoryNames,
  }) = _SharedMeeting;

  factory SharedMeeting.fromJson(Map<String, dynamic> json) =>
      _$SharedMeetingFromJson(json);
}

/// Participant data shared in a meeting package.
/// nickname is only populated for the sender — regular participants omit it.
@freezed
class SharedPerson with _$SharedPerson {
  const factory SharedPerson({
    required String firstName,
    String? lastName,
    String? nickname,
  }) = _SharedPerson;

  factory SharedPerson.fromJson(Map<String, dynamic> json) =>
      _$SharedPersonFromJson(json);
}

// Converts a SharedMeeting to a Firestore-compatible map with Timestamp dates.
Map<String, dynamic> _sharedMeetingToMap(SharedMeeting m) {
  return {
    'name': m.name,
    'date': Timestamp.fromDate(m.date),
    'weight': m.weight,
    'participants': m.participants
        .map((p) => {
              'firstName': p.firstName,
              if (p.lastName != null) 'lastName': p.lastName,
              if (p.nickname != null) 'nickname': p.nickname,
            })
        .toList(),
    'categoryNames': m.categoryNames,
  };
}

// Deserializes a Firestore map into a SharedMeeting, converting Timestamp to DateTime.
SharedMeeting _sharedMeetingFromMap(Map<String, dynamic> m) {
  return SharedMeeting(
    name: m['name'] as String,
    date: (m['date'] as Timestamp).toDate(),
    weight: (m['weight'] as num).toInt(),
    participants: ((m['participants'] as List<dynamic>?) ?? []).map((e) {
      final p = e as Map<String, dynamic>;
      return SharedPerson(
        firstName: p['firstName'] as String,
        lastName: p['lastName'] as String?,
        nickname: p['nickname'] as String?,
      );
    }).toList(),
    categoryNames: ((m['categoryNames'] as List<dynamic>?) ?? [])
        .map((e) => e as String)
        .toList(),
  );
}
