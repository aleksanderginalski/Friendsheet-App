import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../repositories/activity_category_repository.dart';
import '../repositories/meeting_repository.dart';
import '../repositories/person_repository.dart';

/// Fetches all user data and writes it as a JSON file to device storage.
class ExportService {
  final MeetingRepository _meetingRepository;
  final PersonRepository _personRepository;
  final ActivityCategoryRepository _activityCategoryRepository;

  // Injectable directory provider used in tests to avoid path_provider I/O.
  final Future<Directory> Function()? _directoryProvider;

  ExportService({
    required MeetingRepository meetingRepository,
    required PersonRepository personRepository,
    required ActivityCategoryRepository activityCategoryRepository,
    @visibleForTesting Future<Directory> Function()? directoryProvider,
  })  : _meetingRepository = meetingRepository,
        _personRepository = personRepository,
        _activityCategoryRepository = activityCategoryRepository,
        _directoryProvider = directoryProvider;

  /// Fetches all data for [userId], serializes to JSON, and writes the file.
  /// Returns the absolute file path on success.
  /// Throws [ExportException] on failure.
  Future<String> exportToDevice(String userId) async {
    try {
      final meetings = await _meetingRepository.getMeetingsByUser(userId).first;
      final persons = await _personRepository.getPersonsByUser(userId);
      final categories =
          await _activityCategoryRepository.getAllCategories(userId);

      final exportMap = <String, dynamic>{
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'version': '1.0',
        'meetings': meetings.map((m) => m.toJson()).toList(),
        'persons': persons.map((p) => p.toJson()).toList(),
        'activityCategories': categories.map((c) => c.toJson()).toList(),
      };

      final content = jsonEncode(exportMap);
      final dir = await _resolveDirectory();
      final filename =
          'friendsheet_export_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
      final file = File('${dir.path}/$filename');
      await file.writeAsString(content);
      return file.path;
    } on ExportException {
      rethrow;
    } catch (e) {
      throw ExportException('Export failed: $e');
    }
  }

  Future<Directory> _resolveDirectory() async {
    if (_directoryProvider != null) {
      return _directoryProvider!();
    }

    Directory? dir;
    try {
      dir = await getExternalStorageDirectory();
    } catch (_) {
      // External storage unavailable on some platforms — fall through.
    }
    return dir ?? await getApplicationDocumentsDirectory();
  }
}

/// Thrown when export fails due to an unexpected error.
class ExportException implements Exception {
  final String message;

  const ExportException(this.message);

  @override
  String toString() => 'ExportException: $message';
}
