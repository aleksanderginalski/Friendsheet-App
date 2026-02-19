import 'package:flutter/foundation.dart';

/// Manages the state for the Add Meeting screen.
/// Holds form data and notifies listeners on changes.
class AddMeetingProvider extends ChangeNotifier {
  // --- Form fields ---
  String _name = '';
  DateTime _date = DateTime.now();
  int _weight = 3;
  final List<String> _participantIds = [];
  final List<String> _activityIds = [];

  // --- Loading / error state ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  String get name => _name;
  DateTime get date => _date;
  int get weight => _weight;
  List<String> get participantIds => List.unmodifiable(_participantIds);
  List<String> get activityIds => List.unmodifiable(_activityIds);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Setters (will be expanded in US-011 to US-014) ---

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  void setWeight(int value) {
    _weight = value;
    notifyListeners();
  }

  // --- Validation (basic, will be expanded later) ---

  /// Returns true if the form has minimum required data.
  bool get isFormValid =>
      _name.isNotEmpty && _participantIds.isNotEmpty && _activityIds.isNotEmpty;

  // --- Reset ---

  /// Resets all form fields to their default values.
  void reset() {
    _name = '';
    _date = DateTime.now();
    _weight = 3;
    _participantIds.clear();
    _activityIds.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
