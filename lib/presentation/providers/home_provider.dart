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
  bool _initialized = false;
  StreamSubscription<Object>? _subscription;

  /// True after the first stream emission has been received.
  bool get isInitialized => _initialized;

  /// True when the onboarding CTA should be shown (meeting count < 50).
  /// Returns false until the first stream emission to avoid a flash of the CTA.
  bool get shouldShowCta => _initialized && _meetingCount < 50;

  /// Subscribes to the meetings stream so [shouldShowCta] updates reactively.
  Future<void> initialize(String userId) async {
    _subscription?.cancel();
    _subscription = _meetingRepository.getMeetingsByUser(userId).listen(
      (meetings) {
        _meetingCount = meetings.length;
        _initialized = true;
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
