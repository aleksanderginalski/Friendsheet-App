# Friendsheet 📱

> Track your meetings with friends and generate insightful statistics

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 About

Friendsheet is a mobile application that helps you track meetings with friends and analyze your social patterns. Built with Flutter and Firebase, it offers a simple and intuitive way to remember who you spend time with and what activities you enjoy together.


## ✨ Features

### MVP (Current Development)
- ✅ **Complete:** Project setup and Clean Architecture structure
- ✅ **Complete:** Firebase integration (US-002)
- ⏳ **Next:** Git & CI/CD configuration (US-003)
- ⏳ **Planned:** User authentication (Firebase Auth)
- ⏳ **Planned:** Add meetings with participants and activities
- ⏳ **Planned:** Meeting weight system (Fibonacci scale: 1, 2, 3, 5, 8, 13, 21)

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

4. **Run the app**
```powershell
flutter run
```


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
✅ All tests passing (1/1)
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
- `lib/firebase_options.dart` - Firebase API keys

**Never commit these files to version control!** Each developer must create their own Firebase project and configuration files.
