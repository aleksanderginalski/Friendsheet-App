# Changelog

All notable changes to the Friendsheet project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- User authentication (Firebase Auth)
- Add meeting functionality
- Meeting participants management
- Activity tracking
- Meeting weight system (Fibonacci: 1, 2, 3, 5, 8, 13, 21)

## [1.1.0] - 2026-02-14

### Added
- Firebase project integration
- Cloud Firestore database configuration
- Firebase Authentication setup
- `firebase_options.dart` configuration file
- Security rules for Firestore
- Firebase connection verification in main.dart

### Changed
- Updated main.dart to initialize Firebase on app start
- Added Firebase packages to pubspec.yaml (firebase_core, firebase_auth, cloud_firestore)

### Fixed
- Package name inconsistency (standardized to com.friendsheet.app)
- File permissions issues on Windows
- Firebase initialization error handling

### Security
- Added google-services.json to .gitignore
- Added firebase_options.dart to .gitignore
- Configured Firestore Security Rules for user data isolation

## [1.0.0] - 2026-02-12

### Added
- Initial Flutter project setup
- Clean Architecture folder structure
  - core/ - Core utilities and constants
  - data/ - Data layer (models, repositories, datasources)
  - domain/ - Business logic layer (entities, use cases)
  - presentation/ - UI layer (screens, widgets, providers)
- Development dependencies
  - flutter_lints for code quality
  - provider for state management
  - intl for date formatting
- Linting rules (analysis_options.yaml)
- Basic placeholder UI with Material Design 3
- Widget tests foundation
- Comprehensive project documentation
  - README.md
  - friendsheet_requirements.md
  - architecture.md
  - wireframes.md
  - code_snippets.md
  - PROJECT_STRUCTURE.md
  - BACKLOG.md

### Technical Details
- Flutter SDK: 3.0+
- Dart: 2.17+
- Target Platform: Android (API 21+)
- Architecture: Clean Architecture / MVVM
- State Management: Provider

## Sprint Progress

### Sprint 1 - Project Setup & Auth Foundation (In Progress)
- ✅ US-001: Initialize Flutter Project (5 pts) - COMPLETE
- ✅ US-002: Setup Firebase (5 pts) - COMPLETE
- ⏳ US-003: Configure Git & CI/CD (3 pts) - NEXT
- ⏳ US-004: User Registration (8 pts) - PLANNED

**Sprint 1 Progress:** 10/21 story points completed (47%)

---

## Version Naming Convention

- **Major version (X.0.0)**: Major milestones (MVP release, major features)
- **Minor version (1.X.0)**: New features, sprint completions
- **Patch version (1.1.X)**: Bug fixes, minor improvements

## Git Commit Types

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

## Example Commit Messages

- `feat: add Firebase integration (US-002)`
- `fix: resolve package name inconsistency`
- `docs: update README with Firebase setup instructions`
- `test: add unit tests for Meeting model`
- `chore: update dependencies to latest versions`
