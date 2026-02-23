import 'package:flutter/foundation.dart';

import '../../data/models/activity.dart';
import '../../data/models/meeting.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/person_repository.dart';

/// Manages state for MeetingDetailScreen.
/// Resolves participant IDs and activity IDs to full objects.
class MeetingDetailProvider extends ChangeNotifier {
  final PersonRepository _personRepository;
  final ActivityRepository _activityRepository;

  MeetingDetailProvider({
    required PersonRepository personRepository,
    required ActivityRepository activityRepository,
  })  : _personRepository = personRepository,
        _activityRepository = activityRepository;

  List<Person> _participants = [];
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Person> get participants => _participants;
  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads full person and activity objects for the given meeting.
  Future<void> initialize(Meeting meeting) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch participants and activities in parallel
      final results = await Future.wait([
        _personRepository.getPersonsByIds(meeting.participantIds),
        _activityRepository.getActivitiesByIds(meeting.activityIds),
      ]);

      _participants = results[0] as List<Person>;
      _activities = results[1] as List<Activity>;
    } catch (e) {
      _errorMessage = 'Failed to load meeting details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
