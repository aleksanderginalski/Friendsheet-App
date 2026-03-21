// Data types shared between SharedPackageInboxProvider and import screens.

/// Resolution for an activity name conflict during package import.
/// Either rename the incoming activity or link it to an existing category.
class ActivityResolution {
  final String? renamedName;
  final String? linkedCategoryId;

  const ActivityResolution.rename(String name)
      : renamedName = name,
        linkedCategoryId = null;

  const ActivityResolution.link(String id)
      : renamedName = null,
        linkedCategoryId = id;

  bool get isRename => renamedName != null;
}

/// Resolution for a person name conflict during package import.
/// Either add with a nickname or link to an existing person.
class PersonResolution {
  final String? nickname;
  final String? linkedPersonId;

  const PersonResolution.nickname(String n)
      : nickname = n,
        linkedPersonId = null;

  const PersonResolution.link(String id)
      : nickname = null,
        linkedPersonId = id;

  bool get isNickname => nickname != null;
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
