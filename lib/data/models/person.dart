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
    @Default([]) List<String> nicknames,
    String? linkedUserId,
    String? birthDayMonth,
    String? partnerId,
    DateTime? partnerLinkedAt,
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
      nicknames: (data['nicknames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      linkedUserId: data['linkedUserId'] as String?,
      birthDayMonth: data['birthDayMonth'] as String?,
      partnerId: data['partnerId'] as String?,
      partnerLinkedAt: data['partnerLinkedAt'] != null
          ? (data['partnerLinkedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'createdAt': Timestamp.fromDate(createdAt),
      'nicknames': nicknames,
      if (linkedUserId != null) 'linkedUserId': linkedUserId,
      if (birthDayMonth != null) 'birthDayMonth': birthDayMonth,
      if (partnerId != null) 'partnerId': partnerId,
      if (partnerLinkedAt != null)
        'partnerLinkedAt': Timestamp.fromDate(partnerLinkedAt!),
    };
  }

  bool isValid() {
    return firstName.isNotEmpty && userId.isNotEmpty;
  }
}
