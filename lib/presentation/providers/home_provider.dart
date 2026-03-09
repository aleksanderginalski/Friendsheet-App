import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/meeting_repository.dart';

/// Manages state for the Home tab onboarding CTA.
///
/// Subscribes to the meetings stream. The CTA is shown when the user has
/// fewer than 50 meetings.
class HomeProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;

  HomeProvider({MeetingRepository? meetingRepository})
      : _meetingRepository = meetingRepository ?? MeetingRepository();

  int _meetingCount = 0;
  StreamSubscription<Object>? _subscription;

  /// True when the onboarding CTA should be shown (meeting count < 50).
  bool get shouldShowCta => _meetingCount < 50;

  /// Subscribes to the meetings stream so [shouldShowCta] updates reactively.
  Future<void> initialize(String userId) async {
    _subscription?.cancel();
    _subscription = _meetingRepository.getMeetingsByUser(userId).listen(
      (meetings) {
        _meetingCount = meetings.length;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
