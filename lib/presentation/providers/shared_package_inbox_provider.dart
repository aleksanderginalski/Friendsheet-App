import 'package:flutter/foundation.dart';

import '../../data/models/meeting.dart';
import '../../data/models/pending_meeting_package.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/pending_meeting_package_repository.dart';

/// Resolution chosen by user C for a meeting date conflict in a shared package.
enum ConflictResolution { merge, addAsNew, skip }

/// Manages received PendingMeetingPackages and date-conflict resolution state.
///
/// Lifecycle:
///   1. Created in MainScreen.initState().
///   2. Call [initialize] after auth to load packages and detect conflicts.
///   3. Use [resolveConflict] as user resolves each date conflict.
///   4. Use [canProceed] to gate the "Continue" button in PackageConflictScreen.
///   5. Call [dismissPackage] when user taps Continue — removes from local state.
///      US-093 handles final Firestore import and deletion.
class SharedPackageInboxProvider extends ChangeNotifier {
  final PendingMeetingPackageRepository _packageRepo;
  final MeetingRepository _meetingRepo;

  List<PendingMeetingPackage> _packages = [];

  // packageId -> { meetingIndex -> existing Meeting with the same date }
  final Map<String, Map<int, Meeting>> _conflicts = {};

  // packageId -> { meetingIndex -> chosen resolution }
  final Map<String, Map<int, ConflictResolution>> _resolutions = {};

  bool _isLoading = false;

  SharedPackageInboxProvider({
    required PendingMeetingPackageRepository packageRepository,
    required MeetingRepository meetingRepository,
  })  : _packageRepo = packageRepository,
        _meetingRepo = meetingRepository;

  List<PendingMeetingPackage> get packages => List.unmodifiable(_packages);

  bool get isLoading => _isLoading;

  bool get hasPackages => _packages.isNotEmpty;

  /// Returns conflicts for one package (empty map if none detected).
  Map<int, Meeting> conflictsFor(String packageId) =>
      Map.unmodifiable(_conflicts[packageId] ?? {});

  /// Returns the current resolution for a specific meeting index (null if not chosen).
  ConflictResolution? resolutionFor(String packageId, int meetingIndex) =>
      _resolutions[packageId]?[meetingIndex];

  /// True when every conflict in the package has a resolution assigned.
  bool canProceed(String packageId) {
    final conflicts = _conflicts[packageId] ?? {};
    if (conflicts.isEmpty) return true;
    final resolutions = _resolutions[packageId] ?? {};
    return conflicts.keys.every((i) => resolutions.containsKey(i));
  }

  /// Records the user's resolution choice for a conflict; notifies listeners.
  void resolveConflict(
      String packageId, int meetingIndex, ConflictResolution resolution) {
    _resolutions[packageId] ??= {};
    _resolutions[packageId]![meetingIndex] = resolution;
    notifyListeners();
  }

  /// Removes the package from local state only (no Firestore delete).
  /// US-093 handles the final import and Firestore cleanup.
  void dismissPackage(String packageId) {
    _packages = _packages.where((p) => p.id != packageId).toList();
    _conflicts.remove(packageId);
    _resolutions.remove(packageId);
    notifyListeners();
  }

  /// Loads packages from Firestore and detects date conflicts against existing meetings.
  /// Returns early without loading if [userId] is empty — guards against unauthenticated state.
  Future<void> initialize(String userId) async {
    if (userId.isEmpty) {
      _isLoading = false;
      return;
    }

    _isLoading = true;
    notifyListeners();

    _packages = await _packageRepo.fetchPackages(userId);

    final existingMeetings = await _meetingRepo.getMeetingsByUser(userId).first;

    for (final pkg in _packages) {
      for (var i = 0; i < pkg.meetings.length; i++) {
        final sharedDate = pkg.meetings[i].date;
        Meeting? conflicting;
        for (final m in existingMeetings) {
          if (m.date.year == sharedDate.year &&
              m.date.month == sharedDate.month &&
              m.date.day == sharedDate.day) {
            conflicting = m;
            break;
          }
        }
        if (conflicting != null) {
          _conflicts[pkg.id] ??= {};
          _conflicts[pkg.id]![i] = conflicting;
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
