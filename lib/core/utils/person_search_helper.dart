import '../../data/models/person.dart';

// Shared person search logic — used by PersonsListProvider and AddMeetingProvider
class PersonSearchHelper {
  PersonSearchHelper._();

  // Returns true if person matches query by firstName, lastName, or any nickname
  static bool matches(Person person, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return false;
    if (person.firstName.toLowerCase().contains(q)) return true;
    if (person.lastName?.toLowerCase().contains(q) ?? false) return true;
    return person.nicknames.any((n) => n.toLowerCase().contains(q));
  }
}
