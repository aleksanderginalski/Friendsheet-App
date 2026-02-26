import 'package:flutter/foundation.dart';

import '../../data/models/activity_category.dart';
import '../../data/models/meeting.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/person_repository.dart';

/// Manages state for MeetingDetailScreen.
/// Resolves participant IDs and category IDs to full objects.
class MeetingDetailProvider extends ChangeNotifier {
  final PersonRepository _personRepository;
  final ActivityCategoryRepository _categoryRepository;

  MeetingDetailProvider({
    required PersonRepository personRepository,
    ActivityCategoryRepository? categoryRepository,
  })  : _personRepository = personRepository,
        _categoryRepository =
            categoryRepository ?? ActivityCategoryRepository();

  List<Person> _participants = [];
  // Only leaf categories are stored here (ancestors are filtered out).
  List<ActivityCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Person> get participants => _participants;
  List<ActivityCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads full person and category objects for the given meeting.
  Future<void> initialize(Meeting meeting) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Skip persons fetch when no participant IDs to avoid unnecessary Firestore queries
      final personsFuture = meeting.participantIds.isEmpty
          ? Future.value(<Person>[])
          : _personRepository.getPersonsByIds(
              meeting.participantIds, meeting.userId);

      // Fetch participants and categories in parallel
      final results = await Future.wait([
        personsFuture,
        _resolveCategoryIds(meeting.categoryIds, meeting.userId),
      ]);

      _participants = results[0] as List<Person>;
      _categories = results[1] as List<ActivityCategory>;
    } catch (e) {
      _errorMessage = 'Failed to load meeting details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetches categories by IDs and filters to leaf nodes only.
  // A category is a leaf if its ID is not the parentCategoryId of any other
  // category in the resolved list — ancestors are excluded from display.
  Future<List<ActivityCategory>> _resolveCategoryIds(
    List<String> ids,
    String userId,
  ) async {
    if (ids.isEmpty) return [];

    final resolved = await _categoryRepository.getCategoriesByIds(ids, userId);

    // Collect all parentCategoryIds within the resolved set.
    final parentIds = resolved
        .where((c) => c.parentCategoryId != null)
        .map((c) => c.parentCategoryId!)
        .toSet();

    // Keep only categories that are not referenced as a parent by another.
    return resolved.where((c) => !parentIds.contains(c.id)).toList();
  }
}
