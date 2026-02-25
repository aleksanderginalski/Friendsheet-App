# Friendsheet — Claude Code Instructions

## Project Identity (Invariants)
- **App name:** Friendsheet
- **Root widget:** FriendsheetApp
- **Package name:** com.friendsheet.app
- **Main entry file:** main.dart
- **Repository:** friendsheet-app

## Tech Stack
- Flutter 3.0+ / Dart
- Firebase Auth + Cloud Firestore
- Provider (ChangeNotifier)
- Freezed + json_serializable
- Mockito for tests

## Architecture
Clean Architecture with three layers:
- `lib/data/` — models (Freezed), repositories (Firestore), services (Auth)
- `lib/domain/` — scaffolded for future use
- `lib/presentation/` — screens, widgets, providers

## Code Standards
- Code comments: English only
- Style: explain WHAT and WHY, no metaphors in comments
- Max file length: 300 lines
- Always use `const` constructors where possible
- Prefer single quotes for strings

## Naming Conventions
- Files: snake_case
- Classes: UpperCamelCase
- Variables/methods: lowerCamelCase
- Tests mirror lib/ structure exactly
  - `lib/data/models/person.dart` → `test/data/models/person_test.dart`

## Git Workflow
- Branch format: `{issue-number}-{short-description}`
- Conventional Commits required:
  - `feat:` new feature
  - `fix:` bug fix
  - `test:` adding tests
  - `refactor:` code change without feature/fix
  - `docs:` documentation only
  - `chore:` build, config, dependencies
- Always include `Closes #issue_number` in commit message
- Never push directly — always PR to main

## Flutter Best Practices
- Run `flutter analyze` before every commit
- Run `flutter test` before every commit
- Fix all issues before committing — never commit with failing tests
- Disable buttons during loading to prevent double-tap
- Check `mounted` before setState

## Freezed Workflow
After any model change:
```bash
dart run build_runner build --delete-conflicting-outputs
```
- Commit generated files (*.freezed.dart, *.g.dart)
- Use explicit type casting in fromFirestore

## Gitignore Check Protocol
Before adding new packages or files — check if .gitignore needs updating:
- API keys → always gitignored
- Generated files (*.freezed.dart, *.g.dart) → committed in this project
- firebase_options.dart → gitignored
- google-services.json → gitignored

## Testing Patterns
- MockRepository injected via constructor (never instantiate real Firebase in tests)
- After adding dependency to Provider → update ALL test files that create that Provider
- Run `dart run build_runner build --delete-conflicting-outputs` after @GenerateMocks changes
- Widget tests: use `FocusManager.instance.primaryFocus?.unfocus()` for focus-loss simulation

## Never Do
- Never use `--dangerously-skip-permissions`
- Never commit firebase_options.dart or google-services.json
- Never push with failing tests
- Never use names: MyApp, MainApp, ExampleApp, TestApp
- Never push directly to main — always PR

## Provider Navigation Pattern

When creating a Provider for a detail screen, always create it at the
navigation call-site (in the parent screen), not inside the target screen itself.
Use addPostFrameCallback in initState to call initialize() on the provider.

See: PersonDetailScreen + PersonsListScreen as reference implementation.

## Firestore Security Rules — List Queries on Subcollections

When writing Security Rules for subcollections (`users/{userId}/subcollection/{docId}`),
use `userId` from the URL path for `allow read` and `allow delete` — NOT `resource.data.userId`.

`resource.data` is unavailable during list queries (Firestore does not load document data
to evaluate list permissions). Path-based check is always safe for both get and list.
```javascript
// WRONG — blocks list queries:
allow read: if isAuthenticated() && isOwner(resource.data.userId);

// CORRECT — works for both get and list:
allow read: if isAuthenticated() && isOwner(userId);
```

## AlertDialog Layout — No ListView Inside

`AlertDialog` computes its width using `IntrinsicWidth`. `ListView` does not support
intrinsic dimension queries and will crash with:
`RenderViewport does not support returning intrinsic dimensions`

Always use `SingleChildScrollView + Row` for horizontal scrolling inside dialogs.
```dart
// WRONG — crashes inside AlertDialog:
SizedBox(
  height: 48,
  child: ListView.builder(...),
)

// CORRECT:
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(children: [...]),
)
```

## Firestore fromFirestore — Nullable Fields in Global Documents

Global documents (seeded via script) may have different schemas than user-created documents.
Always use null-safe fallback for fields that may be missing in global records.
```dart
// WRONG — crashes if field missing in global document:
createdAt: (data['createdAt'] as Timestamp).toDate(),

// CORRECT:
createdAt: data['createdAt'] != null
    ? (data['createdAt'] as Timestamp).toDate()
    : DateTime.fromMillisecondsSinceEpoch(0),

```

---

