# Friendsheet 📱

> Track your meetings with friends and generate insightful statistics

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 About

Friendsheet is a mobile application that helps you track meetings with friends and analyze your social patterns. Built with Flutter and Firebase, it offers a simple and intuitive way to remember who you spend time with and what activities you enjoy together.


## ✨ Features

### MVP (Current Development)
- ✅ **Complete:** Project setup and Clean Architecture structure (US-001)
- ✅ **Complete:** Firebase integration (US-002)
- ✅ **Complete:** Git & CI/CD configuration (US-003)
- ✅ **Complete:** Google Sign-In authentication (US-004)
- ✅ **Complete:** User logout with Dependency Injection refactor (US-006)
- ✅ **Complete:** Meeting Model (US-007)
- ✅ **Complete:** Person Model (US-008)
- ✅ **Complete:** Activity Model (US-009)
- ✅ **Complete:** Add Meeting Screen UI with Provider scaffold (US-010)
- ✅ **Complete:** Meeting Name & Date Input with validation (US-011)
- ✅ **Complete:** Meeting weight selector - Fibonacci stepper (US-012)
- ✅ **Complete:** Participant Management - autocomplete, chips, add new person (US-013)
- ✅ **Complete:** Activity Management - autocomplete, chips, add new activity (US-014)


### Planned (Future Phases)
- 📊 Statistics and insights
- 📋 Meeting history view
- ✏️ Edit and delete meetings
- 🔍 Advanced search and filters
- 📱 iOS support

## �️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:
```
lib/
├── core/           # Core utilities, constants, errors
├── data/           # Data layer (models, repositories, datasources)
├── domain/         # Business logic layer (entities, use cases)
├── presentation/   # UI layer (screens, widgets, providers)
├── main.dart       # Application entry point
└── firebase_options.dart  # Firebase configuration
```

**Tech Stack:**
- **Frontend:** Flutter 3.0+ (Dart)
- **Backend:** Firebase (Auth + Firestore)
- **Architecture:** Clean Architecture / MVVM
- **State Management:** Provider

## 📚 Documentation

Comprehensive documentation is available in the project root:

- [Requirements Documentation](friendsheet_requirements.md) - Functional and non-functional requirements
- [Architecture Documentation](architecture.md) - System design and diagrams
- [UI/UX Documentation](wireframes.md) - Screen designs and user flows
- [Code Examples](code_snippets.md) - Implementation snippets
- [Project Structure](PROJECT_STRUCTURE.md) - Folder organization
- [Product Backlog](BACKLOG.md) - Sprint planning and user stories

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
cd friendsheet
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
e. Create `lib/firebase_options.dart` with your Firebase configuration

**Note:** `google-services.json` and `firebase_options.dart` are gitignored for security. You must create your own Firebase project.

5.  **Create firebase_options.dart**

You need to create your own Firebase configuration:

a. If using FlutterFire CLI (recommended):
```bash
flutterfire configure
```

b. Or copy the example template and fill in your credentials:
```bash
# Copy template
cp lib/firebase_options.example.dart lib/firebase_options.dart

# Edit lib/firebase_options.dart with your Firebase project details
```

**Note:** The `firebase_options.example.dart` file contains mock credentials for CI/CD. Never commit your real `firebase_options.dart` file.

5. **Run the app**


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
✅ All tests passing (2/2)
✅ No linting issues
✅ Code formatted correctly
✅ Firebase connected successfully
✅ CI/CD pipeline operational
```

## 📱 Supported Platforms

- ✅ **Android** - API 21+ (Android 5.0) - Current focus

## 🗂️ Project Structure
```
friendsheet/
├── lib/
│   ├── core/
│   │   ├── constants/      # App-wide constants
│   │   ├── errors/         # Error handling
│   │   └── utils/          # Utility functions
│   ├── data/
│   │   ├── models/         # Data models
│   │   ├── repositories/   # Repository implementations
│   │   └── datasources/    # Firebase datasources
│   ├── domain/
│   │   ├── entities/       # Business entities
│   │   ├── repositories/   # Repository interfaces
│   │   └── usecases/       # Business use cases
│   ├── presentation/
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable widgets
│   │   └── providers/      # State management
│   ├── main.dart           # App entry point
│   └── firebase_options.dart  # Firebase configuration
├── android/
│   └── app/
│       ├── google-services.json  # Firebase config (gitignored)
│       └── build.gradle
├── test/                   # Unit and widget tests
├── pubspec.yaml            # Dependencies
├── analysis_options.yaml   # Linting rules
└── README.md              # This file
```

## 🎨 Code Style

This project follows Flutter's official style guide and uses `flutter_lints` for code quality.

**Key conventions:**
- Use `const` constructors where possible
- Prefer single quotes for strings
- Use trailing commas for better formatting
- Keep files focused and under 300 lines
- Document public APIs with /// comments

## 🤝 Contributing

This is currently a learning project. Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI components
- Clean Architecture pattern by Uncle Bob

## 📧 Contact

Project Link: [https://github.com/aleksanderginalski/friendsheet-app](https://github.com/aleksanderginalski/friendsheet-app)

---

**Made with ❤️ and Flutter**

**Note:** This is a learning project to understand SDLC (Software Development Life Cycle) and mobile app development with Flutter.

## 📖 Version History

### v1.11.0 - Sprint 2, US-014 (February 19, 2026)
- ✅ Firestore Security Rules updated to allow global activity reads
- ✅ ActivityRepository with global and private activity support
- ✅ AddMeetingProvider extended with activities state and validation
- ✅ ActivityAutocomplete widget with AddActivityDialog
- ✅ AddMeetingScreen - activities placeholder replaced with working widget
- ✅ searchActivities logic moved from repository to provider
- ✅ 10 new provider tests, 30 total in AddMeetingProvider test file

### v1.10.0 - Sprint 2, US-013 (February 19, 2026)
- ✅ PersonRepository with getPersonsByUser and addPerson methods
- ✅ AddMeetingProvider extended with participant state management
- ✅ PersonAutocomplete widget with search suggestions and chip display
- ✅ AddPersonDialog with automatic first/last name split
- ✅ AddMeetingScreen migrated to StatefulWidget for loadPersons on init
- ✅ Fix: full name input split into firstName/lastName on dialog open
- ✅ MockPersonRepository injected in tests to avoid Firebase dependency
- ✅ 20 provider tests (100% passing), 97 total tests

### v1.9.0 - Sprint 2, US-012 (February 19, 2026)
- ✅ MeetingWeightStepper widget with +/− buttons
- ✅ Fibonacci values only (1,2,3,5,8,13,21) via index-based navigation
- ✅ Buttons disabled at min (1) and max (21) boundaries
- ✅ AddMeetingProvider refactored from raw int to index-based weight
- ✅ 15 new tests (5 widget + 10 provider), 77 total tests

### v1.8.0 - Sprint 2, US-011 (February 19, 2026)
- ✅ MeetingNameField widget with character counter (X/50)
- ✅ Focus-loss validation for meeting name field
- ✅ MeetingDateField widget with DatePicker (dd/MM/yyyy format)
- ✅ Default date set to today
- ✅ AddMeetingProvider extended with name validation logic
- ✅ AddMeetingScreen placeholders replaced with real widgets
- ✅ 11 widget tests (100% passing), 62 total tests

### v1.7.0 - Sprint 2, US-010 (February 19, 2026)
- ✅ AddMeetingScreen UI with ScrollView layout
- ✅ All form sections as placeholders (Name, Date, Weight, Participants, Activities)
- ✅ AddMeetingProvider with ChangeNotifier scaffold
- ✅ Navigation from HomeScreen to AddMeetingScreen
- ✅ Save button disabled with user info until US-015
- ✅ 5 widget tests (100% passing)

### v1.6.0 - Sprint 2, US-009 (February 19, 2026)
- ✅ Activity Model implemented with Freezed
- ✅ Global/private activity pattern (isGlobal + userId: null)
- ✅ categoryId field as String? (foundation for US-019 categories)
- ✅ Firestore and JSON serialization
- ✅ 13 unit tests (100% coverage)
- ✅ Architecture updated: activity_categories collection designed
- ✅ Scope split: US-019 (categories) + US-020 (global library) created

### v1.5.0 - Sprint 2, US-008 (February 18, 2026)
- ✅ Person Model implemented with Freezed
- ✅ fullName getter with optional lastName support
- ✅ Firestore and JSON serialization
- ✅ 11 unit tests (100% coverage)
- ✅ Test folder structure reorganized to mirror lib/ structure

### v1.4.0 - Sprint 2, US-007 (February 18, 2026)
- ✅ Meeting Model implemented with Freezed
- ✅ Freezed + json_serializable integration
- ✅ Data models structure in lib/data/models/
- ✅ 12 unit tests for Meeting model (100% coverage)
- ✅ Build runner configuration
- ✅ Firestore and JSON serialization patterns established

### v1.3.0 - Sprint 1, US-006 (February 17, 2026)
- ✅ User logout implemented (Google + Firebase sign out)
- ✅ Dependency Injection introduced for AuthService
- ✅ AuthWrapper refactored - accepts AuthService as parameter
- ✅ LoginScreen refactored - accepts AuthService as parameter
- ✅ HomeScreen refactored - accepts AuthService as parameter
- ✅ Widget tests for AuthWrapper auth state routing
- ✅ MockAuthService generated with Mockito

### v1.2.1 - Sprint 1, US-004 (February 16, 2026)
- ✅ Google Sign-In authentication implemented
- ✅ AuthService with Singleton pattern
- ✅ LoginScreen with Google Sign-In button
- ✅ HomeScreen with user info and logout
- ✅ AuthWrapper for automatic auth state management
- ✅ Manual navigation after successful login
- ✅ Firebase packages updated to latest compatible versions

### v1.2.0 - Sprint 1, US-003 (February 14, 2026)
- ✅ Git repository configured
- ✅ GitHub repository created with branch protection
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Automated testing on Pull Requests
- ✅ Code quality checks (format, analyze, test)

### v1.1.0 - Sprint 1, US-002 (February 14, 2026)
- ✅ Firebase project created and configured
- ✅ Firebase Authentication integrated
- ✅ Cloud Firestore database enabled
- ✅ Security rules configured
- ✅ firebase_options.dart generated
- ✅ Connection to Firebase verified

### v1.0.0 - Sprint 1, US-001 (February 12, 2026)
- ✅ Initial Flutter project setup
- ✅ Clean Architecture structure implemented
- ✅ Development dependencies configured
- ✅ Linting rules established
- ✅ Basic placeholder UI created
- ✅ Widget tests added

## 🔐 Security Notes

**Important:** The following files contain sensitive information and are gitignored:
- `android/app/google-services.json` - Firebase configuration
- `lib/firebase_options.dart` - Firebase API keys (your real credentials)

**Mock files for CI (safe to commit):**
- `lib/firebase_options.example.dart` - Template with fake credentials for CI/CD

**Never commit your real firebase_options.dart!** Each developer must create their own Firebase project and configuration files.