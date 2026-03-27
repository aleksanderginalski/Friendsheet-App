import 'package:flutter/foundation.dart';

import '../../data/models/meeting.dart';
import '../../data/repositories/meeting_repository.dart';

/// Manages state for the HomeScreen Buddy widget.
///
/// Fetches the most recently dated meeting without notes within the last
/// 60 days. Exposes expand/collapse state for the widget card.
class BuddyWidgetProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;

  BuddyWidgetProvider({MeetingRepository? meetingRepository})
      : _meetingRepository = meetingRepository ?? MeetingRepository();

  Meeting? _suggestedMeeting;
  bool _isExpanded = true;
  bool _isInitialized = false;

  /// The most recently added meeting without notes within the last 2 months,
  /// or null if no such meeting exists.
  Meeting? get suggestedMeeting => _suggestedMeeting;

  /// True when the widget card is expanded (visible). Collapsed = only icon shown.
  bool get isExpanded => _isExpanded;

  /// True after the first fetch has completed.
  bool get isInitialized => _isInitialized;

  /// Fetches the suggested meeting for the given user.
  Future<void> initialize(String userId) async {
    final since = DateTime.now().subtract(const Duration(days: 60));
    _suggestedMeeting =
        await _meetingRepository.getLastMeetingWithoutNotes(userId, since);
    _isInitialized = true;
    notifyListeners();
  }

  /// Collapses the widget card; Buddy icon remains visible.
  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }

  /// Re-expands the widget card.
  void expand() {
    _isExpanded = true;
    notifyListeners();
  }
}
