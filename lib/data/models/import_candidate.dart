import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_candidate.freezed.dart';
part 'import_candidate.g.dart';

/// Source type indicating the origin of an ImportCandidate.
enum ImportSourceType { calendar, photos }

/// Transient model representing an event selected for import.
/// Persisted to SharedPreferences while the import session is in progress.
@freezed
class ImportCandidate with _$ImportCandidate {
  const factory ImportCandidate({
    required String id,
    required String title,
    required DateTime date,
    required List<String> attendeeEmails,
    required ImportSourceType sourceType,
  }) = _ImportCandidate;

  factory ImportCandidate.fromJson(Map<String, dynamic> json) =>
      _$ImportCandidateFromJson(json);
}
