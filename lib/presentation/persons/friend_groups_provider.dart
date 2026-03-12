import 'package:flutter/foundation.dart';

import '../../data/models/friend_group.dart';
import '../../data/repositories/friend_group_repository.dart';
import '../../data/services/auth_service.dart';

// Manages state for friend groups in the Friends tab.
// Responsibilities: fetch all groups, CRUD operations, and
// optimistic updates for person assignment changes.
class FriendGroupsProvider extends ChangeNotifier {
  final FriendGroupRepository _repository;
  final AuthService _authService;

  List<FriendGroup> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FriendGroup> get groups => List.unmodifiable(_groups);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FriendGroupsProvider({
    FriendGroupRepository? repository,
    AuthService? authService,
  })  : _repository = repository ?? FriendGroupRepository(),
        _authService = authService ?? AuthService();

  // Loads all groups for the current user. Safe to call multiple times.
  Future<void> loadGroups() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _repository.getGroupsByUser(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Creates a new group with the given name and optional icon.
  // Calls loadGroups() after creation to obtain the Firestore-generated ID.
  Future<void> addGroup({required String name, String? iconIdentifier}) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final group = FriendGroup(
      id: '',
      name: name,
      iconIdentifier: iconIdentifier,
      createdAt: DateTime.now(),
    );
    await _repository.addGroup(userId, group);
    await loadGroups();
  }

  // Updates name and/or iconIdentifier of an existing group, then refreshes.
  Future<void> updateGroup(FriendGroup group) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    await _repository.updateGroup(userId, group);
    await loadGroups();
  }

  // Deletes a group document. Does NOT delete or modify any Person documents.
  Future<void> deleteGroup(String groupId) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    await _repository.deleteGroup(userId, groupId);
    await loadGroups();
  }

  // Adds a person to a group with an optimistic local update.
  // On error, reverts by reloading from Firestore.
  Future<void> addPersonToGroup(String groupId, String personId) async {
    _groups = _groups.map((g) {
      if (g.id != groupId || g.personIds.contains(personId)) return g;
      return g.copyWith(personIds: [...g.personIds, personId]);
    }).toList();
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;
      await _repository.addPersonToGroup(userId, groupId, personId);
    } catch (e) {
      _errorMessage = e.toString();
      await loadGroups();
    }
  }

  // Removes a person from a group with an optimistic local update.
  // On error, reverts by reloading from Firestore.
  Future<void> removePersonFromGroup(String groupId, String personId) async {
    _groups = _groups.map((g) {
      if (g.id != groupId) return g;
      return g.copyWith(
        personIds: g.personIds.where((id) => id != personId).toList(),
      );
    }).toList();
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;
      await _repository.removePersonFromGroup(userId, groupId, personId);
    } catch (e) {
      _errorMessage = e.toString();
      await loadGroups();
    }
  }

  // Returns groups that contain the given personId. Pure client-side filter.
  List<FriendGroup> groupsForPerson(String personId) =>
      _groups.where((g) => g.personIds.contains(personId)).toList();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
