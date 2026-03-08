import 'activity_category.dart';
import 'meeting.dart';
import 'person.dart';

/// Contains all data needed for a statistics computation pass.
/// Fetched once per year selection to minimize Firestore reads.
/// Plain Dart class — no Freezed, no serialization.
class StatsDataBundle {
  final List<Meeting> currentYearMeetings;
  final List<Meeting> previousYearMeetings;
  final List<ActivityCategory> categories;
  final List<Person> persons;

  const StatsDataBundle({
    required this.currentYearMeetings,
    required this.previousYearMeetings,
    required this.categories,
    required this.persons,
  });
}
