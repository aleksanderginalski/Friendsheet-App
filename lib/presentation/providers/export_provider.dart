import 'package:flutter/foundation.dart';

import '../../data/services/export_service.dart';

/// Manages state for the data export feature.
/// Follows the ChangeNotifier loading/error pattern used across this project.
class ExportProvider extends ChangeNotifier {
  final ExportService _exportService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _lastExportPath;

  ExportProvider({required ExportService exportService})
      : _exportService = exportService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Absolute path of the last successfully written file. Used in success SnackBar.
  String? get lastExportPath => _lastExportPath;

  /// Triggers the export for [userId]. Updates isLoading, lastExportPath,
  /// and errorMessage according to the outcome.
  Future<void> exportData(String userId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _lastExportPath = null;
    notifyListeners();

    try {
      final path = await _exportService.exportToDevice(userId);
      _lastExportPath = path;
    } catch (e) {
      _errorMessage = e is ExportException ? e.message : 'Export failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
