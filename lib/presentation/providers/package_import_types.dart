// Data types shared between SharedPackageInboxProvider and import screens.

/// Resolution for an activity name conflict during package import.
class ActivityResolution {
  final String? renamedName;
  final String? linkedCategoryId;
  final bool _skip;

  const ActivityResolution.rename(String name)
      : renamedName = name,
        linkedCategoryId = null,
        _skip = false;

  const ActivityResolution.link(String id)
      : renamedName = null,
        linkedCategoryId = id,
        _skip = false;

  /// User chose to skip this activity — it will not be imported.
  const ActivityResolution.skip()
      : renamedName = null,
        linkedCategoryId = null,
        _skip = true;

  bool get isRename => renamedName != null;
  bool get isLink => linkedCategoryId != null;
  bool get isSkip => _skip;
}

/// Resolution for a person name conflict during package import.
class PersonResolution {
  final String? nickname;
  final String? linkedPersonId;
  final bool _skip;
  final bool _createNew;

  const PersonResolution.nickname(String n)
      : nickname = n,
        linkedPersonId = null,
        _skip = false,
        _createNew = false;

  const PersonResolution.link(String id)
      : nickname = null,
        linkedPersonId = id,
        _skip = false,
        _createNew = false;

  /// User chose to skip this person — they will not be imported.
  const PersonResolution.skip()
      : nickname = null,
        linkedPersonId = null,
        _skip = true,
        _createNew = false;

  /// User chose to create as new (no nickname) despite a name conflict.
  const PersonResolution.createNew()
      : nickname = null,
        linkedPersonId = null,
        _skip = false,
        _createNew = true;

  bool get isNickname => nickname != null;
  bool get isLink => linkedPersonId != null;
  bool get isSkip => _skip;
  bool get isCreateNew => _createNew;
}

/// Summary of the import operation, shown on the success screen.
class ImportSummary {
  final int meetingsAdded;
  final int personsAdded;
  final int activitiesAdded;

  const ImportSummary({
    required this.meetingsAdded,
    required this.personsAdded,
    required this.activitiesAdded,
  });
}
