import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

@freezed
class Person with _$Person {
  const Person._();

  const factory Person({
    required String id,
    required String userId,
    required String firstName,
    String? lastName,
    required DateTime createdAt,
  }) = _Person;

  /// Returns full display name, e.g. "Anna" or "Anna Smith"
  String get fullName {
    if (lastName == null || lastName!.trim().isEmpty) {
      return firstName;
    }
    return '$firstName $lastName';
  }

  factory Person.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Person(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      firstName: (data['firstName'] ?? '') as String,
      lastName: data['lastName'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool isValid() {
    return firstName.isNotEmpty && userId.isNotEmpty;
  }
}
