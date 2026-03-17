import '../../data/models/person.dart';

// Shared person search logic — used by PersonsListProvider and AddMeetingProvider
class PersonSearchHelper {
  PersonSearchHelper._();

  // Returns true if person matches query by firstName, lastName, full name, or any nickname.
  // Full-name check supports cross-field queries like "Aleksander G".
  static bool matches(Person person, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return false;
    if (person.firstName.toLowerCase().contains(q)) return true;
    if (person.lastName?.toLowerCase().contains(q) ?? false) return true;
    final fullName =
        '${person.firstName} ${person.lastName ?? ''}'.trim().toLowerCase();
    if (fullName.contains(q)) return true;
    return person.nicknames.any((n) => n.toLowerCase().contains(q));
  }
}
