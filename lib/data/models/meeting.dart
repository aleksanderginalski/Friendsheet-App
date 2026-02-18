// lib/data/models/meeting.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Required for Freezed code generation
part 'meeting.freezed.dart';
// Required for JSON serialization
part 'meeting.g.dart';

/// Meeting model representing a social gathering with friends
/// 
/// This model uses Freezed for immutability and code generation.
/// Valid weight values follow Fibonacci sequence: 1, 2, 3, 5, 8, 13, 21
@freezed
class Meeting with _$Meeting {
  const Meeting._(); // Private constructor for custom methods
  
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

  /// Valid Fibonacci weight values
  static const List<int> validWeights = [1, 2, 3, 5, 8, 13, 21];

  /// Creates Meeting from Firestore document
  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Meeting(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      weight: data['weight'] ?? 1,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      activityIds: List<String>.from(data['activityIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Creates Meeting from JSON
  factory Meeting.fromJson(Map<String, dynamic> json) => 
      _$MeetingFromJson(json);

  /// Converts Meeting to Firestore map
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

  /// Validates meeting data
  bool isValid() {
    return name.isNotEmpty &&
           name.length <= 50 &&
           validWeights.contains(weight) &&
           participantIds.isNotEmpty &&
           activityIds.isNotEmpty;
  }
}