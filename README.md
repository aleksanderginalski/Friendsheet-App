# Sekcje do zastąpienia w README.md

---

## 🗺️ Roadmap

| Milestone | Name | Status |
|-----------|------|--------|
| M1 | Add Meeting | ✅ Completed |
| M2 | Management & CRUD | ✅ Completed |
| M3 | Statistics & Export | ✅ Completed |
| M3.5 | Visual Design & Brand Identity | ✅ Completed |
| M4 | Google Play Release | ✅ Completed |
| M5 | Meeting Import Hub | 🔄 In Progress |
| M6 | Custom Dashboard | 📋 Planned |
| M7 | AI Assistant | 🔄 In Progress |

**M2 — Management & CRUD:** Full CRUD for meetings, persons and activities. Meetings list grouped by year and month. Activity categories with icons and 2-level hierarchy. Friend groups for organising contacts.

**M3 — Statistics & Export:** Activity breakdown, who-per-activity and interaction distribution charts with animated bars. Year stepper with offline-first Hive cache. JSON data export.

**M3.5 — Visual Design & Brand Identity:** Custom app icon, splash screen, Nunito typography, green/amber design system, empty state illustrations, friend groups UI.

**M4 — Google Play Release:** Production build with release signing, store assets, Privacy Policy, Google Play Internal Testing track. Portfolio milestone.

**M5 — Meeting Import Hub:** Google Calendar import — browse past events, review candidates in Meeting Inbox, confirm as meetings. Peer-to-peer sharing: generate sharing token (US-089) so a friend can share their meetings with you; enter a friend's token to link their Friendsheet account to their Person profile (US-090). Receive shared meeting packages in Pending Meetings with full conflict resolution — date duplicates (US-092), activity name conflicts and person name conflicts (US-093), fuzzy near-duplicate activity detection with normalized Levenshtein distance (US-094). Sender is automatically added as a contact and participant in all imported meetings — their self-declared nickname is suggested and saved automatically (US-096). Merge duplicate activity categories to clean up history without data loss (US-095). Extensible architecture supports future import sources (Google Photos planned).

**M6 — Custom Dashboard:** Configurable home screen with drag-and-drop metric widgets.

**M7 — AI Assistant:** Buddy — an AI chat assistant powered by OpenAI (BYOK). US-087 delivered the full chat screen with streaming responses, pseudonym back-translation, and write isolation via `BuddyWriteService`. US-101 added the proactive HomeScreen widget (floating Buddy icon with contextual CTAs). US-103 added birthday data to Person. US-104 delivered birthday reminders: Buddy detects upcoming birthdays, generates Dart-computed friendship stats, and streams a personalized AI birthday wish; "Save Your Memories" shows top-3 meetings without notes as in-chat action buttons. US-102 added proactive LTNS insights: "Long time no see" button for friends absent 90+ days; greeting/lapsedFriendsList/lapsedFriendDetail chat modes; Side Menu "Buddy" tile navigating to a dedicated sub-screen; AIChatScreen AppBar uses Pacifico font. US-109 delivered the full-dataset local Hive cache (`LocalCacheService`): fire-and-forget sync on app start, write-through after every repository write, 8 typed read methods — all one-shot Firestore reads now cache-first. US-105 added meeting frequency context: `PersonContextEntry` carries `avgDaysBetweenMeetings` and `daysSinceLastMeeting`; system prompt guides Buddy to suggest overdue friends. US-118 added LTNS Exclusion Filter: `LtnsExclusionService` + `LtnsFilterScreen` allow opt-out of specific friends from LTNS reminders; action buttons show full name and meeting frequency. US-107 added Relationship Strength Indicator: `RelationshipScoreService` computes a 0–100 score (frequency/recency/variety/weight variety) from the Hive cache; `RelationshipStrengthWidget` shows a colored progress bar on `PersonDetailScreen`; `serializeToPromptWithScores` appends per-person partial scores so Buddy can explain them; smart person name disambiguation — when a user types a real name Buddy resolves it via substring match and shows disambiguation buttons with scores if multiple persons match. Remaining US: widget auto-refresh (US-112), language selection (US-113).

---

## 📚 Documentation

Comprehensive documentation is available in the [`docs/`](docs/) folder:

- [Requirements Documentation](docs/requirements.md) — Functional and non-functional requirements
- [Architecture Documentation](docs/architecture.md) — System design and diagrams
- [UI/UX Documentation](docs/wireframes.md) — Screen designs and user flows
- [Design Brief](docs/friendsheet_design_brief.md) — Visual identity, color palette and typography guidelines
- [Test Cases](docs/TEST_CASES.md) — Manual test cases
- [Code Examples](docs/code_snippets.md) — Implementation snippets
- [Project Structure](docs/PROJECT_FILES.md) — Full file inventory
- [Product Backlog](docs/BACKLOG.md) — Sprint planning and user stories
- [Version History](CHANGELOG.md) — Full changelog

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK:** 3.0 or higher
- **Dart:** 2.17 or higher
- **Android Studio** or **VS Code** with Flutter plugins
- **Android Emulator** or physical Android device
- **Git** for version control
- **Firebase Account** (free tier)

### Installation

1. **Clone the repository**
```powershell
git clone https://github.com/aleksanderginalski/friendsheet-app.git
cd friendsheet-app
```

2. **Install dependencies**
```powershell
flutter pub get
```

3. **Firebase Setup**

You need to set up your own Firebase project:

   a. Create a Firebase project at https://console.firebase.google.com  
   b. Add an Android app with package name: `com.friendsheet.app`  
   c. Download `google-services.json`  
   d. Place it in: `android/app/google-services.json`  
   e. Run `flutterfire configure` to generate `lib/firebase_options.dart`

   **Note:** `google-services.json` and `firebase_options.dart` are gitignored for security. You must create your own Firebase project.

4. **Run the app**
```powershell
flutter run
```

---

## 🧪 Testing

```powershell
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run static analysis
flutter analyze

# Check code formatting
flutter format --set-exit-if-changed .
```

**Current Test Status:**
```
✅ All tests passing (1015)
✅ Code formatted correctly
✅ Firebase connected successfully
✅ CI/CD pipeline operational
```

---

## 📱 Supported Platforms

- ✅ **Android** — API 21+ (Android 5.0) — current focus
- 🔄 **Google Play** — Internal Testing track active

---

## 🎨 Code Style

This project follows Flutter's official style guide and uses `flutter_lints` for code quality.

**Key conventions:**
- Use `const` constructors where possible
- Prefer single quotes for strings
- Use trailing commas for better formatting
- Keep files focused and under 300 lines
- Document public APIs with `///` comments
- Code comments and documentation in English only

---

## 🤝 Contributing

This is a personal portfolio project. If you'd like to contribute or have ideas, please **reach out to me first** before opening a pull request — I'd love to hear from you.

📧 Contact via GitHub: [@aleksanderginalski](https://github.com/aleksanderginalski)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI components
- Anthropic Claude for AI-assisted development workflow

---

## 📧 Contact

Project Link: [https://github.com/aleksanderginalski/Friendsheet-App](https://github.com/aleksanderginalski/Friendsheet-App)

---

**Made with ❤️ and Flutter**

*This project documents a full SDLC journey — from backlog and architecture through implementation, testing and Google Play release.*

## 📖 Version History

Full version history is available in [CHANGELOG.md](CHANGELOG.md).

### Latest: v4.5.12 — US-125: Friends-Quest Tasks (April 20, 2026)
- ✅ `FriendsQuestTask` (MODIFIED) — `contextLabel` and `sourcePersonId` fields added
- ✅ `FriendsQuestRepository` (MODIFIED) — `updateQuest()`; deep Hive cast fix via json round-trip
- ✅ `FriendsQuestProvider` (MODIFIED) — `addTask`, `editTask`, `deleteTask`, `updateParticipants`, `_importTopicsForQuest` with couple-deduplication
- ✅ `FriendsQuestDetailScreen` (NEW) — task list, add/edit dialogs, participant management bottom sheet
- ✅ `QuestTaskTile` (NEW) — task row with read-only checkbox, subtitle, edit/delete actions
- ✅ `QuestParticipantsSection` (NEW) — participant management widget for bottom sheet
- ✅ 14 new tests (1015 total)

See [CHANGELOG.md](CHANGELOG.md) for all previous versions.

## 🔐 Security Notes

**Important:** The following files contain sensitive information and are gitignored:
- `android/app/google-services.json` - Firebase configuration
- `lib/firebase_options.dart` - Firebase API keys (your real credentials)

**Never commit your real firebase_options.dart!** Each developer must create their own Firebase project and configuration files.
