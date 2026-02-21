import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

/// Represents a meeting between the user and one or more friends.
@freezed
class Meeting with _$Meeting {
  const Meeting._();

  const factory Meeting({
    required String id,
    required String userId,
    required String name,
    required DateTime date,
    required int weight,
    required List<String> participantIds,
    required List<String> activityIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);

  /// Creates a Meeting from a Firestore document.
  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meeting(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      date: (data['date'] as Timestamp).toDate(),
      weight: (data['weight'] as num).toInt(),
      participantIds: List<String>.from(data['participantIds'] as List),
      activityIds: List<String>.from(data['activityIds'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converts Meeting to a map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'participantIds': participantIds,
      'activityIds': activityIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Fibonacci sequence used as valid meeting weight values.
  static const List<int> validWeights = [1, 2, 3, 5, 8, 13, 21];

  /// Returns true if the meeting has valid data.
  bool isValid() {
    return name.trim().isNotEmpty &&
        name.length <= 50 &&
        validWeights.contains(weight) &&
        participantIds.isNotEmpty &&
        activityIds.isNotEmpty;
  }
}
