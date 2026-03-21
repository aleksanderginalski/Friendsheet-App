import 'package:flutter/foundation.dart';

import '../../data/models/activity_category.dart';
import '../../data/models/meeting.dart';
import '../../data/models/pending_meeting_package.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/pending_meeting_package_repository.dart';
import '../../data/repositories/person_repository.dart';
import 'package_import_types.dart';
import 'package_importer.dart';

export 'package_import_types.dart';

/// Resolution chosen by user C for a meeting date conflict in a shared package.
enum ConflictResolution { merge, addAsNew, skip }

/// Manages received PendingMeetingPackages, conflict detection, and batch import.
///
/// Lifecycle:
///   1. Created in MainScreen.initState().
///   2. Call [initialize] after auth — loads packages, detects date conflicts
///      and person/activity name conflicts.
///   3. Use [resolveConflict] as user resolves each date conflict (US-092).
///   4. Use [canProceed] to gate the Continue button in PackageConflictScreen.
///   5. Use resolve*/setOptOut methods as user resolves person/activity conflicts.
///   6. Use [canProceedToImport] to gate the Confirm button.
///   7. Call [importPackage] for final batch write + Firestore cleanup.
class SharedPackageInboxProvider extends ChangeNotifier {
  final PendingMeetingPackageRepository _packageRepo;
  final MeetingRepository _meetingRepo;
  final PersonRepository _personRepo;
  final ActivityCategoryRepository _categoryRepo;

  List<PendingMeetingPackage> _packages = [];

  // packageId → { meetingIndex → existing Meeting with the same date }
  final Map<String, Map<int, Meeting>> _conflicts = {};
  // packageId → { meetingIndex → chosen resolution }
  final Map<String, Map<int, ConflictResolution>> _resolutions = {};
  // packageId → lowercase categoryName → conflicting existing category
  final Map<String, Map<String, ActivityCategory>> _activityConflicts = {};
  // packageId → lowercase categoryName → user's resolution (conflicts only)
  final Map<String, Map<String, ActivityResolution>> _activityResolutions = {};
  // packageId → set of lowercase categoryNames opted OUT (non-conflicts only)
  final Map<String, Set<String>> _activityOptOut = {};

  // packageId → personKey → conflicting existing person
  final Map<String, Map<String, Person>> _personConflicts = {};

  // packageId → personKey → user's resolution (conflicts only)
  final Map<String, Map<String, PersonResolution>> _personResolutions = {};

  // packageId → set of personKeys opted OUT (non-conflicts only)
  final Map<String, Set<String>> _personOptOut = {};

  // packageId → unique activity names (original casing) across all meetings
  final Map<String, List<String>> _uniqueActivityNames = {};

  // packageId → personKey → SharedPerson across all meetings
  final Map<String, Map<String, SharedPerson>> _uniquePersons = {};

  bool _isLoading = false;

  SharedPackageInboxProvider({
    required PendingMeetingPackageRepository packageRepository,
    required MeetingRepository meetingRepository,
    required PersonRepository personRepository,
    required ActivityCategoryRepository categoryRepository,
  })  : _packageRepo = packageRepository,
        _meetingRepo = meetingRepository,
        _personRepo = personRepository,
        _categoryRepo = categoryRepository;

  List<PendingMeetingPackage> get packages => List.unmodifiable(_packages);
  bool get isLoading => _isLoading;
  bool get hasPackages => _packages.isNotEmpty;

  Map<int, Meeting> conflictsFor(String packageId) =>
      Map.unmodifiable(_conflicts[packageId] ?? {});

  ConflictResolution? resolutionFor(String packageId, int meetingIndex) =>
      _resolutions[packageId]?[meetingIndex];

  List<String> uniqueActivityNamesFor(String packageId) =>
      List.unmodifiable(_uniqueActivityNames[packageId] ?? []);

  Map<String, SharedPerson> uniquePersonsFor(String packageId) =>
      Map.unmodifiable(_uniquePersons[packageId] ?? {});

  Map<String, ActivityCategory> activityConflictsFor(String packageId) =>
      Map.unmodifiable(_activityConflicts[packageId] ?? {});

  Map<String, Person> personConflictsFor(String packageId) =>
      Map.unmodifiable(_personConflicts[packageId] ?? {});

  ActivityResolution? activityResolutionFor(String packageId, String lower) =>
      _activityResolutions[packageId]?[lower];

  PersonResolution? personResolutionFor(String packageId, String personKey) =>
      _personResolutions[packageId]?[personKey];

  bool isActivityOptedOut(String packageId, String lower) =>
      _activityOptOut[packageId]?.contains(lower) ?? false;

  bool isPersonOptedOut(String packageId, String personKey) =>
      _personOptOut[packageId]?.contains(personKey) ?? false;

  /// True when every date conflict in the package has a resolution assigned.
  bool canProceed(String packageId) {
    final conflicts = _conflicts[packageId] ?? {};
    if (conflicts.isEmpty) return true;
    final resolutions = _resolutions[packageId] ?? {};
    return conflicts.keys.every((i) => resolutions.containsKey(i));
  }

  /// True when all activity conflicts have resolutions assigned.
  bool canProceedActivities(String packageId) {
    final actConflicts = _activityConflicts[packageId] ?? {};
    if (actConflicts.isEmpty) return true;
    final actRes = _activityResolutions[packageId] ?? {};
    return actConflicts.keys.every((k) => actRes.containsKey(k));
  }

  /// True when all person conflicts have resolutions assigned.
  bool canProceedPersons(String packageId) {
    final personConflicts = _personConflicts[packageId] ?? {};
    if (personConflicts.isEmpty) return true;
    final personRes = _personResolutions[packageId] ?? {};
    return personConflicts.keys.every((k) => personRes.containsKey(k));
  }

  /// True when all activity and person conflicts have resolutions assigned.
  bool canProceedToImport(String packageId) =>
      canProceedActivities(packageId) && canProceedPersons(packageId);

  void resolveConflict(
      String packageId, int meetingIndex, ConflictResolution resolution) {
    _resolutions[packageId] ??= {};
    _resolutions[packageId]![meetingIndex] = resolution;
    notifyListeners();
  }

  void resolveActivityConflict(
      String packageId, String lower, ActivityResolution res) {
    _activityResolutions[packageId] ??= {};
    _activityResolutions[packageId]![lower] = res;
    notifyListeners();
  }

  void resolvePersonConflict(
      String packageId, String personKey, PersonResolution res) {
    _personResolutions[packageId] ??= {};
    _personResolutions[packageId]![personKey] = res;
    notifyListeners();
  }

  void setActivityOptOut(String packageId, String lower, bool optedOut) {
    _activityOptOut[packageId] ??= {};
    if (optedOut) {
      _activityOptOut[packageId]!.add(lower);
    } else {
      _activityOptOut[packageId]!.remove(lower);
    }
    notifyListeners();
  }

  void setPersonOptOut(String packageId, String personKey, bool optedOut) {
    _personOptOut[packageId] ??= {};
    if (optedOut) {
      _personOptOut[packageId]!.add(personKey);
    } else {
      _personOptOut[packageId]!.remove(personKey);
    }
    notifyListeners();
  }

  /// Removes the package from local state and clears all associated conflict
  /// and resolution state. Called by [importPackage] after successful import.
  void dismissPackage(String packageId) {
    _packages = _packages.where((p) => p.id != packageId).toList();
    _conflicts.remove(packageId);
    _resolutions.remove(packageId);
    _activityConflicts.remove(packageId);
    _activityResolutions.remove(packageId);
    _activityOptOut.remove(packageId);
    _personConflicts.remove(packageId);
    _personResolutions.remove(packageId);
    _personOptOut.remove(packageId);
    _uniqueActivityNames.remove(packageId);
    _uniquePersons.remove(packageId);
    notifyListeners();
  }

  /// Loads packages, detects date conflicts and person/activity name conflicts.
  /// Returns early without loading if [userId] is empty.
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
        for (final m in existingMeetings) {
          if (m.date.year == sharedDate.year &&
              m.date.month == sharedDate.month &&
              m.date.day == sharedDate.day) {
            _conflicts[pkg.id] ??= {};
            _conflicts[pkg.id]![i] = m;
            break;
          }
        }
      }
    }

    final existingPersons = await _personRepo.getPersonsByUser(userId);
    final existingCategories = await _categoryRepo.getAllCategories(userId);
    _detectPersonActivityConflicts(existingPersons, existingCategories);

    _isLoading = false;
    notifyListeners();
  }

  /// Collects unique activity names and persons from all meetings in each package,
  /// then checks them against existing data to populate conflict maps.
  void _detectPersonActivityConflicts(
    List<Person> existingPersons,
    List<ActivityCategory> existingCategories,
  ) {
    for (final pkg in _packages) {
      final seenNames = <String>{};
      final names = <String>[];
      final persons = <String, SharedPerson>{};

      for (final m in pkg.meetings) {
        for (final name in m.categoryNames) {
          if (seenNames.add(name.toLowerCase())) names.add(name);
        }
        for (final sp in m.participants) {
          persons.putIfAbsent(_personKey(sp.firstName, sp.lastName), () => sp);
        }
      }

      // Always include sender as a person to import into each package.
      final senderKey = _personKey(pkg.senderFirstName, pkg.senderLastName);
      persons.putIfAbsent(
        senderKey,
        () => SharedPerson(
          firstName: pkg.senderFirstName,
          lastName: pkg.senderLastName,
        ),
      );

      _uniqueActivityNames[pkg.id] = names;
      _uniquePersons[pkg.id] = persons;

      for (final name in names) {
        final lower = name.toLowerCase();
        for (final cat in existingCategories) {
          if (cat.name.toLowerCase() == lower) {
            _activityConflicts[pkg.id] ??= {};
            _activityConflicts[pkg.id]![lower] = cat;
            break;
          }
        }
      }

      for (final key in persons.keys) {
        for (final p in existingPersons) {
          if (_personKey(p.firstName, p.lastName) == key) {
            _personConflicts[pkg.id] ??= {};
            _personConflicts[pkg.id]![key] = p;
            break;
          }
        }
      }
    }
  }

  /// Imports meetings, persons, and activities from the package to Firestore,
  /// then deletes the package document and clears local state.
  Future<ImportSummary> importPackage(String packageId, String userId) async {
    final pkg = _packages.firstWhere((p) => p.id == packageId);
    final summary = await PackageImporter(
      meetingRepo: _meetingRepo,
      personRepo: _personRepo,
      categoryRepo: _categoryRepo,
    ).run(
      package: pkg,
      meetingConflicts: _conflicts[packageId] ?? {},
      meetingResolutions: _resolutions[packageId] ?? {},
      activityResolutions: _activityResolutions[packageId] ?? {},
      activityOptOut: _activityOptOut[packageId] ?? {},
      personResolutions: _personResolutions[packageId] ?? {},
      personOptOut: _personOptOut[packageId] ?? {},
      userId: userId,
    );
    await _packageRepo.deletePackage(userId, packageId);
    dismissPackage(packageId);
    return summary;
  }

  static String _personKey(String firstName, String? lastName) =>
      '${firstName.trim().toLowerCase()} ${(lastName ?? '').trim().toLowerCase()}'
          .trim();
}
