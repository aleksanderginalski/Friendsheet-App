import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/meeting_repository.dart';

const _kCtaDismissedKey = 'onboarding_calendar_cta_dismissed';

/// Manages state for the Home tab onboarding CTA.
///
/// Subscribes to the meetings stream and persists the dismissed flag
/// in SharedPreferences. The CTA is shown when the user has fewer than
/// 50 meetings and has not dismissed it.
class HomeProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;

  HomeProvider({MeetingRepository? meetingRepository})
      : _meetingRepository = meetingRepository ?? MeetingRepository();

  int _meetingCount = 0;
  bool _isDismissed = false;
  StreamSubscription<Object>? _subscription;

  /// True when the onboarding CTA should be shown.
  bool get shouldShowCta => _meetingCount < 50 && !_isDismissed;

  /// Loads the dismissed flag from SharedPreferences and subscribes to the
  /// meetings stream so [shouldShowCta] updates reactively.
  Future<void> initialize(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    _isDismissed = prefs.getBool(_kCtaDismissedKey) ?? false;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _meetingRepository.getMeetingsByUser(userId).listen(
      (meetings) {
        _meetingCount = meetings.length;
        notifyListeners();
      },
    );
  }

  /// Marks the CTA as dismissed and persists the flag to SharedPreferences.
  Future<void> dismissCta() async {
    _isDismissed = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCtaDismissedKey, true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
