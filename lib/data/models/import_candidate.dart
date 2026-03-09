import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_candidate.freezed.dart';

/// Source type indicating the origin of an ImportCandidate.
enum ImportSourceType { calendar, photos }

/// Transient model representing an event selected for import.
/// Stored in memory only — never persisted to Firestore.
/// Resets when the app is closed.
@freezed
class ImportCandidate with _$ImportCandidate {
  const factory ImportCandidate({
    required String id,
    required String title,
    required DateTime date,
    required List<String> attendeeEmails,
    required ImportSourceType sourceType,
  }) = _ImportCandidate;
}
