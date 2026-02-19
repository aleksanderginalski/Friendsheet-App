import 'package:flutter/foundation.dart';

/// Manages the state for the Add Meeting screen.
/// Holds form data and notifies listeners on changes.
class AddMeetingProvider extends ChangeNotifier {
  // --- Constants ---
  static const List<int> weightValues = [1, 2, 3, 5, 8, 13, 21];

  // --- Form fields ---
  String _name = '';
  DateTime _date = DateTime.now();
  // Default index 2 → value 3
  int _weightIndex = 2;
  final List<String> _participantIds = [];
  final List<String> _activityIds = [];

  // --- Validation errors ---
  String? _nameError;

  // --- Loading / error state ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  String get name => _name;
  DateTime get date => _date;
  int get weight => weightValues[_weightIndex];
  bool get canDecrement => _weightIndex > 0;
  bool get canIncrement => _weightIndex < weightValues.length - 1;
  List<String> get participantIds => List.unmodifiable(_participantIds);
  List<String> get activityIds => List.unmodifiable(_activityIds);
  String? get nameError => _nameError;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Setters ---
  void setName(String value) {
    _name = value;
    // Clear error while user is typing
    if (_nameError != null) {
      _nameError = null;
      notifyListeners();
    }
  }

  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  void incrementWeight() {
    if (canIncrement) {
      _weightIndex++;
      notifyListeners();
    }
  }

  void decrementWeight() {
    if (canDecrement) {
      _weightIndex--;
      notifyListeners();
    }
  }

  // --- Validation ---
  /// Validates name on focus loss. Returns true if valid.
  bool validateName() {
    if (_name.isEmpty) {
      _nameError = 'Meeting name is required';
    } else if (_name.length > 50) {
      _nameError = 'Name cannot exceed 50 characters';
    } else {
      _nameError = null;
    }
    notifyListeners();
    return _nameError == null;
  }

  /// Returns true if the form has minimum required data.
  bool get isFormValid =>
      _name.isNotEmpty &&
      _name.length <= 50 &&
      _participantIds.isNotEmpty &&
      _activityIds.isNotEmpty;

  // --- Reset ---
  /// Resets all form fields to their default values.
  void reset() {
    _name = '';
    _date = DateTime.now();
    _weightIndex = 2;
    _participantIds.clear();
    _activityIds.clear();
    _nameError = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
