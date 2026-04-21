import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/meeting_repository.dart';
import '../../data/services/local_cache_service.dart';

/// Manages state for the Home tab onboarding CTA.
///
/// Cache-first: loads meeting count from Hive immediately so the CTA
/// renders without waiting for Firestore. Stream keeps count up to date.
class HomeProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;

  HomeProvider({MeetingRepository? meetingRepository})
      : _meetingRepository = meetingRepository ?? MeetingRepository();

  int _meetingCount = 0;
  bool _initialized = false;
  StreamSubscription<Object>? _subscription;

  /// True after the first data has been received (cache or stream).
  bool get isInitialized => _initialized;

  /// True when the onboarding CTA should be shown (meeting count < 50).
  /// Returns false until data arrives to avoid a flash of the CTA.
  bool get shouldShowCta => _initialized && _meetingCount < 50;

  /// Loads meeting count from cache, then subscribes to stream for live updates.
  Future<void> initialize(String userId) async {
    _subscription?.cancel();

    // Cache-first: render CTA state immediately without Firestore round-trip.
    final cached = await LocalCacheService().getAllMeetings(userId);
    if (cached.isNotEmpty) {
      _meetingCount = cached.length;
      _initialized = true;
      notifyListeners();
    }

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
