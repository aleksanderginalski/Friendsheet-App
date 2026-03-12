# Friendsheet - Product Backlog

**Project:** Friendsheet  
**Version:** 2.1  
**Last Updated:** March 05, 2026  
**Product Owner:** Aleksander Ginalski  

---

## 📊 Backlog Overview

| Milestone | Name | Status |
|-----------|------|--------|
| M1 | Add Meeting | ✅ COMPLETED |
| M2 | Management & CRUD | ✅ COMPLETED |
| M3 | Statistics & Export | ✅ COMPLETED |
| M3.5 | Visual Design & Brand Identity | 🔄 In Progress |
| M4 | Google Play Release | 📋 Planned |
| M5 | Meeting Import Hub | 📋 Planned |
| M6 | Custom Dashboard | 📋 Planned |
| M7 | AI Assistant | 💡 Future |
---

## 🎯 Epic Structure

```
EPIC-001: Friendsheet M1 - Add Meeting 
├── FEATURE-001: Project Infrastructure Setup ✅
├── FEATURE-002: User Authentication ✅
├── FEATURE-003: Data Models ✅
├── FEATURE-004: Add Meeting Feature ✅
└── FEATURE-005: Testing & Quality Assurance ✅

EPIC-002: Friendsheet M2 - Management & CRUD ✅
├── FEATURE-006: Meetings View ✅
├── FEATURE-007: Persons View ✅
└── FEATURE-008: Activities View & Categories ✅

EPIC-003: Friendsheet M3 - Statistics & Export
├── FEATURE-016: Data Import ✅
└── FEATURE-009: Core Statistics ✅
└── FEATURE-010: Data Export ✅
└── FEATURE-017: Sideload Release ✅

EPIC-009: Friendsheet M3.5 - Visual Design & Brand Identity
├── FEATURE-018: Design System & Theme ✅
├── FEATURE-019: App Assets (Icon + Splash) ✅
└── FEATURE-020: Illustrations & Empty States

EPIC-004: Friendsheet M4 - Google Play Release
└── FEATURE-011: Store Release Preparation

EPIC-005: Friendsheet M5 - Meeting Import Hub
├── FEATURE-013: Google Calendar Import      ← before Google Play
├── FEATURE-014: Google Photos Import        ← post Google Play, backlog
└── FEATURE-012: Invitation Code System

EPIC-006: Friendsheet M6 - Custom Dashboard
└── FEATURE-015: Configurable Metrics Dashboard

EPIC-007: Friendsheet M7 - AI Assistant
└── FEATURE-016-AI: AI-powered Insights
```



# 📦 EPIC-001: Friendsheet MVP

**Goal:** Deliver minimum viable product allowing users to add meetings with friends

**Business Value:** Enable users to track social interactions and lay foundation for future statistics features
**Status:** ✅ COMPLETED 
---

## 🔧 FEATURE-001: Project Infrastructure Setup
**Priority:** P0 (Critical - Foundation)  
**Sprint:** Sprint 1  
**Total Points:** 13  
**Role:** DevOps + Developer
**Status:** ✅ COMPLETED 

### US-001: Initialize Flutter Project

**As a** Developer  
**I want to** have a properly structured Flutter project  
**So that** I can start implementing features with clean architecture
**Status:** ✅ COMPLETED 
**Story Points:** 5  
**Priority:** P0

**Acceptance Criteria:**
- [x] Flutter project created with latest stable version (3.0+)
- [x] Project follows Clean Architecture folder structure
- [x] `pubspec.yaml` configured with initial dependencies
- [x] `analysis_options.yaml` configured with linting rules
- [x] Project runs successfully on Android emulator
- [x] README.md updated with setup instructions

**Tasks:**
- [x] **TASK-001:** Create Flutter project (`flutter create friendsheet`) - 1h
- [x] **TASK-002:** Setup folder structure (core/, data/, domain/, presentation/) - 1h
- [x] **TASK-003:** Configure `pubspec.yaml` dependencies - 30min
- [x] **TASK-004:** Configure `analysis_options.yaml` linting - 30min
- [x] **TASK-005:** Test project on Android emulator - 30min
- [x] **TASK-006:** Update documentation - 30min

**Definition of Done:**
- Code passes linting (`flutter analyze`)
- Project builds without errors
- Runs on Android emulator
- Code reviewed and merged to main branch
- Documentation updated

---

### US-002: Setup Firebase

**As a** Developer  
**I want to** integrate Firebase into the Flutter project  
**So that** I can use Authentication and Firestore services
**Status:** ✅ COMPLETED 
**Story Points:** 5  
**Priority:** P0

**Acceptance Criteria:**
- [x] Firebase project created in Firebase Console
- [x] Android app registered in Firebase project
- [x] `google-services.json` downloaded and added to project
- [x] Firebase Core, Auth, and Firestore packages added to `pubspec.yaml`
- [x] Firebase initialized in `main.dart`
- [x] Connection to Firebase verified (test write to Firestore)
- [x] Firestore Security Rules configured for user data isolation

**Tasks:**
- [x] **TASK-007:** Create Firebase project in console - 30min
- [x] **TASK-008:** Register Android app in Firebase - 30min
- [x] **TASK-009:** Download and add `google-services.json` - 15min
- [x] **TASK-010:** Add Firebase packages to `pubspec.yaml` - 15min
- [x] **TASK-011:** Initialize Firebase in `main.dart` - 30min
- [x] **TASK-012:** Test Firestore connection - 1h
- [x] **TASK-013:** Configure Firestore Security Rules - 1h
- [x] **TASK-014:** Document Firebase setup process - 30min

**Definition of Done:**
- Firebase successfully initialized
- Test data written to Firestore
- Security rules deployed and tested
- No security warnings in Firebase Console
- Documentation includes Firebase setup steps

---

### US-003: Configure Git & CI/CD

**As a** DevOps Engineer  
**I want to** setup version control and CI/CD pipeline  
**So that** code quality is maintained and deployments are automated
**Status:** ✅ COMPLETED 
**Story Points:** 3  
**Priority:** P1

**Acceptance Criteria:**
- [x] Git repository initialized
- [x] `.gitignore` configured properly
- [x] Initial commit pushed to GitHub
- [x] Branch protection rules configured on main branch
- [x] GitHub Actions workflow created for CI
- [x] CI runs linting and tests on every PR

**Tasks:**
- [x] **TASK-015:** Initialize Git repository - 15min
- [x] **TASK-016:** Configure `.gitignore` - 15min
- [x] **TASK-017:** Create initial commit and push to GitHub - 30min
- [x] **TASK-018:** Configure branch protection rules - 15min
- [x] **TASK-019:** Create GitHub Actions workflow - 1h
- [x] **TASK-020:** Test CI pipeline - 30min

**Definition of Done:**
- Code on GitHub
- CI pipeline running successfully
- Branch protection active
- All team members have access

---

## 🔐 FEATURE-002: User Authentication

**Role:** Developer
**Status:** ✅ COMPLETED 

### US-004: User Registration

**As a** new or returning user  
**I want to** sign in with my Google account  
**So that** I can quickly and securely access the application without creating a new password
**Story Points:** 5
**Status:** ✅ COMPLETED 


**Acceptance Criteria:**
- [x] Login screen UI created with "Sign in with Google" button
- [x] Google Sign-In SDK integrated into Flutter project
- [x] Firebase project configured for Google authentication
- [x] "Sign in with Google" button triggers Google authentication flow
- [x] User can select their Google account from device accounts
- [x] Successful authentication creates/updates user in Firebase Auth
- [x] User's email and display name retrieved from Google account
- [x] User redirected to home screen after successful authentication
- [x] Error messages displayed for authentication failures
- [x] Loading indicator shown during sign-in process
- [x] First-time users automatically "registered"
- [x] Works offline for previously authenticated users

**Tasks:**
- [x] **TASK-021:** Add `google_sign_in` package to `pubspec.yaml` - 15min
- [x] **TASK-022:** Configure Google Sign-In in Firebase Console - 30min
- [x] **TASK-023:** Update `android/app/build.gradle` with required configuration - 30min
- [x] **TASK-024:** Create LoginScreen widget with Google Sign-In button - 1h
- [x] **TASK-025:** Create AuthService with `signInWithGoogle()` method - 2h
- [x] **TASK-026:** Implement Google Sign-In flow (SDK → Firebase Auth) - 2h
- [x] **TASK-027:** Add error handling for authentication failures - 1h
- [x] **TASK-028:** Implement loading state and navigation - 1h
- [x] **TASK-029:** Add auth state persistence - 30min
- [x] **TASK-030:** Write widget tests for LoginScreen - 1h
- [x] **TASK-031:** Write integration test for Google Sign-In flow - 1h

**Challenges:** 
- StreamBuilder not reacting to auth state changes
- Widget lifecycle issues with mounted state
- Required manual navigation after successful login

**Definition of Done:**
- [x] User can sign in with Google successfully
- [x] Authentication persists across app restarts
- [x] Error messages are user-friendly and helpful
- [x] Loading states provide good UX feedback
- [x] Widget and integration tests pass (basic)
- [x] No security vulnerabilities
- [x] Code follows Flutter best practices
- [x] Code reviewed and merged

**Test Scenarios:**
1. ✅ First-time user signs in with Google → Account created, redirected to home
2. ✅ Returning user signs in with Google → Authenticated, redirected to home
3. ❌ User cancels Google sign-in → Returns to login screen with message
4. ❌ Network error during sign-in → Error message displayed
5. ✅ User already authenticated → Automatically logged in on app start
6. ❌ Google Play Services not available → Helpful error message

---

### US-005: Email/Password Login [OBSOLETE - REMOVED FROM MVP]

**Status:** ❌ OBSOLETE  
**Story Points:** 8
**Reason:** Replaced by US-004 (Google Sign-In) for MVP  


**📝 Decision Log:**
- Date: February 14, 2026
- Decision: Use Google Sign-In instead of email/password for MVP
- Rationale: Simpler implementation, better UX, more secure, industry standard
- Future: Email/password can be added post-MVP if needed (Firebase supports multiple providers)

**Note for GitHub Issues:**
If you already created a GitHub issue for US-005, you can:
1. Close it with label "wontfix" or "obsolete"
2. Add comment: "Replaced by Google Sign-In (US-004) for MVP - simpler and more secure"
3. Keep it for reference if you want to implement email/password post-MVP
---

### US-006: User Logout (UPDATED for SSO)

**As a** logged-in user  
**I want to** log out of the application  
**So that** my data is secure when I'm not using the app
**Story Points:** 3 
**Status:** ✅ COMPLETED 

**Acceptance Criteria:**
- [x] Logout button/option visible in app bar or drawer
- [x] Clicking logout signs out user from both Google Sign-In AND Firebase Auth
- [x] User redirected to login screen after logout
- [x] Confirmation dialog shown before logout (optional but recommended)
- [x] All local cached data cleared on logout
- [x] Auth state properly reset
- [x] User needs to re-authenticate to access app again

**Tasks:**
- [x] **TASK-037:** Add logout button to AppBar/Drawer - 30min
- [x] **TASK-038:** Implement `signOut()` method in AuthService (Google + Firebase) - 1h
- [x] **TASK-039:** Add optional confirmation dialog - 30min
- [x] **TASK-040:** Clear app state on logout - 30min
- [x] **TASK-041:** Implement navigation to login screen - 30min
- [x] **TASK-042:** Write tests for logout flow - 30min

**Definition of Done:**
- Logout functionality works correctly
- User is fully signed out (Google + Firebase)
- User redirected to login screen
- App state properly cleared
- Cannot access protected screens after logout
- Tests pass
- Code reviewed

**Test Scenarios:**
1. ✅ User clicks logout → Confirmation shown → Signs out → Redirected to login
2. ✅ User clicks logout → Cancels → Stays logged in
3. ✅ After logout, protected screens are inaccessible
4. ✅ After logout, user must re-authenticate to access app


### 🐛 US-074: Fix — Session Not Restored After App Restart

**As a** returning user
**I want** the app to skip the login screen when I reopen it
**So that** I can access my data immediately without re-authenticating

**Labels:** `bug` `auth` `P0`
**Story Points:** 3
**Priority:** P0
**Status:** 📋 Planned
**Feature:** FEATURE-002: User Authentication
**Epic:** EPIC-001

**Context / Root Cause Area:**
Session restoration fails on every cold start (100% reproducible). The user is never logged out, but the app always shows the login screen. Tapping "Login" bypasses the Google account picker and goes directly to HomeScreen — confirming Firebase still holds a valid token. Root cause is likely `silentSignIn()` not being awaited before routing, or `authStateChanges` stream not being handled before the first frame renders.

**Acceptance Criteria:**
- [ ] Reopening the app after cold start (removed from recents) navigates directly to HomeScreen — no login screen shown
- [ ] Google account picker is NOT triggered during session restore (silent re-auth only)
- [ ] If session is genuinely expired, login screen is shown normally with account picker
- [ ] No regression: explicit logout still works, first-time login still works
- [ ] TC-AUTH-003 passes

**Tasks:**
- [ ] **TASK-074.1:** Audit `AuthService` — verify `silentSignIn()` is called on app start and its result is awaited before routing
- [ ] **TASK-074.2:** Audit `main.dart` / root widget — verify `authStateChanges` stream decision (authenticated → HomeScreen, unauthenticated → LoginScreen) happens before first meaningful frame
- [ ] **TASK-074.3:** Fix routing so a loading/splash state is shown while auth resolves, then navigate without flashing login screen
- [ ] **TASK-074.4:** Update auth restore widget test
- [ ] **TASK-074.5:** Run `flutter analyze` + `flutter test`, report back

**Definition of Done:**
- [ ] Cold start goes directly to HomeScreen — 100% reproducible
- [ ] No login screen flash before HomeScreen
- [ ] TC-AUTH-003 passes
- [ ] `flutter analyze` clean, `flutter test` green


### US-076: Delete Account and All User Data

**As a** user
**I want** to permanently delete my account and all associated data
**So that** I have full control over my personal information

**Labels:** `profile` `gdpr` `P1`
**Story Points:** 8
**Priority:** P1
**Status:** ✅ COMPLETED (March 12, 2026)


**Context:**
Entry point: Side Drawer → Profile → "Delete Account". Full hard-delete required: Firebase Auth account + all Firestore subcollections (`meetings`, `persons`, `activity_categories`, root `users/{uid}` document). Firebase requires re-authentication before sensitive operations — this must be handled. After deletion: navigate to LoginScreen with stack cleared via `pushAndRemoveUntil`.

**Acceptance Criteria:**
- [x] "Delete Account" option visible in Profile section of side drawer
- [x] Tapping it shows a confirmation dialog with clear destructive action warning
- [x] User must re-authenticate with Google before deletion proceeds
- [x] On confirm: all Firestore data deleted — `meetings`, `persons`, `activity_categories` subcollections + root `users/{uid}` document
- [x] Firebase Auth account deleted after Firestore cleanup
- [x] User navigated to LoginScreen with navigation stack cleared
- [x] If deletion fails (network error), error message shown and account is NOT partially deleted
- [x] Loading state shown during deletion

**Tasks:**
- [x] **TASK-076.1:** Add "Delete Account" tile to Profile section in side drawer
- [x] **TASK-076.2:** Create confirmation dialog with destructive styling (red confirm button)
- [x] **TASK-076.3:** Implement `deleteAccount()` in `AuthService`: re-authenticate → delete Firestore subcollections → delete Auth account
- [x] **TASK-076.4:** Implement Firestore subcollection deletion (meetings, persons, activity_categories, root user doc) — sequential with per-step error handling
- [x] **TASK-076.5:** Ensure no partial deletion on failure — surface error and halt if any step fails
- [x] **TASK-076.6:** Navigate to LoginScreen with `pushAndRemoveUntil` on success
- [x] **TASK-076.7:** Write unit tests for `deleteAccount()` logic
- [x] **TASK-076.8:** Run `flutter analyze` + `flutter test`, report back

**Definition of Done:**
- [x] Full deletion flow works end-to-end on device
- [x] Firestore data confirmed deleted in Firebase Console after flow
- [x] Firebase Auth account confirmed deleted after flow
- [x] Error handling works (simulate network failure — no partial state)
- [x] `flutter analyze` clean, `flutter test` green

---

## 💾 FEATURE-003: Data Models

**Role:** Developer + Solution Architect
**Status:** ✅ COMPLETED 


### US-007: Meeting Model

**As a** Developer  
**I want to** have a Meeting data model  
**So that** I can represent meeting data in the application
**Story Points:** 5
**Status:** ✅ COMPLETED (February 18, 2026)

**Acceptance Criteria:**
- [x] Meeting class created with all required fields
- [x] fromFirestore factory constructor implemented
- [x] toMap method for Firestore serialization
- [x] isValid validation method
- [x] copyWith method for immutability
- [x] Proper null safety handling
- [x] Unit tests for all methods



**Tasks:**
- [x] **TASK-043:** Create Meeting class in `lib/data/models/meeting.dart` - 1h
- [x] **TASK-044:** Implement fromFirestore factory - 1h
- [x] **TASK-045:** Implement toMap serialization - 1h
- [x] **TASK-046:** Add validation logic - 1h
- [x] **TASK-047:** Write comprehensive unit tests - 1h

**Definition of Done:**
- All methods implemented
- Unit tests pass with >90% coverage
- Documentation comments added
- Code reviewed

**Fields:**
```dart
- id: String
- userId: String
- name: String (max 50 chars)
- date: DateTime
- weight: int (1,2,3,5,8,13,21)
- participantIds: List<String>
- activityIds: List<String>
- createdAt: DateTime
- updatedAt: DateTime
```

---

### US-008: Person Model

**As a** Developer  
**I want to** have a Person data model  
**So that** I can represent participant data
**Story Points:** 3 
**Status:** ✅ COMPLETED 

**Acceptance Criteria:**
- [x] Person class created with required fields
- [x] Serialization methods implemented
- [x] fullName getter for display
- [x] Validation method
- [x] Unit tests

**Tasks:**
- [x] **TASK-048:** Create Person class - 1h
- [x] **TASK-049:** Implement serialization - 1h
- [x] **TASK-050:** Add fullName getter - 30min
- [x] **TASK-051:** Write unit tests - 1h

**Definition of Done:**
- Model implemented
- Tests pass
- Code reviewed

---

### US-009: Activity Model

**As a** Developer  
**I want to** have an Activity data model  
**So that** I can represent activity data
**Story Points:** 3 
**Status:** ✅ COMPLETED 

**Acceptance Criteria:**
- [x] Activity class created
- [x] Serialization implemented
- [x] Validation added
- [x] Unit tests written

**Tasks:**
- [x] **TASK-052:** Create Activity class - 1h
- [x] **TASK-053:** Implement serialization - 1h
- [x] **TASK-054:** Add validation - 1h
- [x] **TASK-055:** Write unit tests - 1h
- [x] **TASK-056:** Create repository interface - 1h

**Definition of Done:**
- Model complete
- Tests pass
- Code reviewed

---

## ➕ FEATURE-004: Add Meeting Feature

**Role:** Developer + UX Designer
**Status:** ✅ COMPLETED 


### US-010: Add Meeting Screen UI

**As a** Developer  
**I want to** create the Add Meeting screen layout  
**So that** users have a UI to input meeting data

**Story Points:** 5  
**Priority:** P0
**Status:** ✅ COMPLETED (February 19, 2026)

**Acceptance Criteria:**
- [x] Screen follows wireframe design
- [x] AppBar with title "Add Meeting"
- [x] All input fields visible and properly styled
- [x] ScrollView for small screens
- [x] Material Design 3 components used
- [x] Responsive layout

**Tasks:**
- [x] **TASK-057:** Create AddMeetingScreen scaffold - 1h
- [x] **TASK-058:** Add AppBar - 30min
- [x] **TASK-059:** Create form layout with SingleChildScrollView - 1h
- [x] **TASK-060:** Style components with Material Design 3 - 1h
- [x] **TASK-061:** Test on different screen sizes - 1h

**Definition of Done:**
- UI matches wireframe
- Responsive on different screens
- Passes accessibility checks
- Code reviewed

---

### US-011: Meeting Name & Date Input

**As a** user  
**I want to** enter meeting name and select date  
**So that** I can specify when and what the meeting was
**Status:** ✅ COMPLETED (February 19, 2026)
**Story Points:** 3 
**Acceptance Criteria:**
- [x] Name TextField with 50 character limit
- [x] Character counter displayed (X/50)
- [x] Date picker integrated
- [x] Default date is today
- [x] Validation: name required, date required
- [x] Error messages for invalid input

**Tasks:**
- [x] **TASK-062:** Implement name TextField - 1h
- [x] **TASK-063:** Add character counter - 30min
- [x] **TASK-064:** Integrate date picker - 1h
- [x] **TASK-065:** Add validation logic - 30min
- [x] **TASK-066:** Write widget tests - 1h

**Definition of Done:**
- Inputs work correctly
- Validation functional
- Tests pass

---

### US-012: Meeting Weight Selector

**As a** user  
**I want to** select meeting importance using a weight scale  
**So that** I can indicate how significant the meeting was
**Status:** ✅ COMPLETED (February 19, 2026)
**Story Points:** 5

**Acceptance Criteria:**
- [x] Custom stepper widget created
- [x] Only allows Fibonacci values (1,2,3,5,8,13,21)
- [x] Plus/minus buttons
- [x] Current value displayed prominently
- [x] Buttons disabled at min/max values
- [x] Default value is 3

**Tasks:**
- [x] **TASK-067:** Create MeetingWeightStepper widget - 2h
- [x] **TASK-068:** Implement increment/decrement logic - 1h
- [x] **TASK-069:** Style and visual feedback - 1h
- [x] **TASK-070:** Write widget tests - 1h

**Definition of Done:**
- Widget works as designed
- Visual feedback clear
- Tests pass
- Reusable component

---

### US-013: Participant Management

**As a** user  
**I want to** add participants to my meeting  
**So that** I can track who I met with

**Story Points:** 8  
**Priority:** P0
**Status:** ✅ COMPLETED (February 19, 2026)
**Acceptance Criteria:**
- [x] Autocomplete field for searching existing persons
- [x] "Add new person" option when no match
- [x] Dialog to add new person (firstName, lastName)
- [x] Selected persons displayed as chips
- [x] Ability to remove selected person (X button)
- [x] Minimum 1 participant required
- [x] No duplicate participants allowed

**Tasks:**
- [x] **TASK-071:** Create PersonRepository with search - 2h
- [x] **TASK-072:** Implement PersonAutocomplete widget - 2h
- [x] **TASK-073:** Create AddPersonDialog - 1h
- [x] **TASK-074:** Implement chip display for selected persons - 1h
- [x] **TASK-075:** Add validation and duplicate check - 1h
- [x] **TASK-076:** Write tests - 1h

**Definition of Done:**
- Autocomplete functional
- Can add new persons
- Validation works
- Tests pass

---

### US-014: Activity Management

**As a** user  
**I want to** add activities to my meeting  
**So that** I can remember what we did
**Status:** ✅ COMPLETED (February 19, 2026)

**Story Points:** 8  
**Priority:** P0

**Acceptance Criteria:**
- [x] Autocomplete for existing activities
- [x] "Add new activity" option
- [x] Dialog to create new activity
- [x] Selected activities shown as chips
- [x] Remove activity option
- [x] Minimum 1 activity required
- [x] No duplicate activities

**Tasks:**
- [x] **TASK-077:** Create ActivityRepository - 2h
- [x] **TASK-078:** Implement ActivityAutocomplete - 2h
- [x] **TASK-079:** Create AddActivityDialog - 1h
- [x] **TASK-080:** Display chips - 1h
- [x] **TASK-081:** Add validation - 1h
- [x] **TASK-082:** Write tests - 1h

**Definition of Done:**
- Autocomplete works
- Can add new activities
- Validation functional
- Tests pass

---

### US-015: Save Meeting to Firestore

**As a** user  
**I want to** save my meeting  
**So that** it's stored securely in the cloud
**Status:** ✅ COMPLETED (February 19, 2026)

**Acceptance Criteria:**
- [x] Form validation before save
- [x] Meeting object created from form data
- [x] MeetingRepository saveMeeting method called
- [x] Loading indicator during save
- [x] Success message on successful save
- [x] Error message on failure
- [x] Form cleared after successful save
- [x] Navigation back or to home

**Tasks:**
- [x] **TASK-083:** Create MeetingRepository - 2h
- [x] **TASK-084:** Implement save logic in AddMeetingScreen - 1h
- [x] **TASK-085:** Add loading state - 30min
- [x] **TASK-086:** Implement success/error handling - 1h
- [x] **TASK-087:** Write integration tests - 1h

**Definition of Done:**
- Meeting saves to Firestore
- All validations work
- User feedback clear
- Tests pass
- Error handling robust

---

## 🧪 FEATURE-005: Testing & Quality Assurance

**Role:** QA Engineer + Developer
**Status:** ✅ COMPLETED 


### US-016: Unit Tests

**As a** QA Engineer  
**I want to** comprehensive unit tests  
**So that** data models and business logic are reliable
**Status:** ✅ COMPLETED (February 20, 2026)

**Story Points:** 5  
**Priority:** P1

**Acceptance Criteria:**
- [x] All models have unit tests (Meeting, Person, Activity)
- [x] All repositories have unit tests
- [x] Validation logic tested
- [x] Edge cases covered
- [x] Code coverage > 80%

**Tasks:**
- [x] **TASK-088:** Write Meeting model tests - 1h
- [x] **TASK-089:** Write Person model tests - 1h
- [x] **TASK-090:** Write Activity model tests - 1h
- [x] **TASK-091:** Write repository tests - 1h
- [x] **TASK-092:** Achieve 80%+ coverage - 1h

**Definition of Done:**
- All tests pass
- Coverage > 80%
- Tests documented

---

### US-017: Widget Tests

**As a** QA Engineer  
**I want to** widget tests for UI components  
**So that** user interface is reliable
**Story Points:** 5
**Status:** ✅ COMPLETED (February 20, 2026)


- [x] Login screen widget tests
- [x] ~~Register screen widget tests~~ (obsolete - Google SSO)
- [x] AddMeeting screen widget tests
- [x] Custom widgets tested (stepper, autocomplete)
- [x] HomeScreen widget tests
- [x] User interactions tested

**Tasks:**
- [x] **TASK-093:** Test LoginScreen - 1h
- [x] **TASK-094:** Test RegisterScreen - 1h
- [x] **TASK-095:** Test AddMeetingScreen - 2h
- [x] **TASK-096:** Test custom widgets - 1h

**Definition of Done:**
- All widget tests pass
- User flows tested
- Code reviewed

---

### US-018: Manual Testing & Bug Fixes

**As a** QA Engineer  
**I want to** perform manual testing  
**So that** the app is polished before release
**Story Points:** 3 
**Status:** ✅ COMPLETED

**Acceptance Criteria:**
- [x] Test cases document created
- [x] All features manually tested
- [x] Bugs logged and prioritized
- [x] Critical bugs fixed
- [x] Regression testing performed

**Tasks:**
- [x] **TASK-097:** Create test cases document - 1h
- [x] **TASK-098:** Execute manual tests - 2h
- [x] **TASK-099:** Log bugs in issue tracker - 30min
- [x] **TASK-100:** Fix critical bugs - varies
- [x] **TASK-101:** Regression testing - 1h

**Definition of Done:**
- All test cases executed
- Critical bugs fixed
- App stable for release


---

# 📦 EPIC-002: Friendsheet M2 - Management & CRUD

**Goal:** Give users full visibility and control over their meetings, persons and activities

**Business Value:** App becomes a real management tool instead of just a data entry form. Foundation for statistics in M3.
**Status:** ✅ COMPLETED 
**Architecture Notes:**
- Meetings view requires Firestore queries ordered by date DESC
- Persons and Activities views reuse existing repositories
- Activity categories require ActivityCategory model (designed in US-019)
- Icon system: predefine ~50 icons (Material/emoji), stored as string identifier in Firestore

---

## 📅 FEATURE-006: Meetings View

**Priority:** P0  
**Role:** Developer + UX Designer  
**Status:** ✅ COMPLETED 


### US-021: Meetings List Screen

**As a** user  
**I want to** see all my meetings in chronological order  
**So that** I can review my social history and find specific meetings

**Story Points:** 8  
**Priority:** P0
**Status:** ✅ COMPLETED (February 21, 2026)

**Acceptance Criteria:**
- [x] Meetings displayed in reverse chronological order (newest first)
- [x] Meetings grouped by year
- [x] Current year and previous year expanded by default
- [x] Years older than 1 year collapsed by default with expand button
- [x] Each meeting card shows: name, date, participants count, weight
- [x] Tapping a meeting opens Meeting Detail screen
- [x] Empty state shown when no meetings exist
- [x] Loading indicator while fetching data

**Tasks:**
- [x] **TASK-102:** Create MeetingsListScreen scaffold - 1h
- [x] **TASK-103:** Implement Firestore query (orderBy date DESC) in MeetingRepository - 1h
- [x] **TASK-104:** Implement year-grouping logic in provider - 2h
- [x] **TASK-105:** Build MeetingCard widget - 1h
- [x] **TASK-106:** Implement collapsible year sections - 2h
- [x] **TASK-107:** Add empty state widget - 30min
- [x] **TASK-108:** Write widget tests - 1h

---

### US-022: Meeting Detail Screen

**As a** user  
**I want to** see full details of a meeting  
**So that** I can review what happened and who was there

**Story Points:** 5  
**Priority:** P0
**Status:** ✅ COMPLETED (February 23, 2026)

**Acceptance Criteria:**
- [x] Screen displays all meeting fields (name, date, weight, participants, activities)
- [x] Participants shown as list with full names
- [x] Activities shown as list with category context
- [x] Edit button navigates to Edit Meeting screen
- [x] Delete button with confirmation dialog
- [x] Back navigation to Meetings List

**Tasks:**
- [x] **TASK-109:** Create MeetingDetailScreen - 2h
- [x] **TASK-110:** Resolve participant names from IDs - 1h
- [x] **TASK-111:** Resolve activity names from IDs - 1h
- [x] **TASK-112:** Implement delete with confirmation - 1h
- [x] **TASK-113:** Write tests - 1h

---

### US-023: Edit Meeting

**As a** user  
**I want to** edit an existing meeting  
**So that** I can correct mistakes or update information

**Story Points:** 8  
**Priority:** P0
**Status:** ✅ COMPLETED (February 23, 2026)
**Acceptance Criteria:**
- [x] Edit screen pre-populated with existing meeting data
- [x] All fields editable (name, date, weight, participants, activities)
- [x] Save updates the existing document in Firestore (updatedAt refreshed)
- [x] Cancel returns to detail screen without changes
- [x] Validation same as Add Meeting screen
- [x] Success/error feedback shown

**Tasks:**
- [x] **TASK-114:** Reuse AddMeetingScreen as EditMeetingScreen with initial data - 2h
- [x] **TASK-115:** Add updateMeeting method to MeetingRepository - 1h
- [x] **TASK-116:** Update provider to handle edit mode - 2h
- [x] **TASK-117:** Write tests - 1h

---

## 👥 FEATURE-007: Persons View

**Priority:** P0  
**Role:** Developer + UX Designer  
**Status:** ✅ COMPLETED 


### US-024: Persons List Screen
**Status:** ✅ COMPLETED (February 23, 2026)
**Story Points:** 8 

**Acceptance Criteria:**
- [x] Alphabetical list of all persons
- [x] Each row shows full name
- [x] Search/filter by name
- [x] Tapping person opens Person Detail screen
- [x] Empty state shown when no persons exist

**Tasks:**
- [x] **TASK-118:** Create PersonsListScreen - 2h
- [x] **TASK-118b:** Fix MeetingCard empty participants warning - 30min
- [x] **TASK-118c:** Fix MeetingDetailScreen crash on empty participants - 30min
- [x] **TASK-118d:** Data integrity — cascade delete person from meetings - 1h
- [x] **TASK-118e:** Add person from Friends tab AppBar - 1h
- [x] **TASK-118f:** Rename tab label Persons → Friends - 15min
- [x] **TASK-119:** Implement search/filter in PersonRepository - 1h
- [x] **TASK-120:** Build PersonListTile widget - 1h
- [x] **TASK-121:** Write tests - 1h

---

### US-025: Person Detail & Edit
**Story Points:** 5
**Status:** ✅ COMPLETED (February 23, 2026)

**Acceptance Criteria:**
- [x] Shows first name, last name
- [x] Shows number of meetings together
- [x] Edit inline or via edit screen
- [x] Delete with confirmation (warn if person has meetings)
- [x] Cannot delete person who has associated meetings without explicit confirmation

**Tasks:**
- [x] **TASK-122:** Create PersonDetailScreen - 2h
- [x] **TASK-123:** Add updatePerson, deletePerson to PersonRepository - 1h
- [x] **TASK-124:** Implement meeting count query - 1h
- [x] **TASK-125:** Write tests - 1h

---

## 🏷️ FEATURE-008: Activities View & Categories

**Priority:** P0  
**Role:** Developer + UX Designer  
**Status:** ✅ COMPLETED 
**Architecture Note:** This feature delivers US-019 and US-020 which were designed in M1 but not implemented. The ActivityCategory model with parentCategoryId (max 3 levels) and icon support is the foundation for M3 statistics filtering.

---

### US-019: Activity Categories (moved from FEATURE-X)

**As a** user  
**I want to** organize activities into categories and subcategories  
**So that** I can better structure my activity data and enable hierarchical statistics

**Story Points:** 13  
**Priority:** P0
**Status:** ✅ COMPLETED

**Acceptance Criteria:**
- [x] ActivityCategory model created (max 3 levels: category → subcategory → activity)
- [x] parentCategoryId: String? for hierarchy support
- [x] iconIdentifier: String field (references predefined icon set)
- [x] isGlobal: bool field
- [x] Security Rules updated for activity_categories collection
- [x] Unit tests written

**Tasks:**
- [x] **TASK-126:** Create ActivityCategory model with Freezed - 2h
- [x] **TASK-127:** Create ActivityCategoryRepository - 2h
- [x] **TASK-128:** Update Firestore Security Rules - 1h
- [x] **TASK-129:** Write unit tests - 1h

---

### US-020: Global Activity Library

**As a** user  
**I want to** have a built-in library of common activities  
**So that** I don't have to create everything from scratch

**Story Points:** 8  
**Priority:** P2 (post-MVP)
**Status:** ✅ COMPLETED (February 24, 2026)

**Acceptance Criteria:**
- [x] ActivityCategory model extended with isSelectableAsActivity: bool and copiedFromId: String?
- [x] Meeting model extended with categoryIds: List<String> alongside activityIds
- [x] Global categories seeded via Node.js script (26 categories, 2-level hierarchy)
- [x] Seed data versioned in repository (seed/global_categories.json)
- [x] On first login: batch-copy all global categories to user's private collection
- [x] After copy: user operates on their own private categories (isGlobal: false)
- [x] Ancestor propagation: selecting leaf category saves full path to root in categoryIds
- [x] ActivityCategoryRepository: getSelectableCategories, getAncestorIds methods
- [x] Unified autocomplete: selectable categories + private activities in one field
- [x] Security Rules updated for batch-write on first login
- [x] Unit tests written (251/251 passing)

**Tasks:**
- [x] **TASK-130a:** Extend ActivityCategory model — isSelectableAsActivity, copiedFromId
- [x] **TASK-130b:** Extend Meeting model — categoryIds field
- [x] **TASK-131:** Prepare and seed global categories via Node.js script
- [x] **TASK-132a:** Add getSelectableCategories to ActivityCategoryRepository
- [x] **TASK-132b:** Add getAncestorIds to ActivityCategoryRepository
- [x] **TASK-133:** AuthService batch-copy on first login
- [x] **TASK-134:** AddMeetingProvider — categories + ancestor propagation
- [x] **TASK-135:** ActivityAutocomplete — unified search from two sources
- [x] **TASK-136:** MeetingDetailProvider — resolve categoryIds
- [x] **TASK-137:** Update Security Rules for batch-write
- [x] **TASK-138:** Update all affected tests

---

### US-026: Activities List Screen
**Status:** ✅ COMPLETED (February 25, 2026)

**As a** user
**I want to** see all activities organized by category
**So that** I can manage my activity library

**Story Points:** 8
**Priority:** P0

**Acceptance Criteria:**
- [x] Activities displayed in category tree (expandable)
- [x] Global categories visible and read-only (long-press disabled)
- [x] User can add new private activity category with icon and optional parent
- [x] User can edit/delete their own private categories (long-press)
- [x] User cannot edit/delete global categories
- [x] Search/filter by name

**Tasks:**
- [x] **TASK-139:** Add `getAllCategories` to ActivityCategoryRepository — merges global + private (US-026)
- [x] **TASK-140:** Create ActivitiesListProvider — fetch, tree expansion, search, CRUD
- [x] **TASK-141:** Verify/add addCategory, updateCategory, deleteCategory to repository
- [x] **TASK-142:** Create ActivitiesListScreen with expandable tree view
- [x] **TASK-143:** Create AddEditActivityDialog with icon picker
- [x] **TASK-144:** Wire ActivitiesListProvider into MainScreen
- [x] **TASK-145:** Write tests (9 new tests)
- [x] **TASK-146:** Fix Firestore Security Rules — path-based userId for subcollection list queries
- [x] **TASK-147:** Fix AddMeetingProvider validation — include selectedCategories
- [x] **TASK-148:** Fix ActivityCategory.fromFirestore — nullable createdAt
- [x] **TASK-149:** Fix MeetingDetailScreen — display resolved categories
- [x] **TASK-150:** Fix AddMeetingProvider.initializeEditData — restore category chips

---
### US-042: Cleanup — Remove legacy Activity model and collection

**As a** developer
**I want to** remove the legacy `Activity` model and `activities` Firestore collection from the codebase
**So that** the app has a single, consistent data source for activities

**Story Points:** 5
**Priority:** P0
**Milestone:** M2
**Status:** ✅ COMPLETED

**Acceptance Criteria:**

- [x] `Activity` model removed (`activity.dart`, `activity.freezed.dart`, `activity.g.dart`)
- [x] `ActivityRepository` removed (`activity_repository.dart` and its test file)
- [x] `Meeting` model no longer contains `activityIds` field
- [x] `AddMeetingProvider` no longer references `Activity` model or `ActivityRepository`
- [x] `ActivityAutocomplete` no longer uses `Activity` suggestions or `_activitySuggestions` list
- [x] `MeetingDetailProvider` no longer resolves `activityIds`
- [x] `MeetingDetailScreen` no longer displays legacy activities section
- [x] All tests updated — no references to `Activity` model remain
- [x] `flutter analyze` passes with 0 issues

**Tasks:**

- [x] **TASK-42.1:** Delete `activity.dart`, `activity.freezed.dart`, `activity.g.dart`
- [x] **TASK-42.2:** Delete `activity_repository.dart` and its corresponding test file
- [x] **TASK-42.3:** Remove `activityIds` field from `Meeting` model + run `build_runner`
- [x] **TASK-42.4:** Remove `Activity` references from `AddMeetingProvider` (`selectedActivities`, `searchActivities`, `selectActivity`, `removeActivity`, `addNewActivity`)
- [x] **TASK-42.5:** Remove `Activity` suggestions from `ActivityAutocomplete` (`_activitySuggestions`, `_selectActivity`)
- [x] **TASK-42.6:** Remove `activityIds` resolving from `MeetingDetailProvider` and `MeetingDetailScreen`
- [x] **TASK-42.7:** Update all affected tests — run `flutter test` and fix failures
- [x] **TASK-42.8:** Fix regressions — private categories in autocomplete, add-new-activity flow

---

### US-043: Fix — Unified activity flow

**As a** user
**I want to** have activities work consistently between AddMeeting and the Activities tab
**So that** anything I add in AddMeeting appears in my activity tree and vice versa

**Story Points:** 8
**Priority:** P0
**Milestone:** M2
**Status:** ✅ COMPLETED
**Acceptance Criteria:**

- [x] Autocomplete in AddMeeting reads only from `users/{uid}/activity_categories` via `getSelectableCategories`
- [x] Typing a new activity name in AddMeeting and confirming creates a root category (`isSelectableAsActivity: true`) in `users/{uid}/activity_categories`
- [x] Newly created activity appears in Activities tab immediately after saving the meeting
- [x] Deleting a root category in Activities tab deletes all its children atomically (WriteBatch)
- [x] Deleting a child category does not affect its siblings or parent
- [x] `flutter analyze` passes with 0 issues

**Tasks:**

- [x] **TASK-43.1:** Update `ActivityAutocomplete` — remove `Activity` path, read only from `getSelectableCategories`
- [x] **TASK-43.2:** Update `AddMeetingProvider.addNewActivity` — saves to `users/{uid}/activity_categories` as root category with `isSelectableAsActivity: true`
- [x] **TASK-43.3:** Add `deleteWithChildren(String categoryId, String userId)` to `ActivityCategoryRepository` using `WriteBatch`
- [x] **TASK-43.4:** Update `ActivitiesListProvider` — call `deleteWithChildren` instead of `deleteCategory`
- [x] **TASK-43.5:** Write/update tests for repository and provider changes

---

### US-044: Fix — Onboarding idempotency

**As a** developer
**I want to** ensure the activity template is copied to a new user exactly once
**So that** reinstalling the app or logging in again does not create duplicate categories

**Story Points:** 3
**Priority:** P0
**Milestone:** M2
**Status:** ✅ COMPLETED
**Acceptance Criteria:**

- [x] `users/{uid}` document contains `onboardingCompletedAt: Timestamp` field after first login
- [x] Batch-copy of global categories runs only if `onboardingCompletedAt` is null (field absent)
- [x] Re-login or reinstall does not create duplicate entries in `users/{uid}/activity_categories`
- [x] `flutter analyze` passes with 0 issues

**Tasks:**

- [x] **TASK-44.1:** Add `onboardingCompletedAt: Timestamp` write to `users/{uid}` document as part of the first-login batch operation
- [x] **TASK-44.2:** Update `AuthService` — check `onboardingCompletedAt` flag before running batch-copy; skip if field exists
- [x] **TASK-44.3:** Write/update tests for `AuthService` covering idempotent onboarding behavior


### US-045: Firestore Hierarchy — Migrate meetings and persons to user subcollections

**As a** developer
**I want to** store meetings and persons under `users/{uid}/meetings` and `users/{uid}/persons`
**So that** all user data lives under a single consistent path and Security Rules are path-based

**Story Points:** 8
**Priority:** P0
**Milestone:** M2
**Status:** ✅ COMPLETED

**Acceptance Criteria:**

- [x] `MeetingRepository` reads/writes from `users/{uid}/meetings` subcollection
- [x] `PersonRepository` reads/writes from `users/{uid}/persons` subcollection
- [x] `users/{uid}` document created on first login with `onboardingCompletedAt: Timestamp`
- [x] Batch-copy of global categories runs only if `onboardingCompletedAt` is absent (idempotent)
- [x] Security Rules for meetings and persons use path-based `userId` (not `resource.data.userId`)
- [x] `firestore.indexes.json` updated with new subcollection paths
- [x] `flutter analyze` passes with 0 issues
- [x] All tests pass
- [x] getAllCategories reads only from users/{uid}/activity_categories — root activity_categories collection is never queried from the UI layer

**Tasks:**

- [x] **TASK-45.1:** Update `MeetingRepository` — change all Firestore paths from `/meetings` to `users/{uid}/meetings`; update `save`, `update`, `delete`, `stream`, `getMeetingsCountForPerson`, `removePersonFromMeetings`
- [x] **TASK-45.2:** Update `PersonRepository` — change all Firestore paths from `/persons` to `users/{uid}/persons`; update `getPersonsByUser`, `addPerson`, `updatePerson`, `deletePerson`, `getPersonsByIds`
- [x] **TASK-45.3:** Update Security Rules — replace `resource.data.userId` checks with path-based `userId` for meetings and persons; remove `userId` field dependency from read/delete rules
- [x] **TASK-45.4:** Update `AuthService` — create `users/{uid}` document with `onboardingCompletedAt: Timestamp` as part of first-login batch; guard batch-copy with `onboardingCompletedAt` field presence check
- [x] **TASK-45.5:** Update `firestore.indexes.json` — replace root collection paths with subcollection paths for meetings and persons indexes
- [x] **TASK-45.6:** Update all affected tests — `MeetingRepository`, `PersonRepository`, `AuthService`, `AddMeetingProvider`, `MeetingDetailProvider`, `PersonDetailProvider`, `PersonsListProvider`

- [x] **TASK-45.7:**  Update ActivityCategoryRepository.getAllCategories — remove global root collection query; read only from users/{uid}/activity_categories; update affected tests in activity_category_repository_test.dart and activities_list_provider_test.dart

---

# 📦 EPIC-003: Friendsheet M3 - Statistics & Export

**Goal:** Give users meaningful insights about their social life and ability to back up their data

**Business Value:** Core value proposition of the app — transforms raw data into actionable insights. Export enables user trust and data portability.

**Architecture Notes:**
- Statistics computed client-side (no Cloud Functions) — acceptable for personal scale (~857 meetings)
- Aggregation by year, filtered from `users/{uid}/meetings` subcollection
- Hidden persons preferences stored in SharedPreferences (per-metric, local only)
- Import is a one-time Python script — not part of the Flutter app
**Status:** ✅ COMPLETED
---

## 📥 FEATURE-016: Data Import

**Priority:** P0
**Role:** Developer
**Status:** ✅ COMPLETED

---

### US-041: Python Migration Script — Excel to Firestore

**As a** user
**I want to** run a one-time Python script that reads my Excel file and writes all meetings, persons and activities to Firestore
**So that** I have 20 years of social history available in Friendsheet

**Story Points:** 5
**Priority:** P0
**Labels:** `migration`, `data`, `python`
**Status:** ✅ COMPLETED 

**Acceptance Criteria:**
- [x] Script reads `.xlsx` file with columns: Data | Waga | Aktywność | Nazwa spotkania | persons as columns with "x"
- [x] Activities separated by ";" are split and treated as separate `categoryIds`
- [x] Persons are deduplicated — same name = same Firestore document
- [x] Meetings written to `users/{uid}/meetings` subcollection
- [x] Persons written to `users/{uid}/persons` subcollection
- [x] Activities matched or created in `users/{uid}/activity_categories`
- [x] Script is idempotent — running twice does not create duplicates (match by date + name)
- [x] Progress reported to console (e.g. "Imported 450/857 meetings...")
- [x] Script requires: `FIREBASE_UID`, path to `.xlsx`, path to Firebase service account JSON

**Tasks:**
- [x] **TASK-041.1:** Set up Python environment + dependencies (openpyxl, firebase-admin)
- [x] **TASK-041.2:** Implement person deduplication and Firestore write
- [x] **TASK-041.3:** Implement activity matching and Firestore write
- [x] **TASK-041.4:** Implement meeting import with idempotency check
- [x] **TASK-041..5:** Add progress reporting and error handling


---

## 📊 FEATURE-009: Core Statistics

**Priority:** P0
**Role:** Developer + UX Designer
**Status:** ✅ COMPLETED

---

### US-027: Statistics Home Tab — Year Filter

**As a** user
**I want to** see a statistics section on the Home tab with a year selector
**So that** I can explore my social data year by year

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (February 27, 2026)

**Acceptance Criteria:**
- [x] Home tab displays statistics section
- [x] Year selector (YearStepper: ← YYYY → with swipe gesture) — defaults to current year
- [x] Available years derived from actual meeting data (no hardcoding)
- [x] Selected year persisted in provider state during session
- [x] Loading state while fetching data
- [x] Empty state when no meetings in selected year

**Tasks:**
- [x] **TASK-027.1:** Create StatisticsRepository with getAvailableYears and getMeetingsForYear
- [x] **TASK-027.2:** Create StatisticsProvider with year selector state
- [x] **TASK-027.3:** Create StatisticsSection widget on HomeScreen
- [x] **TASK-027.4:** Register StatisticsProvider lifecycle in MainScreen
- [x] **TASK-027.5:** Update HomeScreen — replace placeholder with Consumer<StatisticsProvider>
- [x] **TASK-027.6:** Write tests (repository + provider: 14 tests)
- [x] **TASK-027.7:** Replace ChoiceChip row with YearStepper (← YYYY → + swipe gesture)

---

### US-028: Activity Breakdown Metric

**As a** user
**I want to** see a ranked list of activities by total weight compared to the previous year
**So that** I can understand how my social habits are changing

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (February 27, 2026)

**Acceptance Criteria:**
- [x] Ranked list of activities by sum of meeting weights in selected year
- [x] Each row shows: activity name | weight sum current year | weight sum previous year | delta (▲/▼)
- [x] Sorted by current year weight sum descending
- [x] Activities with 0 occurrences in current year but present in previous year shown at bottom
- [x] Weight treated as intensity score (higher = more significant meeting)

**Tasks:**
- [x] **TASK-028.1:** Implement `getActivityWeightBreakdown(year)` in StatisticsRepository
- [x] **TASK-028.2:** Build ActivityBreakdownWidget
- [x] **TASK-028.3:** Write tests

---

### US-029: Who Per Activity Metric

**As a** user
**I want to** select an activity and see a ranked list of people I did it with
**So that** I can understand my activity-relationship patterns

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (February 27, 2026)

**Acceptance Criteria:**
- [x] Activity selector (dropdown or chip) — defaults to most frequent activity in selected year
- [x] Ranked list of persons by sum of meeting weights with that activity in selected year
- [x] Per-metric hidden persons toggle — excluded persons not shown in list
- [x] Hidden persons list stored in SharedPreferences key: `stats_hidden_persons_activity`
- [x] Long-press on person → option to hide/show
- [x] Hidden persons count shown as hint ("2 persons hidden — tap to show")

**Tasks:**
- [x] **TASK-029.1:** Implement `getPersonsForActivity(activityId, year)` in StatisticsRepository
- [x] **TASK-029.2:** Build WhoPerActivityWidget with activity selector
- [x] **TASK-029.3:** Implement hidden persons persistence (SharedPreferences)
- [x] **TASK-029.4:** Write tests

---

### US-048: Activity Breakdown — UX Improvements

**As a** user
**I want to** see activity breakdown as a bar chart with ability to hide selected activities
**So that**  I can focus on the activities that matter to me and read the data more clearly

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (March 01, 2026)

**Acceptance Criteria:**
- [x] Widget replaced with vertical bar chart (colored bars + legend)
- [x] Each activity has a unique color consistent between bar and legend
- [x] Scroll within widget — 10 activities visible at a time, rest scrollable
⚙️ icon next to section title opens dialog with checkbox list of all activities
- [x] User can check/uncheck activities to show/hide them
- [x] Hidden activities stored in SharedPreferences key: stats_hidden_activities_breakdown
- [x] Hint shown when activities are hidden: "X activities hidden"
- [x] Chart re-renders immediately after closing dialog

**Tasks:**
- [x] **TASK-048.1:** Extend StatisticsProvider with hidden activities state
- [x] **TASK-048.2:** Build ActivityVisibilityDialog
- [x] **TASK-048.3:** Rebuild ActivityBreakdownWidget as vertical bar chart
- [x] **TASK-048.4:** Wire dialog into StatisticsSection
- [x] **TASK-048.5:** Write tests
- [x] **TASK-048.6:** Activity Breakdown UI fixes
- [x] **TASK-048.7:** Activity Breakdown further UX improvements
- [x] **TASK-048.8:** — Fix top 10 logic + animated bar chart
- [x] **TASK-048.9:** — Fix auto-select logic + fix animation on year change
- [x] **TASK-048.10:** — Animated reordering + stable colors
- [x] **TASK-048.11:** - Fix stationary bar poition jump
- [x] **TASK-048.12:** - Debug and fix stationary bar reordering
- [x] **TASK-048.13:** - Fix multiple didUpdateWidget calls corrupting tween state
---

### US-030: Interaction Distribution Metric

**As a** user
**I want to** see what percentage of my total social intensity each person accounts for
**So that** I understand how my attention is distributed across relationships

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (March 02, 2026)

**Acceptance Criteria:**
- [x] Vertical bar chart — one bar per person, same layout as Activity Breakdown (US-048)
- [x] Default mode: yearly view — bar = sum of weights of meetings with that person in selected year
- [x] Each row shows: person name | weight sum | delta vs previous year (▲/▼ + %)
- [x] Delta: NEW when person has no data in previous year
- [x] Toggle button "Total interactions" — switches to cumulative mode
- [x]  Cumulative mode: bar = sum of all weights from all years up to and including selected year
- [x] Cumulative mode: no delta indicator (not applicable)
- [x] Top 10 persons auto-selected by default for selected year (SharedPreferences key: stats_hidden_persons_distribution)
- [x] ⚙️ icon → dialog with checkbox list + "Auto-select top 10" button
- [x] Long-press on bar → hide/show person
- [x] Hidden persons hint: "X persons hidden"
- [x] Percentages intentionally exceed 100% total — meeting with 3 people counts for all 3
- [x] Info icon explaining >100% behaviour (yearly mode only)

**Tasks:**
- [x] **TASK-US-030.1:** Add getInteractionDistribution(year, userId) to StatisticsRepository — yearly weights per person
- [x] **TASK-US-030.2:** Add getCumulativeInteractions(year, userId) to StatisticsRepository — sum of all weights up to selected year per person
- [x] **TASK-US-030.3:** Extend StatisticsProvider with distribution state, toggle mode, hidden persons
- [x] **TASK-US-030.4:** Build InteractionDistributionWidget — bar chart reusing Activity Breakdown patterns
- [x] **TASK-US-030.5:** Build PersonVisibilityDialog — reuse ActivityVisibilityDialog pattern (checkboxes + auto-select top 10)
- [x] **TASK-US-030.6:** Write tests


### US-049.1: Activity Breakdown — Smooth Bar Reordering Animation

**As a** user
**I want to** see bars stay in place when their ranking doesn't change between years
**So that** I can visually track individual activities across year changes without confusion

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (March 02, 2026)

**Acceptance Criteria:**
- [x] Bars that don't change rank position remain visually stationary during year change animation
- [x] Bars that change rank animate smoothly to their new position
- [x] Color assignments remain stable across year changes and reorders
- [x] No visual glitches (bars jumping to wrong position and back)

**Tasks:**
- [x] **TASK-US-049.1.1:** Add debug logging to trace targetLeft values across rebuilds — identify root cause of spurious position changes
- [x] **TASK-US-049.1.2:** Fix tween initialization so stationary bars receive begin == end == targetLeft
- [x] **TASK-US-049.1.3:** Verify fix across multiple year changes (including mid-animation changes)
- [x] **TASK-US-049.1.4:** Remove debug logging, run dart format + flutter analyze + flutter test

### US-051: Statistics Carousel — Swipeable metric cards on Home screen

**As a** user
**I want to** swipe between statistics on the Home screen instead of seeing them all at once
**So that** I can focus on one metric at a time without being overwhelmed

**Story Points:** 5
**Priority:** P1
**Labels:** `statistics`, `ux`, `home-screen`
**Status:** ✅ COMPLETED (March 02, 2026)
**Milestone:** M3


**Acceptance Criteria:**
- [x] Home screen replaces stacked statistics widgets with a horizontal `PageView` (carousel)
- [x] Swiping left/right switches between metric cards (ActivityBreakdown, WhoPerActivity, InteractionDistribution)
- [x] `YearStepper` lives above the carousel — single year selector applies to all cards
- [x] Long-press on a card hides it; long-press on any remaining card shows a "Restore hidden" option
- [x] Hidden cards persisted in `SharedPreferences` key: `stats_carousel_hidden_cards`
- [x] If all cards are hidden: empty state shown with hint „Long-press any card to restore"
- [x] No dot indicators — swipe gesture is the only navigation
- [x] Each card is independently scrollable (handles variable widget heights)
- [x] `flutter analyze` passes with 0 issues
- [x] All existing statistics tests pass without modification

**Tasks:**
- [x] **TASK-051.1:** Refactor `StatisticsSection` — replace `Column` with `PageView` + `PageController`
- [x] **TASK-051.2:** Extract `YearStepper` above `PageView` (shared across all cards)
- [x] **TASK-051.3:** Wrap each `PageView` page in `GestureDetector(onLongPress)` + `SingleChildScrollView`
- [x] **TASK-051.4:** Add `visibleCards` state + `toggleCardVisibility()` to `StatisticsProvider`
- [x] **TASK-051.5:** Implement `SharedPreferences` persistence for hidden cards (`stats_carousel_hidden_cards`)
- [x] **TASK-051.6:** Implement empty state when all cards hidden
- [x] **TASK-051.7:** Write tests for provider changes (toggleCardVisibility, persistence)

**Architecture Notes:**
- `GestureDetector` for long-press lives at `PageView` page level — above child widgets that use their own long-press (bars in charts). This avoids gesture conflict.
- Long-press feedback via `SnackBar`: e.g. „Activity Breakdown hidden. Long-press to restore."
- `StatCard` enum: `activityBreakdown`, `whoPerActivity`, `interactionDistribution`
- SharedPreferences key stores list of hidden card names as JSON array of strings

---

### US-050: Bug Fix — Who Per Activity shows no data for existing meetings

**As a** user
**I want to** see persons listed in Who Per Activity when I select an activity that has meetings
**So that** the metric actually reflects my social history

**Story Points:** 3
**Priority:** P0
**Labels:** `bug`, `statistics`, `who-per-activity`
**Status:** ✅ COMPLETED (March 03, 2026)
**Milestone:** M3


**Problem Description:**
Activity Breakdown correctly shows 82 meetings with „Planszówki" in 2023, but Who Per Activity shows an empty list for the same activity and year. The two metrics use different data access paths — the bug likely lies in `getPersonsForActivity` filtering logic.

**Suspected Root Cause:**
`getPersonsForActivity` filters meetings by matching `categoryIds` using the selected activity's ID. Meetings migrated via the Python script may store `categoryIds` as the category name string rather than the Firestore document ID — or the ancestor propagation differs between the migration script and the Flutter app's write path.

**Acceptance Criteria:**
- [x] Selecting „Planszówki" (or any activity with meetings) in Who Per Activity for year 2023 shows a non-empty ranked list of persons
- [x] Result is consistent with Activity Breakdown — same activity, same year, same meeting pool
- [x] Fix applies to both migrated data and meetings added natively through the app
- [x] No regression in Activity Breakdown or Interaction Distribution
- [x] `flutter analyze` passes with 0 issues
- [x] Existing tests pass; new test added covering the identified root cause

**Diagnostic Steps (before implementation):**
1. Log raw `categoryIds` from a 2023 „Planszówki" meeting in Firestore console
2. Compare with the `categoryId` value used in `ActivitySelectorDialog` when „Planszówki" is selected
3. Check `getPersonsForActivity` query — verify it matches by document ID, not by name

**Tasks:**
- [x] **TASK-050.1:** Diagnose — compare `categoryIds` stored in meetings vs IDs used in `getPersonsForActivity` query (add debug logging or inspect Firestore directly)
- [x] **TASK-050.2:** Fix `getPersonsForActivity` filtering to correctly match migrated and native data
- [x] **TASK-050.3:** Write regression test covering the root cause scenario
- [x] **TASK-050.4:** WhoPerActivityWidget UI improvements
- [x] **TASK-050.5:** Fix "No data" flash on year change
---

## 💾 FEATURE-010: Data Export

**Priority:** P1  
**Role:** Developer  
**Status:** ✅ COMPLETED

---

### US-031: JSON Export to Device

**As a** user
**I want to** export all my meeting data as a JSON file to my device
**So that** I can back up my data and ensure portability

**Story Points:** 5
**Priority:** P1
**Status:** ✅ COMPLETED

**Acceptance Criteria:**
- [x] Export option accessible from Settings or Home tab
- [x] Exports all meetings from `users/{uid}/meetings` to JSON
- [x] File saved to device Downloads folder
- [x] Success confirmation with file path shown to user
- [x] Error handling for storage permission issues

**Tasks:**
- [x] **TASK-031.1:** Implement ExportService (Firestore → JSON)
- [x] **TASK-031.2:** Add file write using path_provider + dart:io
- [x] **TASK-031.3:** Build export trigger UI (button + confirmation)
- [x] **TASK-031.4:** Write tests

### US-075: Statistics & Activities UI Polish

**As a** user viewing Statistics and Activities
**I want** charts to animate smoothly from zero and feel consistent, and activity categories to clearly show whether they have subcategories
**So that** the UI feels polished and intentional

**Labels:** `statistics` `activities` `ux` `P2`
**Story Points:** 5
**Priority:** P2
**Status:** 📋 Planned
**Feature:** FEATURE-009: Core Statistics / FEATURE-008: Activities View & Categories
**Epic:** EPIC-003 / EPIC-002

**Context:**
Three independent polish items grouped due to low complexity and shared "find widget → adjust appearance" workflow:

1. **Pre-animation flash** — Who per Activity, Activity Breakdown, Interaction Distribution all briefly show their final state before animating. Classic "render then animate" issue — `AnimationController` starts at end value instead of 0.
2. **Animation duration mismatch** — Who per Activity animates noticeably faster than the other two charts. Should use a single shared constant.
3. **Child activity badge** — No visual indicator shows which categories have subcategories. A small badge with the direct child count (e.g. "3") should appear next to parent category names. Leaf nodes show no badge.

**Acceptance Criteria:**
- [ ] On tab load or year change, all three charts start from zero/empty and animate forward — no pre-flash of final values
- [ ] Who per Activity, Activity Breakdown, and Interaction Distribution run at identical animation duration
- [ ] Duration defined as a single shared constant (e.g. `AppConstants.chartAnimationDuration`), not hardcoded per widget
- [ ] Parent categories (≥1 child) display a badge showing direct child count
- [ ] Leaf categories display no badge
- [ ] Badge updates correctly when a child is added or deleted
- [ ] Badge is visually consistent with app design system
- [ ] No regression on chart data correctness, or activity expand/collapse/edit/delete flows

**Tasks:**
- [ ] **TASK-075.1:** Audit animation controller initialization in all three chart widgets — ensure `forward()` is called after first frame (`addPostFrameCallback` or correct `initState` ordering), values start at 0
- [ ] **TASK-075.2:** Fix initialization order so animated values start at 0 before first paint — verify flash is gone for all three widgets on device
- [ ] **TASK-075.3:** Extract animation duration to shared constant and apply to all three chart widgets
- [ ] **TASK-075.4:** Identify widget rendering each activity category row in the tree
- [ ] **TASK-075.5:** Add badge widget (small rounded container + count text) visible only when `children.length > 0`, styled with app theme
- [ ] **TASK-075.6:** Verify badge updates live on child add/remove
- [ ] **TASK-075.7:** Run `flutter analyze` + `flutter test`, report back

**Definition of Done:**
- [ ] No pre-animation flash on any of the three chart types
- [ ] All three chart animations run at identical duration via shared constant
- [ ] Badge visible on parent categories, absent on leaf categories, count accurate
- [ ] `flutter analyze` clean, `flutter test` green


## 📱 FEATURE-017: Sideload Release

**Description:** Enables the developer to install Friendsheet on a personal Android device
without Google Play — producing a signed release APK and configuring Firebase
for the release signing key. Serves as the Epic 3 capstone: real data, real device.

**Priority:** P0
**Role:** Developer + DevOps
**Status:** ✅ COMPLETED

---

### US-042.1: Install Friendsheet on Personal Device via APK
**Status:** ✅ COMPLETED
**As a** developer
**I want to** build a signed release APK and install it on my personal Android phone
**So that** I can use Friendsheet daily with real data without needing a connected computer

**Story Points:** 5
**Priority:** P0
**Labels:** `release`, `android`, `devops`

**Acceptance Criteria:**
- [x] Keystore generated and stored securely outside the repository
- [x] `key.properties` configured and added to `.gitignore`
- [x] `build.gradle` configured with release signing config
- [x] `flutter build apk --release` completes without errors
- [x] APK installed on personal Android device (sideload via USB or file transfer)
- [x] SHA-1 fingerprint of release keystore added to Firebase Console
- [x] Google Sign-In works on the installed release build
- [x] App runs stably — no crash on launch, data loads correctly

**Architecture Notes:**
- Keystore generated once — reused in US-032 (Google Play release) without changes
- `key.properties` format follows Flutter/Gradle convention:
  ```
  storePassword=...
  keyPassword=...
  keyAlias=...
  storeFile=...
  ```
- SHA-1 for release build differs from debug SHA-1 — both must be registered in Firebase Console
- APK vs AAB: `.apk` for sideload (this US), `.aab` for Google Play (US-032)

**Tasks:**
- [x] **TASK-042.1.1:** Update `.gitignore` — add keystore and `key.properties` entries
- [x] **TASK-042.1.2:** Generate keystore with `keytool` and store securely outside repo
- [x] **TASK-042.1.3:** Create `android/key.properties` with signing config
- [x] **TASK-042.1.4:** Configure release signing in `android/app/build.gradle`
- [x] **TASK-042.1.5:** Run `flutter build apk --release` and verify output
- [x] **TASK-042.1.6:** Extract SHA-1 from release keystore and add to Firebase Console
- [x] **TASK-042.1.7:** Install APK on device and verify Google Sign-In + data load

**Relation to US-032 (Google Play Release):**
- Keystore created here is reused directly in US-032
- `build.gradle` signing config created here requires only minor changes for AAB
- US-032 adds: version name/code, ProGuard rules, App Bundle target


---
### US-072: Optimize Statistics Firestore Reads

| **Priority** | P0 (Critical — affects free tier limits) |
| **Story Points** | 13 |
| **Status** |  ✅ COMPLETED (March 08, 2026)
| **Labels** | `performance`, `firestore`, `statistics`, `cost-optimization` |

**As a** user  
**I want to** browse statistics without excessive Firestore reads  
**So that** the app stays within free tier limits and loads faster

---

#### Problem Statement

Current implementation causes **~5,200 Firestore reads per `initialize()` call**:

| Method | Reads | Called |
|--------|-------|--------|
| `getAvailableYears()` | ~860 | 1x |
| `getMeetingsForYear(currentYear)` | ~860 | 3-4x (duplicate!) |
| `getMeetingsForYear(previousYear)` | ~800 | 2x (duplicate!) |
| `getAllCategories()` | ~20 | 2x (duplicate!) |
| `getPersonsByUser()` | ~80 | 2x (duplicate!) |

**Impact:** With 860 meetings, a single user browsing statistics 10x/day consumes **~13,000 reads** — 26% of daily free tier (50,000).

**Risk:** 5 active users = **65,000 reads/day** → exceeds free tier limit.

---

#### Solution Overview

Three-phase optimization reducing reads by **~95%**:

| Phase | Strategy | Reduction | Complexity |
|-------|----------|-----------|------------|
| **Phase 1** | Provider-level cache | 70% | Low |
| **Phase 2** | Repository-level cache | 85% | Medium |
| **Phase 3** | Single-query refactor | 95% | Medium |

---

#### Acceptance Criteria

##### Phase 1: Provider Cache
- [x] `StatisticsProvider.initialize()` is idempotent — skips fetch if data already loaded for current year
- [x] `selectYear()` only fetches if year changed
- [x] `selectActivity()` reuses already-loaded meetings (no Firestore call)
- [x] `loadDistribution()` reuses already-loaded meetings for current year
- [x] Unit tests verify no duplicate fetches

##### Phase 2: Repository Cache
- [x] `StatisticsRepository` caches `getMeetingsForYear()` results in memory
- [x] Cache key: `${userId}_${year}`
- [x] Cache invalidated on `MeetingRepository.save()`, `update()`, `delete()`
- [x] `getAllCategories()` cached per session
- [ ] `getPersonsByUser()` cached per session
- [x] Cache invalidated on person/category add/update/delete
- [x] Unit tests verify cache hit/miss behavior

##### Phase 3: Single-Query Refactor
- [x] New method `loadAllStatsData(year, userId)` fetches meetings once
- [x] Returns `StatsDataBundle` containing: meetings, categories, persons
- [x] All aggregation methods accept `StatsDataBundle` instead of fetching internally
- [x] `getAvailableYears()` optimized — uses cached meetings or dedicated index
- [x] Backward compatibility maintained — old methods still work (delegate to new)
- [x] Unit tests verify single Firestore call per year

##### General
- [x] `flutter analyze` passes with 0 issues
- [x] All existing tests pass
- [x] New tests added for cache behavior
- [x] README updated with performance notes
- [x] architecture.md updated with caching strategy
---

#### Tasks

##### Phase 1: Provider Cache (Est. 2h)
- [x] **TASK-072.1:** Add `_isInitialized` and `_lastLoadedYear` flags to `StatisticsProvider`
- [x] **TASK-072.2:** Guard `initialize()` with early return if already loaded
- [x] **TASK-072.3:** Optimize `selectYear()` — skip fetch if year unchanged
- [x] **TASK-072.4:** Write tests verifying idempotent behavior

##### Phase 2: Repository Cache (Est. 3h)
- [x] **TASK-072.5:** Add `_meetingsCache` map to `StatisticsRepository`
- [x] **TASK-072.6:** Implement cache lookup in `getMeetingsForYear()`
- [x] **TASK-072.7:** Add `_categoriesCache` and `_personsCache`
- [x] **TASK-072.8:** Add `invalidate*Cache()` methods
- [x] **TASK-072.9:** Wire cache invalidation into `MeetingRepository`, `PersonRepository`, `ActivityCategoryRepository`
- [x] **TASK-072.10:** Write tests for cache hit/miss scenarios

##### Phase 3: Single-Query Refactor (Est. 4h)
- [x] **TASK-072.11:** Create `StatsDataBundle` class
- [x] **TASK-072.12:** Implement `loadAllStatsData()` in `StatisticsRepository`
- [x] **TASK-072.13:** Refactor `getActivityWeightBreakdown()` to `computeActivityBreakdown(StatsDataBundle)`
- [x] **TASK-072.14:** Refactor `getPersonsForActivity()` to `computePersonsForActivity(StatsDataBundle, categoryId)`
- [x] **TASK-072.15:** Refactor `getInteractionDistribution()` to `computeInteractionDistribution(StatsDataBundle)`
- [x] **TASK-072.16:** Refactor `getCumulativeInteractions()` — special case (all years)
- [x] **TASK-072.17:** Update `StatisticsProvider` to use new architecture
- [x] **TASK-072.18:** Write integration tests verifying single Firestore call

---

### US-073: Persistent Local Cache — Offline-First Statistics

| Field | Value |
|---|---|
| **Priority** | P2 |
| **Story Points** | 8 |
| **Status** | ✅ COMPLETED (March 10, 2026) |
| **Labels** | `performance`, `offline`, `hive`, `statistics` |
| **Depends on** | US-072 ✅ |

---

#### User Story

**As a** user  
**I want to** browse statistics instantly after reopening the app  
**So that** I don't wait for Firestore reads on every app launch

---

#### Problem Statement

US-072 eliminated duplicate reads **within a session**. However, every app restart clears
the in-memory cache and triggers ~1,800 Firestore reads on first statistics open.

With Hive persistent cache, data survives restarts — reads drop to near-zero for returning users.

| Scenario | Before US-072 | After US-072 | After US-073 |
|---|---|---|---|
| First load (cold start) | ~5,200 | ~1,800 | ~1,800 (first ever) |
| App restart, no writes | ~5,200 | ~1,800 | ~0 |
| Tab switch (same year) | ~5,200 | 0 | 0 |
| Year change | ~5,200 | ~900 | ~0 (if cached) |

---

#### Technology: Hive

Hive is a lightweight key-value store for Flutter that persists Dart objects directly to disk —
no SQL, no native dependencies.

**Why Hive over Drift/SQLite:**
- Stores Dart objects natively — no query layer needed
- No native code dependencies (SQLite requires platform-specific binaries)
- Fast on-device reads — data loaded into memory on first access
- Sufficient for ~860 meetings (not a relational data problem)
- Familiar workflow — uses `build_runner` adapters, same as Freezed

**Hive Box structure:**

| Box name | Key | Value |
|---|---|---|
| `stats_meetings` | `{userId}_{year}` | `List<Meeting>` |
| `stats_categories` | `{userId}` | `List<ActivityCategory>` |
| `stats_persons` | `{userId}` | `List<Person>` |
| `stats_available_years` | `{userId}` | `List<int>` |

---

#### Acceptance Criteria

##### Cache — Write
- [x] After first Firestore load, `StatsDataBundle` contents persisted to Hive per year
- [x] `getAvailableYears()` result persisted to Hive per userId
- [x] Persons and categories persisted to Hive per userId

##### Cache — Read
- [x] On app restart, statistics load from Hive instead of Firestore (if cache exists)
- [x] `StatisticsRepository` checks Hive before hitting Firestore
- [x] Cache miss (no Hive data) falls back to Firestore transparently

##### Cache — Invalidation
- [x] Any write in `MeetingRepository` clears `stats_meetings` box entries for that userId
- [x] Any write in `PersonRepository` clears `stats_persons` entry for that userId
- [x] Any write in `ActivityCategoryRepository` clears `stats_categories` entry for that userId
- [x] `invalidateAllCaches()` in `StatisticsRepository` clears all Hive boxes for current user
- [x] Cache cleared on logout (all Hive boxes purged for that userId)

##### Quality
- [x] `flutter analyze` passes with 0 issues
- [x] All existing tests pass
- [x] New unit tests for Hive cache hit / miss / invalidation behavior
- [x] Hive boxes opened once at app startup (not per-repository-call)

---


#### Tasks

##### Setup (Est. 1h)
- [x] **TASK-073.1:** Add `hive` and `hive_flutter` to `pubspec.yaml`; verify `.gitignore` covers Hive files
- [x] **TASK-073.2:** Create `HiveService` — box initialization + `clearUserData(userId)`
- [x] **TASK-073.3:** Call `HiveService.initialize()` in `main.dart` before `runApp()`

##### Repository Layer (Est. 2h)
- [x] **TASK-073.4:** Extend `StatisticsRepository.getMeetingsForYear()` — check Hive before Firestore; write to Hive after fetch
- [x] **TASK-073.5:** Extend `StatisticsRepository` categories/persons cache — check Hive before Firestore
- [x] **TASK-073.6:** Extend `StatisticsRepository.getAvailableYears()` — persist/read from Hive
- [x] **TASK-073.7:** Extend all `invalidate*Cache()` methods to also clear corresponding Hive boxes

##### Logout Integration (Est. 30min)
- [x] **TASK-073.8:** Call `HiveService.clearUserData(userId)` on logout in `AuthService`

##### Tests (Est. 1.5h)
- [x] **TASK-073.9:** Unit tests — Hive cache hit (Firestore not called on second load after restart simulation)
- [x] **TASK-073.10:** Unit tests — Hive cache miss (first load hits Firestore, then writes to Hive)
- [x] **TASK-073.11:** Unit tests — invalidation clears both in-memory and Hive

##### Documentation (Est. 30min)
- [x] **TASK-073.12:** Update `architecture.md` — extend Statistics Caching Strategy section with Hive layer
- [x] **TASK-073.13:** Update README version history

---

#### Out of Scope

- TTL-based cache expiration — deferred (personal app, single user, writes are infrequent)
- Hive encryption (`hive_flutter` AES) — deferred (no sensitive data beyond what Firebase holds)
- Sync conflict resolution — deferred (no multi-device sync in current architecture)
- Caching for non-statistics repositories (MeetingsList, PersonsList) — separate US if needed

---

#### Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Hive file grows unbounded over years | Low | Cache only accessed years; `clearUserData` on logout |
| JSON bridge slower than TypeAdapters | Low | ~860 meetings deserialization is <50ms — acceptable |
| Hive box not initialized before first read | Medium | `HiveService.initialize()` called before `runApp()`, tests use `Hive.init(tempDir)` |
| Stale data after write on another device | Low | Out of scope — single device assumption for now |

---

#### Definition of Done

- [ ] All acceptance criteria met
- [ ] `flutter analyze` 0 issues
- [ ] All tests pass (existing + new)
- [ ] Statistics open instantly on app restart (verified manually)
- [ ] Firestore reads after restart = 0 (verified via Firebase Console)
- [ ] Documentation updated
---

# 📦 EPIC-009: Friendsheet M3.5 - Visual Design & Brand Identity

**Goal:** Establish a consistent visual identity for Friendsheet — color system, typography, app icon, splash screen, and illustrations — so the app looks professional before Google Play release.

**Business Value:** A polished UI is the difference between a portfolio project and a portfolio project that impresses. Recruiters and users judge apps in the first 5 seconds.

**Prerequisites:** M2 completed. Runs in parallel with M3 development.

**Design Tools:** Figma (free plan), Midjourney (subscribed), Flutter ThemeData.

**Status:** 📋 Planned

---

## 🎨 FEATURE-018: Design System & Theme

**Description:** Defines the visual foundation of the app — color palette, typography, spacing and shape system — and implements it as Flutter ThemeData so all screens inherit the style automatically.

**Priority:** P0
**Role:** UX Designer + Developer
**Status:** ✅ COMPLETED

---

### US-049: Figma Setup — Color System & Typography

**As a** designer
**I want to** set up a Figma file with color styles and text styles
**So that** I have a single source of truth for all design decisions before implementing them in code

**Story Points:** 3
**Priority:** P0
**Status:** ✅ COMPLETED
**Labels:** `design`, `figma`
**Mode:** 🎨 Design (no Claude Code)

**Acceptance Criteria:**
- [x] Figma file created with frame size 390×844 (standard mobile)
- [x] Color styles defined: Primary, Primary Light, Primary Dark, Secondary, Surface, On Surface, Subtle, Error
- [x] Text styles defined: Display, H1, H2, Body, Caption
- [x] Nunito font imported via Google Fonts plugin
- [x] 8dp grid configured on frames
- [x] Color palette exported as reference (screenshot or PDF)

**Reference:** `friendsheet_design_brief.md` — Sections 2 & 3

**Tasks:**
- [x] **TASK-049.1:** Create Figma account and new project file
- [x] **TASK-049.2:** Install Google Fonts plugin, import Nunito
- [x] **TASK-049.3:** Define Color Styles from design brief palette
- [x] **TASK-049.4:** Define Text Styles (Display / H1 / H2 / Body / Caption)
- [x] **TASK-049.5:** Configure 8dp grid on base frame

---

### US-050: Flutter Theme Implementation

**As a** developer
**I want to** implement the design system as Flutter ThemeData
**So that** all screens automatically use the correct colors, typography and shape system

**Story Points:** 3
**Priority:** P0
**Status:** ✅ COMPLETED
**Labels:** `flutter`, `theme`, `dev`
**Mode:** ⚙️ Task (Claude Code)
**Depends on:** US-049

**Acceptance Criteria:**
- [x] `AppTheme` class created in `lib/core/theme/app_theme.dart`
- [x] `ColorScheme.light()` configured with design brief palette
- [x] `google_fonts` package added, Nunito set as `fontFamily`
- [x] `CardTheme` with `borderRadius: 16dp`
- [x] `ElevatedButton` theme with `borderRadius: 12dp`
- [x] `ThemeData` applied in `FriendsheetApp` widget
- [x] All existing screens visually verified — no layout breaks
- [x] `flutter analyze` passes with no warnings

**Tasks:**
- [x] **TASK-050.1:** Add `google_fonts` to pubspec.yaml, run `flutter pub get`
- [x] **TASK-050.2:** Create `lib/core/theme/app_theme.dart` with `AppTheme` class
- [x] **TASK-050.3:** Implement `ColorScheme`, `TextTheme`, `CardTheme`, `ButtonTheme`
- [x] **TASK-050.4:** Apply theme in `main.dart` → `FriendsheetApp`
- [x] **TASK-050.5:** Visual smoke test on all 4 main screens
- [x] **TASK-050.6:** Run `dart format .` and `flutter analyze`

---

## 🖼️ FEATURE-019: App Assets

**Description:** Creates the visual entry points of the app — the app icon visible in Google Play and on device, and the splash screen shown on launch. Both are required for M4 (Google Play Release).

**Priority:** P0
**Role:** UX Designer + Developer
**Status:** 📋 Planned

---

### US-056: App Icon Design & Integration

**As a** developer
**I want to** have a custom app icon that reflects Friendsheet's brand
**So that** the app looks professional in Google Play and on the user's device

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (March 04, 2026)
**Labels:** `design`, `midjourney`, `android`, `release`
**Mode:** 🎨 Design → ⚙️ Task
**Depends on:** US-049 (color palette defined)


**Acceptance Criteria:**
- [x] Icon generated in Midjourney using design brief prompt (warm green + amber palette)
- [x] Icon reviewed and approved (flat 2D style, rounded, character-driven)
- [x] Icon exported as 1024×1024 PNG from Figma
- [x] `flutter_launcher_icons` package configured and icons generated
- [x] Adaptive icon configured for Android (foreground + background layers)
- [x] Icon verified on emulator and physical device

**Midjourney Prompt (starting point — iterate as needed):**
```
friendly mobile app icon, two cartoon characters hugging or waving,
flat 2D illustration, rounded shapes, bold outlines,
warm green #43A047 and amber #FFB300 color palette,
white background, simple geometric style, duolingo-inspired,
app store icon format, square composition, --ar 1:1 --style raw --v 6
```

**Tasks:**
- [x] **TASK-056.1:** Generate 4–6 icon variants in Midjourney, select best
- [x] **TASK-056.2:** Refine in Figma — adjust colors to match palette exactly
- [x] **TASK-056.3:** Export 1024×1024 PNG
- [x] **TASK-056.4:** Add `flutter_launcher_icons` to pubspec.yaml
- [x] **TASK-056.5:** Configure adaptive icon (foreground + `#FAFAF7` background)
- [x] **TASK-056.6:** Run `dart run flutter_launcher_icons` and verify output

---

### US-052: Splash Screen

**Status:** ✅ COMPLETED (March 04, 2026)
**Story Points:** 3
**Labels:** `design`, `flutter`, `release`
**Mode:** 🎨 Design → ⚙️ Task
**Depends on:** US-056 (icon/branding established)

**Acceptance Criteria:**
- [x] MP4 animation asset added to `assets/animations/splash.mp4`
- [x] `video_player` package added for MP4 playback
- [x] `SplashScreen` widget created — plays MP4 + shows "Friendsheet" in Nunito ExtraBold below
- [x] Splash disappears automatically when MP4 finishes playing
- [x] After splash completes → navigate to `AuthWrapper` (auth check happens in background)
- [x] Background color: `#FAFAF7` (warm white)
- [x] "Friendsheet" text color: `#43A047` (primary green)
- [x] Tested on emulator — no jank, smooth playback

**Tasks:**
- [x] **TASK-052.1:** Add MP4 to `assets/animations/` and register in `pubspec.yaml`
- [x] **TASK-052.2:** Add `video_player` to `pubspec.yaml`
- [x] **TASK-052.3:** Create `SplashScreen` widget with `VideoPlayerController`
- [x] **TASK-052.4:** Wire `SplashScreen` as first route in `main.dart` — navigates to `AuthWrapper` on completion
- [x] **TASK-052.5:** Write widget test for `SplashScreen`

---

## 🧩 FEATURE-020: Illustrations & Empty States

**Description:** Adds human character illustrations to key screens — Login and empty states — giving the app personality and making it feel alive when there's no data yet.

**Priority:** P1
**Role:** UX Designer + Developer
**Status:** ✅ Compleated
---

### US-053: Login Screen Illustration & App-wide Typography Polish

**As a** user
**I want to** see a welcoming illustration and consistent branding on the login screen and throughout the app
**So that** the app feels warm, friendly and visually consistent from the first interaction

**Story Points:** 5
**Priority:** P1
**Status:** ✅ COMPLETED (March 2026)
**Labels:** `design`, `midjourney`, `flutter`, `typography`
**Mode:** 🎨 Design → ⚙️ Task
**Depends on:** US-050 (theme in place)

**Acceptance Criteria:**
- [x] Illustration generated in Midjourney (two friendly characters, warm scene)
- [x] Illustration exported as PNG (max 200KB)
- [x] Displayed above Google Sign-In button on LoginScreen
- [x] Responsive — scales correctly on different screen sizes
- [x] Does not push Sign-In button below visible area on small screens (min 360dp height)
- [x] People icon removed from LoginScreen
- [x] App title "Friendsheet" uses Pacifico font on LoginScreen
- [x] App title "Friendsheet" uses Pacifico font in AppBar (MainScreen)
- [x] App title "Friendsheet" uses Pacifico font in Drawer header
- [x] App title "Friendsheet" uses Pacifico font on SplashScreen
- [x] "Settings" title uses white color in SettingsScreen AppBar
- [x] Terms of Service link added to LoginScreen (opens in external browser)
- [x] Privacy Policy link added to LoginScreen (opens in external browser)
- [x] ToS and Privacy Policy hosted on GitHub Pages

**Midjourney Prompt (used):**
```
flat 2D illustration, group of 3-4 diverse cartoon friends,
laughing and spending time together, warm and joyful scene,
rounded character style, green #43A047 and amber #FFB300 color palette,
white background, simple geometric shapes, duolingo-inspired style,
horizontal composition, mobile app onboarding illustration,
no text, no letters, clean edges
--ar 3:2 --style raw --v 6.1
```

**Tasks:**
- [x] **TASK-053.1:** Illustration already present in `assets/images/`
- [x] **TASK-053.2:** Register `login_illustration.png` in `pubspec.yaml`
- [x] **TASK-053.3:** Integrate illustration into `LoginScreen` layout
- [x] **TASK-053.4:** Test on small screen (360dp width) — verify button visibility
- [x] **TASK-053.5:** Add `'displays login illustration'` test
- [x] **TASK-053.6:** Remove `Icon(Icons.people_alt)` from LoginScreen
- [x] **TASK-053.7:** Replace title font with Pacifico on LoginScreen
- [x] **TASK-053.8:** Add ToS as plain text with TODO comment (url_launcher pending)
- [x] **TASK-053.9:** Verify `url_launcher` gitignore — no changes needed
- [x] **TASK-053.10:** Add `url_launcher: ^6.3.0` to `pubspec.yaml`
- [x] **TASK-053.11:** Add `https` scheme intent to `AndroidManifest.xml`
- [x] **TASK-053.12:** Replace ToS text with tappable RichText (ToS + Privacy Policy)
- [x] **TASK-053.13:** Update LoginScreen tests for RichText links
- [x] **TASK-053.14:** Apply Pacifico to AppBar title (MainScreen)
- [x] **TASK-053.15:** Apply Pacifico to Drawer header (MainScreen)
- [x] **TASK-053.16:** Apply Pacifico to SplashScreen title
- [x] **TASK-053.17:** Fix Settings AppBar title color to white

**GitHub Pages:**
- Terms of Service: `https://aleksanderginalski.github.io/Friendsheet-App/terms`
- Privacy Policy: `https://aleksanderginalski.github.io/Friendsheet-App/privacy`

**Definition of Done:**
- [x] Illustration visible on LoginScreen
- [x] Pacifico font consistent across LoginScreen, AppBar, Drawer, SplashScreen
- [x] ToS and Privacy Policy links functional
- [x] GitHub Pages live with both documents
- [x] 365/365 tests passing
- [x] `flutter analyze` — no issues
- [x] Code reviewed and committed

---

### US-054: Empty States — Meetings & Friends

**As a** user
**I want to** see a friendly illustration when my meetings or friends list is empty
**So that** the app feels welcoming even before I've added any data

**Story Points:** 3
**Priority:** P1
**Status:** 📋 Planned
**Labels:** `design`, `midjourney`, `flutter`
**Mode:** 🎨 Design → ⚙️ Task
**Depends on:** US-050
**Status:** ✅ COMPLETED (March 05, 2026)

**Acceptance Criteria:**
- [x] Empty state illustration for MeetingsListScreen (no meetings added yet)
- [x] Empty state illustration for PersonsListScreen (no friends added yet)
- [x] Each empty state: illustration + short friendly message + optional CTA button
- [x] Illustrations consistent in style (same Midjourney style parameters)
- [x] Messages are warm and encouraging, not generic ("No data found")

**Empty State Copy:**
- Meetings: *"No meetings yet — tap + to add your first one!"*
- Friends: *"No friends added yet — tap + to get started!"*

**Midjourney Prompts (starting points):**

Meetings empty state:
```
small flat illustration, two cartoon friends sitting at a cafe table,
smiling and talking, simple rounded characters, warm colors,
green and amber palette, white background, minimal detail,
mobile app empty state style, duolingo character energy,
--ar 4:3 --style raw --v 6
```

Friends empty state:
```
flat 2D illustration, single cartoon character waving hello,
friendly pose, simple rounded shapes, bold outline,
warm green color scheme, white background, minimal,
mobile app illustration, --ar 1:1 --style raw --v 6
```

**Tasks:**
- [x] **TASK-054.1:** Generate both illustrations in Midjourney
- [x] **TASK-054.2:** Create reusable `EmptyStateWidget(image, message, onAction)` component
- [x] **TASK-054.3:** Integrate into `MeetingsListScreen`
- [x] **TASK-054.4:** Integrate into `PersonsListScreen`
- [x] **TASK-054.5:** Write widget test for `EmptyStateWidget`

---

### US-055: Empty State — Activities

**As a** user
**I want to** see a friendly illustration when my activities list is empty
**So that** the app feels consistent and polished across all tabs

**Story Points:** 2
**Priority:** P2
**Status:** ✅ COMPLETED (March 06, 2026)
**Labels:** `design`, `flutter`
**Mode:** 🎨 Design → ⚙️ Task
**Depends on:** US-054 (reuse EmptyStateWidget from US-054)


**Acceptance Criteria:**
- [x] Empty state displayed in ActivitiesListScreen when no categories exist
- [x] Empty state displayed when search returns no results
- [x] Uses EmptyStateWidget component from US-054
- [x] Illustration consistent with Meetings and Friends empty states
- [x] Message: "No activities yet — tap + to create your first category!"
- [x] 51 custom PNG icons replacing Material Icons
- [x] ActivityIcon widget with Icons.category fallback
- [x] Subcategory indentation with T/L tree lines (CustomPainter)
- [x] SharedSearchBar reusable across Activities, Friends, Meetings
- [x] Icon picker rebuilt as 2D scrollable GridView
- [x] AlertDialog replaced with Dialog (RenderIntrinsicWidth fix)

**Tasks:**
- [x] **TASK-055.1:** Generate illustration in Midjourney (reuse style params from US-054)
- [x] **TASK-055.2:** Integrate `EmptyStateWidget` into `ActivitiesListScreen`
- [x] **TASK-055.3:** Shared search bar + Activities search fix
- [x] **TASK-055.4:** Empty State + icon color + icon picker grid
- [x] **TASK-055.5:**  Restore GridView scrolling in icon picker
- [x] **TASK-055.6:** Update activity_icons_test.dart for PNG API


## 📋 Design Dependency Map

```
US-049 Figma Setup
    └── US-050 Flutter Theme ──────────────┐
                                           ├── US-053 Login Illustration
US-051 App Icon ────────────────────────   ├── US-054 Empty States (Meetings + Friends)
    └── US-052 Splash Screen               └── US-055 Empty State (Activities)
```

**Blocking M4 (Google Play Release):**
- US-051 App Icon ← required by store
- US-052 Splash Screen ← required for polish
- US-050 Flutter Theme ← required for visual consistency

**Non-blocking (can ship to M4 without these):**
- US-053 Login Illustration
- US-054 Empty States
- US-055 Empty State Activities


### US-077: UI Assets — Drawer Illustration & Meetings List

**As a** user
**I want** to see a graphic in the side drawer header and a decorative image at the end of the Pending Meetings list, with meeting names visibly indented under month headers
**So that** the app feels visually complete and the meeting hierarchy is immediately readable

**Labels:** `ui` `design` `P2`
**Story Points:** 5
**Priority:** P2
**Status:** 📋 Planned
**Feature:** FEATURE-020: Illustrations & Empty States / FEATURE-006: Meetings View
**Epic:** EPIC-009 / EPIC-002

**Context:**
Three visual polish items grouped because all require user-supplied assets and touch the same general area (drawer + meetings list):

1. **Drawer header illustration** — green area below "Friendsheet" title is empty. User supplies asset.
2. **Pending Meetings end asset** — list ends abruptly. Decorative image as last list item. User supplies asset. Only shown when list has ≥1 item (not on empty state).
3. **My Meetings indentation** — meeting name items share left-alignment with month headers, making the tree look flat. Adding ~16–24dp extra left padding to meeting items makes the hierarchy obvious.

**Acceptance Criteria:**
- [ ] Graphic visible in green header area of side drawer, below "Friendsheet" label, correctly sized without overflow
- [ ] Decorative image visible at end of Pending Meetings list, after the last meeting card, only when list is non-empty
- [ ] Both assets registered in `pubspec.yaml` under `flutter: assets:`
- [ ] Meeting name items in My Meetings have visibly greater left indent than month header rows (16–24dp difference)
- [ ] No regression on drawer header layout, list scrolling, or meeting card interactions

**Tasks:**
- [ ] **TASK-077.1:** Confirm asset filenames, add both to `assets/` folder and `pubspec.yaml`
- [ ] **TASK-077.2:** Update drawer header widget — add `Image.asset` in the green area with correct sizing/constraints
- [ ] **TASK-077.3:** Add `Image.asset` as last item in Pending Meetings `ListView` builder, conditional on list non-empty
- [ ] **TASK-077.4:** Increase left `padding`/`margin` on meeting item tiles in My Meetings list
- [ ] **TASK-077.5:** Visual check on device — all three changes verified
- [ ] **TASK-077.6:** Run `flutter analyze` + `flutter test`, report back

**Definition of Done:**
- [ ] All three visual changes verified on device
- [ ] No layout overflow warnings
- [ ] `flutter analyze` clean, `flutter test` green

## 🎨 FEATURE-021: UX/UI Improvements — Statistics, Meetings & Friends

**Description:** Polishes the existing app experience across three core areas — statistics readability, meeting history navigation, and friends management — so Friendsheet feels production-ready before Google Play release.
**Priority:** P1
**Role:** Developer + UX Designer
**Status:** 📋 Planned

### US-071: Statistics Home — Illustration & Enhanced Year Picker

**As a** user
**I want to** see a decorative illustration on the Home statistics screen and a more intuitive year selector
**So that** the statistics tab feels polished and the year navigation is visually clear

**Story Points:** 5
**Priority:** P1
**Status:** ✅ COMPLETED (March 06, 2026)
**Labels:** `design`, `statistics`, `ux`
**Mode:** 🎨 Design → ⚙️ Task

**Acceptance Criteria:**
- [x] Empty space above YearStepper filled with provided `statistics_illustration` asset
- [x] Illustration is responsive — does not obscure content on small screens
- [x] YearStepper horizontally centered; active year visually prominent (size/color)
- [x] Adjacent years (±1) visible but dimmed — suggest swipeability
- [x] Arrows spaced further from the year label to encourage swipe gesture usage
- [x] Year boundary logic preserved (no arrow when no data beyond boundary)

**Tasks:**
- [x] **TASK-071.1:** Add `statistics_illustration` asset to `assets/images/`, register in `pubspec.yaml`
- [x] **TASK-071.2:** Integrate illustration into `StatisticsSection` — bottom of screen, left-aligned
- [x] **TASK-071.3:** Refactor `YearStepper` — arrows outside, dimmed neighbour years, centered active year
- [x] **TASK-071.4:** Write widget tests for updated `YearStepper`

---

### US-057: Filter Icon & Select All / Deselect All

**As a** user
**I want to** open activity/person filters via a filter icon and quickly select or deselect all items
**So that** the filter control is more intuitive and faster to use

**Story Points:** 5
**Priority:** P1
**Status:** ✅ COMPLETED (March 06, 2026)
**Labels:** `statistics`, `ux`, `filter`
**Mode:** ⚙️ Task

**Acceptance Criteria:**
- [x] Gear icon (⚙️) replaced with provided `filter_icon` asset in all statistics widgets
- [x] `ActivityVisibilityDialog` has "Select all" / "Deselect all" buttons
- [x] `PersonVisibilityDialog` has "Select all" / "Deselect all" buttons
- [x] Deselecting all items does not crash — chart shows empty/no-data state
- [x] Existing "Auto-select top 10" logic unchanged

**Tasks:**
- [x] **TASK-057.1:** Add `filter_icon` asset to `assets/images/`, register in `pubspec.yaml`
- [x] **TASK-057.2:** Replace gear icon with `filter_icon` in `ActivityBreakdownWidget`, `WhoPerActivityWidget`, `InteractionDistributionWidget`
- [x] **TASK-057.3:** Add "Select all" / "Deselect all" to `ActivityVisibilityDialog`
- [x] **TASK-057.4:** Add "Select all" / "Deselect all" to `PersonVisibilityDialog`
- [x] **TASK-057.5:** Write tests for select/deselect all logic

---

### US-058: Who Per Activity — Person Filter Dialog & Activity Tree Picker

**As a** user
**I want to** filter persons in Who Per Activity via a dialog and pick activities from a visual tree
**So that** I can manage which people I see and navigate the activity hierarchy intuitively

**Story Points:** 8
**Priority:** P1
**Status:** ✅ COMPLETED (March 12, 2026)
**Labels:** `statistics`, `who-per-activity`, `ux`
**Mode:** ⚙️ Task

**Acceptance Criteria:**
- [x] `ActivitySelectorDialog` refactored to show full category tree with icons (parent → child hierarchy)
- [x] Selecting an activity in the tree refreshes the chart immediately
- [x] Person filtering available via filter icon (same pattern as US-057)
- [x] Person filter dialog has checkboxes + "Select all" / "Deselect all"
- [x] Long-press on bar removed — person visibility managed exclusively via Person Filter Dialog
- [x] Person Filter Dialog includes "Auto-select top 10" button (top 10 by weightSum for current activity)
- [x] Activity icons consistent with Activities tab

**Tasks:**
- [x] **TASK-058.1:** Refactor `ActivitySelectorDialog` — replace flat list with tree layout using `ActivityCategory` hierarchy and icons
- [x] **TASK-058.2:** Add filter icon to `WhoPerActivityWidget` header
- [x] **TASK-058.3:** Build `WhoPerActivityPersonFilterDialog` — checkboxes + select/deselect all
- [x] **TASK-058.4:** Wire dialog into `WhoPerActivityWidget`; preserve long-press as shortcut
- [x] **TASK-058.5:** Write tests

---

### US-059: Meetings — Monthly Grouping, Compact Cards & Expandable Search

**As a** user
**I want to** see meetings grouped by month within each year, with smaller cards and an expandable search bar
**So that** I can navigate my meeting history more efficiently

**Story Points:** 8
**Priority:** P1
**Status:** ✅ COMPLETED (March 10, 2026)
**Labels:** `meetings`, `ux`, `search`
**Mode:** ⚙️ Task

**Acceptance Criteria:**
- [x] Meetings grouped: Year → Month (e.g. "March 2026 · 4 meetings")
- [x] `MeetingCard` uses compact layout — reduced padding and font sizes
- [x] Month sections are collapsible (same pattern as current year sections)
- [x] Current month expanded by default; previous month expanded; older months collapsed
- [x] Search icon in `MeetingsListScreen` AppBar — tap opens text input field (same UX as `ActivitiesListScreen`)
- [x] Same expandable search pattern applied to `PersonsListScreen` (Friends tab)
- [x] Search results work correctly with new month-grouped structure

**Tasks:**
- [x] **TASK-059.1:** Extend `MeetingsListProvider` — add month-level grouping logic (`Map<int, Map<int, List<Meeting>>>`)
- [x] **TASK-059.2:** Refactor `MeetingsListScreen` — render year → month sections with collapse/expand
- [x] **TASK-059.3:** Update `MeetingCard` — compact variant (reduced padding, smaller font)
- [x] **TASK-059.4:** Implement expandable `SearchBar` in `MeetingsListScreen` AppBar (mirror `ActivitiesListScreen` pattern)
- [x] **TASK-059.5:** Implement expandable `SearchBar` in `PersonsListScreen` AppBar
- [x] **TASK-059.6:** Write widget tests for month grouping and search behavior

---

### US-060: Statistics Visibility Panel

**As a** user
**I want to** manage which statistics cards are visible via a settings panel instead of long-press
**So that** I have a clear and discoverable way to configure my dashboard

**Story Points:** 5
**Priority:** P1
**Status:** ✅ COMPLETED (March 11, 2026)
**Labels:** `statistics`, `ux`, `home-screen`
**Mode:** ⚙️ Task

**Acceptance Criteria:**
- [x] Long-press on carousel card removed as a hide mechanism
- [x] Provided `stats_options_icon` asset shown in statistics section header
- [x] Tapping icon opens a dialog with one checkbox per statistics card
- [x] Unchecking a card hides it from the carousel
- [x] Minimum 1 card must remain visible — last checkbox cannot be unchecked
- [x] Persistence in `SharedPreferences` key `stats_carousel_hidden_cards` unchanged
- [x] US-051 empty state ("Long-press to restore") removed; replaced by dialog-driven restore
- [x] Left/right arrow buttons displayed in statistics section header, flanking the "Statistics" title: `[< Statistics  🎛]`
- [x] Tapping left arrow navigates to previous carousel card (wraps from first to last)
- [x] Tapping right arrow navigates to next carousel card (wraps from last to first)
- [x] Arrow navigation works in parallel with existing swipe gesture
- [x] Arrows respect hidden cards — skips hidden cards during navigation
- [x] Arrows are disabled (or hidden) when only 1 card is visible

**Tasks:**
- [x] **TASK-060.1:** Add `stats_options_icon` asset, register in `pubspec.yaml`
- [x] **TASK-060.2:** Remove `GestureDetector(onLongPress)` from carousel pages in `StatisticsSection`
- [x] **TASK-060.3:** Build `StatisticsVisibilityDialog` — checkbox per `StatCard` enum value, enforce min 1 visible
- [x] **TASK-060.4:** Wire dialog into `StatisticsSection` header
- [x] **TASK-060.5:** Update `StatisticsProvider` — remove long-press toggle path, keep dialog toggle
- [x] **TASK-060.6:** Update existing US-051 tests to reflect removed long-press behavior
- [x] **TASK-060.7:** Statistics Carousel Arrow Navigation

---

### US-061: Friends — Nicknames & Autocomplete

**As a** user
**I want to** add nicknames to friends and search for them by nickname when adding meetings
**So that** I can find people faster without remembering their full name

**Story Points:** 8
**Priority:** P2
**Status:** 📋 Planned
**Labels:** `friends`, `data-model`, `autocomplete`
**Mode:** ⚙️ Task

**Acceptance Criteria:**
- [ ] `Person` model extended with `nicknames: List<String>` (empty list = no nicknames)
- [ ] `PersonDetailScreen` allows adding, editing and removing nicknames
- [ ] Autocomplete in `AddMeetingScreen` searches `firstName`, `lastName` **and** all `nicknames`
- [ ] Suggestion displays: full name + nickname in parentheses, e.g. `Małgorzata Bielawska (Gosia)`
- [ ] Firestore schema change is backwards-compatible — missing field treated as empty list
- [ ] Data migration not required (field is optional)

**Tasks:**
- [ ] **TASK-061.1:** Extend `Person` Freezed model — add `nicknames: List<String>`, update `fromFirestore`/`toFirestore`, regenerate `.freezed.dart`
- [ ] **TASK-061.2:** Update `PersonRepository` — persist and read `nicknames` field
- [ ] **TASK-061.3:** Add nickname management UI to `PersonDetailScreen` (add/remove chips)
- [ ] **TASK-061.4:** Extend `PersonAutocomplete` — include nicknames in search, update suggestion label format
- [ ] **TASK-061.5:** Write tests (model, repository, autocomplete search logic)

---

### US-062: Friends — Groups

**As a** user
**I want to** organize friends into named groups
**So that** I can find and browse friends more easily

**Story Points:** 8
**Priority:** P2
**Status:** 📋 Planned
**Labels:** `friends`, `data-model`, `groups`
**Mode:** ⚙️ Task
**Depends on:** US-061 (stable `Person` model)

**Acceptance Criteria:**
- [ ] New `FriendGroup` model (`id`, `name`, `personIds: List<String>`)
- [ ] `FriendGroupRepository` with full CRUD stored under `users/{uid}/friend_groups`
- [ ] `PersonsListScreen` shows friends grouped into named sections
- [ ] User can create, rename and delete groups from the Friends tab
- [ ] A person can belong to multiple groups
- [ ] People without a group shown in an "Ungrouped" section
- [ ] Search works globally across all groups

**Tasks:**
- [ ] **TASK-062.1:** Create `FriendGroup` Freezed model + `FriendGroupRepository`
- [ ] **TASK-062.2:** Add Firestore security rules for `friend_groups` subcollection
- [ ] **TASK-062.3:** Build `FriendGroupsProvider` — CRUD + loading state
- [ ] **TASK-062.4:** Refactor `PersonsListScreen` — render group sections with "Ungrouped" fallback
- [ ] **TASK-062.5:** Build group management UI (create/rename/delete group, assign persons)
- [ ] **TASK-062.6:** Write tests (model, repository, provider)

---

### US-063: Chart Visual Enhancement — Colors & Depth Effect

**As a** user
**I want to** see statistics charts with richer colors and a depth effect
**So that** the data visualizations feel more engaging and premium

**Story Points:** 5
**Priority:** P2
**Labels:** `statistics`, `design`, `charts`
**Mode:** 🎨 Design → ⚙️ Task
**Status:** ✅ COMPLETED (March 06, 2026)

**Acceptance Criteria:**
- [x] Bars in `ActivityBreakdownWidget`, `WhoPerActivityWidget`, `InteractionDistributionWidget` use a new color palette (not constrained to existing app palette)
- [x] Each bar rendered with a vertical gradient (e.g. lighter top → darker bottom or accent-based)
- [x] Color-per-id assignment remains stable (`categoryId` / `personId` → same color every render)
- [x] Visual effect does not reduce label or value readability
- [x] All existing chart tests pass without modification

**Tasks:**
- [x] **TASK-063.1:** Design new chart color palette (6–10 colors) — optimised for visual depth
- [x] **TASK-063.2:** Implement `ChartGradientBar` helper — `LinearGradient` applied to bar paint in `CustomPainter`
- [x] **TASK-063.3:** Replace flat color bars in `ActivityBreakdownWidget` with `ChartGradientBar`
- [x] **TASK-063.4:** Replace flat color bars in `WhoPerActivityWidget` with `ChartGradientBar`
- [x] **TASK-063.5:** Replace flat color bars in `InteractionDistributionWidget` with `ChartGradientBar`
- [x] **TASK-063.6:** Verify all chart tests pass; update color assertions if needed

### US-064: Easter Egg — Special Thanks

**As a** developer
**I want to** hide a special thanks message triggered by tapping the app title 8 times within 4 seconds
**So that** I can acknowledge the person who named Friendsheet in a fun, discoverable way

**Story Points:** 2
**Priority:** P3
**Status:** ✅ COMPLETED (March 2026)
**Labels:** `easter-egg`, `ux`
**Mode:** ⚙️ Task
**Dependencies:** None

**Acceptance Criteria:**
- [x] Tapping "Friendsheet" label in Home tab header 8 times within 4 seconds triggers the easter egg
- [x] Timer resets if 4 seconds pass between taps without reaching 8
- [x] Pop-up displays: provided `easter_egg_icon` asset + text *"Special thanks to Agatka who came up with the name for this app 💚"*
- [x] Tapping anywhere on the pop-up dismisses it
- [x] Easter egg can be triggered again after dismissal
- [x] No visual hint that the easter egg exists

**Tasks:**
- [x] **TASK-064.1:** Add `easter_egg_icon` asset to `assets/images/`, register in `pubspec.yaml`
- [x] **TASK-064.2:** Add tap counter + timer logic to `HomeScreen` (8 taps / 4s window)
- [x] **TASK-064.3:** Build `EasterEggDialog` — `easter_egg_icon` + thank-you message, dismiss on tap
- [x] **TASK-064.4:** Write widget test for tap counter logic

# 📦 EPIC-004: Friendsheet M4 - Google Play Release

**Goal:** Publish Friendsheet on Google Play Store as a publicly downloadable app

**Business Value:** Portfolio milestone — demonstrates ability to ship a real product. Enables friends to use the app without manual APK installation.

**Prerequisites:** M2 and M3 completed — app must be "showable" with CRUD and statistics.

---

## 🚀 FEATURE-011: Store Release Preparation

**Priority:** P0  
**Role:** Developer + DevOps  
**Status:** 📋 Planned

---

### US-046: App Store Assets & Metadata

**As a** developer  
**I want to** prepare all required Google Play assets  
**So that** the app can be submitted for review
**Status:** ✅ COMPLETED (March 12, 2026)

**Story Points:** 5  
**Priority:** P0

**Acceptance Criteria:**
- [x] App icon (512x512 PNG)
- [x] Feature graphic (1024x500 PNG)
- [x] Screenshots (min 2, phone format)
- [x] Short description (max 80 chars)
- [x] Full description
- [x] Privacy Policy published at accessible URL

**Tasks:**
- [x] **TASK-046.1:** Design app icon - 2h
- [x] **TASK-046.2:** Create store screenshots - 2h
- [x] **TASK-046.3:** Write store description - 1h
- [x] **TASK-046.4:** Create and publish Privacy Policy page - 2h

---

### US-032: Production Build Configuration

**As a** developer  
**I want to** configure a signed production build  
**So that** the app can be published on Google Play

**Story Points:** 5  
**Priority:** P0
**Status:** ✅ COMPLETED (March 04, 2026)

**Acceptance Criteria:**
- [x] Keystore generated and securely stored (NOT in git)
- [x] `key.properties` file configured and gitignored
- [x] Release build variant configured in build.gradle
- [x] App Bundle (.aab) generated successfully
- [x] Version code and version name set
- [x] ProGuard/R8 rules configured if needed

**Tasks:**
- [x] **TASK-032.1:** Generate keystore and document storage - 1h
- [x] **TASK-032.2:** Configure signing in build.gradle - 1h
- [x] **TASK-032.3:** Update .gitignore for keystore files - 30min
- [x] **TASK-032.3:** Build and test release AAB - 1h
- [x] **TASK-032.4:** Update CI/CD for release builds - 1h

---

### US-033: Google Play Developer Account Setup

**As a** developer  
**I want to** set up my Google Play Developer account  
**So that** I can publish and manage the app

**Story Points:** 3  
**Priority:** P0
**Status:** ✅ COMPLETED (March 12, 2026)

**Acceptance Criteria:**
- [x] Google Play Developer account created ($25 one-time fee)
- [x] Account verified
- [x] App created in Play Console
- [x] Internal testing track configured
- [x] App tested via Internal Testing before public release

**Tasks:**
- [x] **TASK-033.1:** Create Google Play Developer account - 30min
- [x] **TASK-033.2:** Create app in Play Console - 30min
- [x] **TASK-033.3:** Upload to Internal Testing track - 1h
- [x] **TASK-033.4:** Test Internal build on real device - 1h
- [x] **TASK-033.5:** Submit for production review - 1h

---

---

# 📦 EPIC-005: Friendsheet M6 - Meeting Import Hub

**Goal:** Allow users to import past meetings from external sources or use help of their friends who already have Friendsheet — reducing friction of retroactive data entry and solving the cold-start problem for new users.

**Business Value:** Demonstrates external OAuth API integration skills (portfolio). Gives new users a fast path to meaningful data without manual entry. Architected as an extensible import system — new sources can be added without changing the shared inbox layer.

**Architecture Decision:** `MeetingInbox` is **source-agnostic** — both FEATURE-013 and FEATURE-014 produce a list of `ImportCandidate` objects that feed into the same `MeetingInboxScreen`. Adding a new import source in the future requires only a new data-fetching layer, not a new inbox.

**Import flow (both features):**
```
External Source → ImportCandidate list → MeetingInboxScreen → Firestore
```

**Local-only state:** The inbox lives in `MeetingInboxProvider` (in-memory). It is NOT persisted to Firestore. If the user closes the app mid-import, the session resets. This is intentional — keeps implementation simple for M6.

---

## 📅 FEATURE-013: Google Calendar Import

**Description:** User imports past calendar events from Google Calendar into Friendsheet. Events are pre-processed into ImportCandidates and reviewed one by one in the shared Meeting Inbox before being saved as meetings.

**Priority:** P0
**Role:** Developer
**Status:** 📋 Planned
**Target:** Before Google Play release (M4)

**Architecture Notes:**
- OAuth scope: `https://www.googleapis.com/auth/calendar.readonly`
- Token stored via `flutter_secure_storage`
- Calendar selection and ALL-DAY filter managed in Settings (added to existing SettingsScreen)
- Only events with ≥ 2 attendees qualify as import candidates
- Email parsing heuristic: `firstname.lastname@domain` → suggested as new Person

---

### US-065: Home Screen Onboarding CTA

**As a** new user with fewer than 50 meetings
**I want to** see a prompt on the Home Screen encouraging me to import past meetings from Google Calendar
**So that** I discover the import feature and can quickly build my meeting history

**Story Points:** 3
**Priority:** P0
**Status:** ✅ COMPLETED (March 2026)
**Labels:** `flutter`, `onboarding`, `ux`
**Depends on:** None (standalone UI component)

**Acceptance Criteria:**
- [x] CTA card visible on Home Screen when user has < 50 total meetings in Firestore
- [x] Card contains: icon, headline ("Import your past meetings"), subtext, primary button "Import from Calendar"
- [x] CTA dismissed permanently when user taps "Import from Calendar" OR taps explicit dismiss (X)
- [x] Dismissed state persisted in SharedPreferences (key: `onboarding_calendar_cta_dismissed`)
- [x] CTA not shown if user already has ≥ 50 meetings regardless of dismissed state
- [x] Tapping "Import from Calendar" navigates to US-057 (Calendar Permission screen)
- [x] CTA uses app theme colors — consistent with design system

**Tasks:**
- [x] **TASK-065.1:** Create `CalendarOnboardingCta` widget — card with icon, headline, subtext, button, dismiss X
- [x] **TASK-065.2:** Add meeting count check to `HomeScreenProvider` (or `StatisticsProvider`) — exposes `bool showCalendarCta`
- [x] **TASK-065.3:** Persist dismissed state via SharedPreferences key `onboarding_calendar_cta_dismissed`
- [x] **TASK-065.4:** Integrate `CalendarOnboardingCta` into `HomeScreen` — above statistics section
- [x] **TASK-065.5:** Write widget tests — CTA shown < 50, hidden ≥ 50, hidden after dismiss
- [x] **TASK-065.6:** Side Bar: "Import from Calendar" ListTile
- [x] **TASK-065.7:** Refactor HomeScreen
- [x] **TASK-065.8:** Register assset in pubspec.yaml


---

### US-066: Google Calendar Permission, Connection & Settings

**As a** user
**I want to** grant Friendsheet read-only access to my Google Calendar and configure which calendars to import from
**So that** the app fetches only the events I want

**Story Points:** 5
**Priority:** P0
**Status:** ✅ COMPLETED (March 2026)
**Labels:** `flutter`, `oauth`, `settings`
**Depends on:** US-056

**Acceptance Criteria:**
- [x] First-time: explanation screen/bottom sheet — what access is requested and why
- [x] OAuth consent shown using `google_sign_in` with scope `calendar.readonly`
- [x] On grant: fetch list of user's calendars, navigate to calendar selection in Settings
- [x] On deny: informative message shown, user can retry
- [x] Settings section added to existing `SettingsScreen`:

**Tasks:**
- [x] **TASK-066.1:** Add `calendar.readonly` scope to `google_sign_in` configuration
- [x] **TASK-066.2:** Add `flutter_secure_storage` to `pubspec.yaml` (check .gitignore first)
- [x] **TASK-066.3:** Create `GoogleCalendarService` — auth flow, token storage, calendar list fetch
- [x] **TASK-066.4:** Build `CalendarPermissionScreen` — explanation + grant/deny flow
- [x] **TASK-066.5:** Add Calendar Settings section to `SettingsScreen` — calendar checkboxes + ALL-DAY toggle
- [x] **TASK-066.6:** Persist calendar selection and ALL-DAY preference in SharedPreferences
- [x] **TASK-066.7:** Write tests for `GoogleCalendarService` auth flow and settings persistence

---

### US-067: Browse & Select Calendar Events

**As a** user
**I want to** browse my Google Calendar events within a chosen date range and select the ones I want to import
**So that** I can choose exactly which past meetings to add to Friendsheet

**Story Points:** 8
**Priority:** P0
**Status:** ✅ COMPLETED (March 2026)
**Labels:** `flutter`, `google-calendar-api`
**Depends on:** US-066

**Acceptance Criteria:**
- [x] Date range picker — "from" and "to" date (default range: last 12 months)
- [x] "Apply Filters" triggers Google Calendar API call with selected date range and calendar filters
- [x] All past events qualify — no attendee count filter
- [x] Each event card shows: title, date, all-day indicator, attendee emails (if any)
- [x] Multi-select with checkboxes
- [x] "Select All" / "Deselect All" action
- [x] Empty state if no qualifying events found in range
- [x] Primary CTA: "Import (N)" — disabled when 0 selected
- [x] Tapping CTA creates `ImportCandidate` list (stub navigation — MeetingInboxScreen in future US)
- [x] Filter panel (date range + calendar checkboxes + all-day toggle) collapsible on same screen
- [x] CTA card on HomeScreen: no dismiss button, visible until user reaches 50 meetings
- [x] Drawer tile: dynamic label — "Import from Calendar" / "Browse & Import Events" based on connection state
- [x] Settings: only "Disconnect Calendar" remains (calendar selection checkboxes removed)
- [x] `ValueNotifier<bool>` in `GoogleCalendarService` for reactive connection state

**Tasks:**
- [x] **TASK-067.1:** Gitignore check + add `uuid` package
- [x] **TASK-067.2:** Create `CalendarEvent` Freezed model
- [x] **TASK-067.3:** Create `ImportCandidate` Freezed model + `ImportSourceType` enum
- [x] **TASK-067.4:** Run build_runner
- [x] **TASK-067.5:** Add `fetchEvents()` + `_fetchEventsForCalendar()` to `GoogleCalendarService`
- [x] **TASK-067.6:** Create `CalendarEventsProvider`
- [x] **TASK-067.7:** Create `CalendarEventsScreen` + `CalendarEventCard` widget
- [x] **TASK-067.8:** Wire navigation from HomeScreen CTA and SettingsScreen
- [x] **TASK-067b.1–4:** Remove CTA dismiss button, dynamic drawer tile, Settings cleanup, remove SharedPreferences dismiss key
- [x] **TASK-067c.1–3:** Add `ValueNotifier` to `GoogleCalendarService`, replace `FutureBuilder` with `ValueListenableBuilder` in drawer and Settings
- [x] **TASK-067d–h:** Fix drawer OAuth flow via `CalendarPermissionScreen` + `onConnected` callback, fix stale context via `_openCalendarPermissionScreen()` on State, fix `finally/notifyListeners` race condition in `connectCalendar()`
- [x] **TASK-067i:** Fix token init race condition (ensureInitialized + Completer) and silent navigation failure (appNavigatorKey in MaterialApp)

**Known issues deferred:**
- CTA card flickers for ~1s on HomeScreen load (meetingCount initializes as 0) — deferred to US-073

**Definition of Done:**
- [x] `flutter analyze` — no issues
- [x] `flutter test` — 445/445 passed
- [x] Manual verification: all navigation flows work on first tap
- [x] No debug code in production

---

### US-068: Meeting Inbox — Review & Confirm

**As a** user
**I want to** review selected import candidates one by one, enrich them with details, and confirm which ones to save
**So that** each imported meeting has correct data before it enters Friendsheet

**Story Points:** 8
**Priority:** P0
**Status:** ✅ COMPLETED (March 10, 2026)
**Labels:** `flutter`, `ux`
**Depends on:** US-058

**Acceptance Criteria:**
- [x] `MeetingInboxScreen` shows list of all pending `ImportCandidate` cards
- [x] Progress indicator: "X of Y reviewed"
- [x] Tapping card opens `InboxItemEditScreen` with pre-filled fields:
  - [x] Meeting Name (pre-filled from event title, editable, max 50 chars)
  - [x] Date (pre-filled from event start date, editable via date picker)
  - [x] Weight (default: 3, Fibonacci stepper — same component as AddMeeting)
  - [x] Participants: attendee e-mails shown as person suggestions (using heuristic from US-058); user can accept, dismiss, or add manually
  - [x] Activities: standard activity autocomplete (no pre-fill)
- [x] "Confirm" saves meeting to Firestore, removes card from inbox
- [x] "Skip" removes card from inbox without saving
- [x] When inbox is empty: success screen showing count of added meetings + CTA "Go to Meetings"
- [x] Back navigation from `InboxItemEditScreen` returns to inbox list without data loss

**Tasks:**
- [x] **TASK-068.1:** Extend ImportCandidate with JSON support + run build_runner
- [x] **TASK-068.2:** Create MeetingInboxProvider
- [x] **TASK-068.3:** Create InboxItemEditProvider
- [x] **TASK-068.4:** Build MeetingInboxScreen
- [x] **TASK-068.5:** Build InboxItemEditScreen
- [x] **TASK-068.6:** Build ImportSuccessScreen
- [x] **TASK-068.7:** Write tests for MeetingInboxProvider and InboxItemEditProvider

**Architecture note (updated):** `MeetingInboxProvider` is persisted to
SharedPreferences (key: `meeting_inbox_candidates`) — candidates survive
app restarts. Provider is owned by `MainScreen` for full-session lifetime.
Drawer shows `Pending Meetings (N)` badge when inbox is non-empty.
Source-agnostic: Calendar (US-067) and Photos (US-070) both call
`addCandidates()` on the same provider.



### 🐛 US-078: Fix — "Failed to Load Calendar" on Browse & Import Events

**As a** user with Google Calendar connected
**I want** the calendar event screen to load reliably without manual reconnection
**So that** I can import events without interruption

**Labels:** `bug` `calendar` `P1`
**Story Points:** 3
**Priority:** P1
**Status:** ✅ COMPLETED (March 12, 2026)
**Feature:** FEATURE-013: Google Calendar Import
**Epic:** EPIC-005

**Context:**
Error appears intermittently — every few sessions or after a longer idle period. Disconnect + reconnect always fixes it, which points to an **expired OAuth token** not being refreshed automatically. The fix should: detect token expiry on the API call, silently refresh via `signInSilently()` and retry once, and only prompt the user to reconnect if the token cannot be refreshed (revoked/permission removed).

**Acceptance Criteria:**
- [x] If OAuth token is expired, the app silently refreshes it and retries — user sees no error
- [x] If token cannot be refreshed, a clear actionable message is shown: "Calendar access expired — please reconnect" with a "Reconnect" button
- [x] Generic "failed to load calendar" error is eliminated
- [x] No regression: connect and disconnect flows still work correctly
- [x] TC-CAL-001 passes

**Tasks:**
- [x] **TASK-078.1:** Audit `CalendarService` / calendar repository — identify where the API call fails and what error type is caught
- [x] **TASK-078.2:** Identify the `GoogleSignIn` token refresh path (`signInSilently()` / `getAccessToken()`)
- [x] **TASK-078.3:** Implement retry-on-auth-error: catch 401/auth error → call `signInSilently()` → retry calendar load once
- [x] **TASK-078.4:** If refresh fails, show actionable "Reconnect" CTA instead of generic error message
- [x] **TASK-078.5:** Run `flutter analyze` + `flutter test`, report back

**Definition of Done:**
- [x] Token expiry no longer produces "failed to load calendar"
- [x] Silent refresh works for the common expiry case
- [x] TC-CAL-001 passes
- [x] `flutter analyze` clean, `flutter test` green

---

## 📷 FEATURE-014: Google Photos Import

**Description:** User imports past meetings based on photos from Google Photos. Each selected photo creates an ImportCandidate with the photo's creation date pre-filled. Candidates flow into the shared Meeting Inbox (US-059) — same UX as Calendar import.

**Priority:** P1
**Role:** Developer
**Status:** 📋 Planned — Post Google Play release
**Target:** After M4 (non-blocking for store release)

**Architecture Notes:**
- OAuth scope: `https://www.googleapis.com/auth/photoslibrary.readonly`
- Shares `MeetingInboxProvider` and `MeetingInboxScreen` with FEATURE-013 — no duplication
- Photo is NOT stored in Firestore — only the creation date is used
- `sourceType: photos` on ImportCandidate distinguishes origin for analytics

---

### US-069: Google Photos Permission & Connection

**As a** user
**I want to** grant Friendsheet read-only access to my Google Photos
**So that** I can browse my photos to create meeting import candidates

**Story Points:** 5
**Priority:** P1
**Status:** 📋 Planned
**Labels:** `flutter`, `oauth`
**Depends on:** US-057 (reuses OAuth pattern from Calendar)

**Acceptance Criteria:**
- [ ] "Import from Photos" option accessible from Home Screen or import menu
- [ ] First-time: explanation screen — what photo access is requested and why
- [ ] Google Photos OAuth consent shown using `google_sign_in` extended scope
- [ ] On grant: navigate to Browse Photos screen (US-061)
- [ ] On deny: informative message, option to retry
- [ ] Permission revocable from Settings (alongside Calendar revoke option)
- [ ] Token stored via `flutter_secure_storage` (same service as Calendar token)

**Tasks:**
- [ ] **TASK-069.1:** Add `photoslibrary.readonly` scope to `GoogleCalendarService` (or extract shared `OAuthService`)
- [ ] **TASK-069.2:** Build `PhotosPermissionScreen` — reuse pattern from `CalendarPermissionScreen`
- [ ] **TASK-069.3:** Add "Revoke Photos Access" to Settings alongside Calendar revoke
- [ ] **TASK-069.4:** Write tests

---

### US-070: Browse & Select Photos

**As a** user
**I want to** browse my Google Photos and select photos that remind me of past meetings
**So that** each photo creates an import candidate with the correct date pre-filled

**Story Points:** 8
**Priority:** P1
**Status:** 📋 Planned
**Labels:** `flutter`, `google-photos-api`
**Depends on:** US-060

**Acceptance Criteria:**
- [ ] Photo grid — paginated (first page < 2s)
- [ ] Each photo shows thumbnail and creation date
- [ ] Multi-select with checkboxes (same pattern as US-058)
- [ ] "Select All" / "Deselect All"
- [ ] CTA: "Add to Meeting Inbox (N selected)"
- [ ] Each selected photo creates `ImportCandidate` with `date` from photo creation date, `title` empty (user fills in inbox), `sourceType: photos`
- [ ] Navigates to `MeetingInboxScreen` (US-059) — shared with Calendar import
- [ ] Photo NOT stored — only date used

**Tasks:**
- [ ] **TASK-070.1:** Implement `GooglePhotosService.fetchPhotos(pageToken)` — paginated Google Photos REST API
- [ ] **TASK-070.2:** Build `PhotoGridScreen` — thumbnail grid, multi-select
- [ ] **TASK-070.3:** Map selected photos to `ImportCandidate` list (date from metadata, title empty, sourceType: photos)
- [ ] **TASK-070.4:** Add candidates to `MeetingInboxProvider` and navigate to `MeetingInboxScreen`
- [ ] **TASK-070.5:** Write tests — pagination, candidate mapping, empty state

---
## 🔗 FEATURE-012: Invitation Code System

**Priority:** P0  
**Role:** Developer  
**Status:** 📋 Planned

---

### US-034: Generate Invitation Code

**As a** user  
**I want to** generate an invitation code for a friend  
**So that** they can import our shared meetings when they join the app

**Story Points:** 5  
**Priority:** P0

**Acceptance Criteria:**
- [ ] "Share with friend" option on Person Detail screen
- [ ] 6-character alphanumeric code generated (e.g. "FR4K9X")
- [ ] Code stored in Firestore with 48-hour TTL
- [ ] Code displayed with copy button and share sheet option
- [ ] Code expires after 48 hours
- [ ] User can see active/expired codes they generated

**Tasks:**
- [ ] **TASK-034.1:** Create InvitationCode model and Firestore collection - 2h
- [ ] **TASK-034.2:** Implement code generation logic in InvitationService - 2h
- [ ] **TASK-034.3:** Add Firestore Security Rules for invitations collection - 1h
- [ ] **TASK-034.4:** Build GenerateInvitationScreen UI - 2h
- [ ] **TASK-034.5:** Implement share sheet integration - 1h
- [ ] **TASK-034.6:** Write tests - 1h
- [ ] **TASK-034.7:** Extend `AccountDeletionService._deleteFirestoreData()` — add deletion of `users/{uid}/invitation_codes` subcollection to the batch delete sequence

**Architecture Note:**
`AccountDeletionService` (US-076) deletes all user subcollections on account removal.
When implementing US-034, extend `_deleteFirestoreData()` to also delete
`users/{uid}/invitation_codes` — otherwise orphaned codes remain in Firestore
after account deletion.


---

### US-035: Redeem Invitation Code

**As a** new user who received an invitation code  
**I want to** enter the code in the app  
**So that** I receive my shared meeting history instantly

**Story Points:** 8  
**Priority:** P0

**Acceptance Criteria:**
- [ ] "Enter invitation code" option on Home screen or onboarding
- [ ] Code input field with 6-character validation
- [ ] System validates code: exists, not expired, not already used
- [ ] On valid code: all meetings from sender where targetPerson appears are copied to recipient's Firestore
- [ ] Participants and activities from those meetings are also copied (deduplication by name)
- [ ] Code marked as used after successful redemption
- [ ] Success screen shows count of imported meetings
- [ ] Error messages for: invalid code, expired code, already used

**Tasks:**
- [ ] **TASK-175:** Create RedeemInvitationScreen - 2h
- [ ] **TASK-176:** Implement code validation in InvitationService - 1h
- [ ] **TASK-177:** Implement meeting copy logic (batch Firestore write) - 3h
- [ ] **TASK-178:** Implement person/activity deduplication logic - 2h
- [ ] **TASK-179:** Build success/error feedback screens - 1h
- [ ] **TASK-180:** Write tests - 2h

---

---

# 📦 EPIC-006: Friendsheet M7 - Custom Dashboard

**Goal:** Allow users to build a personalized view with the metrics that matter most to them

**Business Value:** Power users can configure the app to reflect their personal priorities — some care about activity diversity, others about frequency, others about specific relationships.

**Architecture Notes:**
- Dashboard config stored in Firestore per user (users/{uid}/dashboard_config)
- Each widget is a self-contained component that accepts a config object
- Widget library built on top of M3 statistics infrastructure

---

## 🎛️ FEATURE-014: Configurable Metrics Dashboard

**Priority:** P0  
**Role:** Developer + UX Designer  
**Status:** 📋 Planned

---

### US-038: Dashboard Screen with Default Widgets

**As a** user  
**I want to** see a dashboard with my key metrics  
**So that** I get a quick overview of my social life on the home screen

**Story Points:** 8  
**Priority:** P0

**Acceptance Criteria:**
- [ ] Dashboard accessible as main/home screen
- [ ] Default layout includes: recent meetings count, top person this month, top activity this month
- [ ] Widgets display data from StatisticsRepository (M3)
- [ ] Refresh on screen focus

**Tasks:**
- [ ] **TASK-190:** Create DashboardScreen scaffold - 2h
- [ ] **TASK-191:** Build default widget set (3 widgets) - 3h
- [ ] **TASK-192:** Connect to StatisticsRepository - 1h
- [ ] **TASK-193:** Write tests - 1h

---

### US-039: Dashboard Customization

**As a** user  
**I want to** add, remove and reorder dashboard widgets  
**So that** I see only the metrics I care about

**Story Points:** 13  
**Priority:** P1

**Acceptance Criteria:**
- [ ] Edit mode for dashboard (tap "Edit" to enter)
- [ ] Widget library with available widget types
- [ ] Drag to reorder widgets
- [ ] Remove widget (X button in edit mode)
- [ ] Add widget from library
- [ ] Configuration saved to Firestore
- [ ] Configuration restored on next app launch

**Tasks:**
- [ ] **TASK-194:** Implement dashboard config model and Firestore persistence - 2h
- [ ] **TASK-195:** Build widget library screen - 2h
- [ ] **TASK-196:** Implement drag-and-drop reordering - 3h
- [ ] **TASK-197:** Build edit mode UI - 2h
- [ ] **TASK-198:** Write tests - 1h

---

---

# 📦 EPIC-007: Friendsheet M8 - AI Assistant

**Goal:** Allow users to ask natural language questions about their social data and get AI-powered insights

**Business Value:** Transforms the app from a tracker into an intelligent social advisor. Demonstrates AI integration skills for portfolio.

**Architecture Notes:**
- Integration with external LLM API (Claude API or OpenAI — decision pending cost analysis)
- User data never sent to LLM without explicit consent — privacy-first approach
- Context window: relevant statistics summary sent as context, not raw Firestore data
- Spike required before full implementation to evaluate: API costs per query, response latency, privacy implications
- Consider: on-device models (Gemini Nano on Android) as zero-cost alternative for basic queries

**Decision Pending:**
- Which LLM API to use (Claude / OpenAI / Gemini Nano on-device)
- Cost model: per-query pricing vs subscription
- Privacy: what data is sent as context

---

## 🤖 FEATURE-015: AI-powered Insights

**Priority:** P0  
**Role:** Developer  
**Status:** 💡 Future - Spike Required

---

### US-040: AI Integration Spike

**As a** developer  
**I want to** evaluate LLM API options and costs  
**So that** I can make an informed decision before full implementation

**Story Points:** 5  
**Priority:** P0 (must complete before US-041)

**Acceptance Criteria:**
- [ ] At least 2 LLM APIs evaluated (e.g. Claude API, Gemini Nano)
- [ ] Cost per query estimated based on typical context size
- [ ] Latency measured for typical query
- [ ] Privacy implications documented
- [ ] Decision documented with rationale
- [ ] Simple proof of concept built

**Tasks:**
- [ ] **TASK-199:** Research Claude API and OpenAI pricing - 2h
- [ ] **TASK-200:** Research Gemini Nano on-device option - 2h
- [ ] **TASK-201:** Build minimal proof of concept with chosen API - 3h
- [ ] **TASK-202:** Document decision - 1h

---

### US-047: AI Assistant Screen

**As a** user  
**I want to** ask the AI assistant questions about my social life  
**So that** I get personalized insights beyond standard statistics

**Story Points:** 13  
**Priority:** P0

**Acceptance Criteria:**
- [ ] Chat-like UI for asking questions
- [ ] AI has context of user's statistics summary (not raw data)
- [ ] Example queries: "Who should I reach out to this week?", "What's my most social month?"
- [ ] Response streamed or shown with loading indicator
- [ ] User informed that data is sent to external API (consent)
- [ ] Error handling for API failures

**Tasks:**
- [ ] **TASK-203:** Create AIAssistantScreen with chat UI - 3h
- [ ] **TASK-204:** Implement context builder (statistics → prompt) - 2h
- [ ] **TASK-205:** Integrate chosen LLM API - 3h
- [ ] **TASK-206:** Implement consent/disclaimer flow - 1h
- [ ] **TASK-207:** Write tests - 1h

---

## 📝 Definition of Ready (DoR)

Before a User Story can be pulled into a sprint:
- [ ] User story written in standard format
- [ ] Acceptance criteria defined
- [ ] Dependencies identified
- [ ] Design/wireframes available (if UI story)
- [ ] Technical approach discussed

---

## ✅ Definition of Done (DoD)

Before a User Story is considered complete:
- [ ] Code written and follows style guide
- [ ] Unit tests written and pass
- [ ] Widget/integration tests (if applicable)
- [ ] Code reviewed and approved
- [ ] Merged to main branch
- [ ] Acceptance criteria met
- [ ] Documentation updated
- [ ] No critical bugs
- [ ] Tested on target device (Android)

---

## 🐛 Bug Tracking Template

```markdown
**Bug ID:** BUG-XXX
**Severity:** Critical / High / Medium / Low
**Priority:** P0 / P1 / P2 / P3
**Found in Sprint:** X
**Assigned to:** Developer Name

**Description:**
Clear description of the bug

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Screenshots/Logs:**
Attach if available

**Environment:**
- Device: 
- OS Version:
- App Version:
```

---

---

# 📦 EPIC-INF: Developer Experience & AI Tooling

**Goal:** Continuously improve developer workflow by leveraging AI tooling, optimizing Claude Code integration, and gradually introducing specialized sub-agents.

**Business Value:** Faster development cycles, better code quality, and hands-on experience with modern AI-assisted development — directly relevant for portfolio and career growth.

---

## 🔧 FEATURE-INF-001: Claude Code Optimization

**Priority:** P1  
**Role:** Developer  
**Status:** 🔜 In Progress

---

### US-INF-001: Claude Code Integration (CLAUDE.md)

**As a** Developer  
**I want to** have a CLAUDE.md file in the repository  
**So that** Claude Code CLI understands project context on every session start

**Story Points:** 2  
**Priority:** P1  
**Status:** ✅ COMPLETED (February 21, 2026)

**Acceptance Criteria:**
- [x] CLAUDE.md created in project root
- [x] Project Invariants documented
- [x] Git workflow documented
- [x] Flutter best practices included
- [x] Claude Code reads context on fresh session start

---

### US-INF-002: Claude Code Task Mode Evaluation

**As a** Developer  
**I want to** evaluate whether Claude Code Task Mode improves my workflow  
**So that** I can decide how to evolve my development process

**Story Points:** 2  
**Priority:** P2  
**Status:** 📋 Planned  
**Trigger:** After M2 completion

**Acceptance Criteria:**
- [ ] Retrospective completed: which tasks worked better in Claude Code vs chat
- [ ] Decision made: whether to update CLAUDE.md based on findings
- [ ] Short findings document created (can be a section in CLAUDE.md)
- [ ] Workflow adjustments applied if needed

---

### US-INF-003: CLAUDE.md v2 — Extended Instructions

**As a** Developer  
**I want to** update CLAUDE.md based on real usage experience  
**So that** Claude Code instructions reflect actual project patterns

**Story Points:** 2  
**Priority:** P2  
**Status:** 📋 Planned  
**Trigger:** After US-INF-002 evaluation

**Acceptance Criteria:**
- [ ] CLAUDE.md updated with lessons learned from M2
- [ ] New patterns documented (e.g. M2-specific repository patterns)
- [ ] Outdated instructions removed or updated
- [ ] Claude Code tested on fresh session with updated instructions

---

## 🤖 FEATURE-INF-002: Sub-agents

**Priority:** P2  
**Role:** Developer  
**Status:** 📋 Planned  
**Note:** Sub-agents require solid CLAUDE.md foundation and developer familiarity with project patterns. Do not start before M3.

---

### US-INF-004: Tester Sub-agent

**As a** Developer  
**I want to** have a specialized Tester sub-agent in Claude Code  
**So that** test generation follows project patterns automatically

**Story Points:** 5  
**Priority:** P2  
**Status:** 📋 Planned  
**Trigger:** After M3/M4 completion

**Acceptance Criteria:**
- [ ] `/tester` slash command configured in Claude Code
- [ ] Agent understands project test patterns (Mockito, fake_cloud_firestore, widget tests)
- [ ] Agent generates tests consistent with Project Invariants
- [ ] Agent mirrors lib/ structure in test/ automatically
- [ ] User reviews and accepts every generated test before commit
- [ ] Agent documented in CLAUDE.md

---

### US-INF-005: Analyst Sub-agent

**As a** Developer  
**I want to** have a specialized Analyst sub-agent  
**So that** documentation updates after US completion are semi-automated

**Story Points:** 5  
**Priority:** P2  
**Status:** 📋 Planned  
**Trigger:** After M4 completion

**Acceptance Criteria:**
- [ ] `/analyst` slash command configured in Claude Code
- [ ] Agent updates BACKLOG, PROJECT_FILES.md, README after US completion
- [ ] Agent follows existing documentation conventions and language (English)
- [ ] User reviews every change before commit
- [ ] Agent documented in CLAUDE.md

---

### US-INF-006: Architect Sub-agent

**As a** Developer  
**I want to** have a specialized Architect sub-agent  
**So that** architectural decisions are validated against project standards before implementation

**Story Points:** 5  
**Priority:** P3  
**Status:** 📋 Planned  
**Trigger:** After M5 completion

**Acceptance Criteria:**
- [ ] `/architect` slash command configured in Claude Code
- [ ] Agent understands Clean Architecture constraints of this project
- [ ] Agent validates new features against existing architecture before implementation
- [ ] Agent suggests impact on existing layers (data/domain/presentation)
- [ ] Agent documented in CLAUDE.md

---

## ⚙️ FEATURE-INF-003: CI/CD Enhancement

**Priority:** P3  
**Role:** DevOps + Developer  
**Status:** 📋 Planned  
**Note:** Requires GitHub Pro or sufficient Actions minutes. Evaluate cost before starting.

---

### US-INF-007: Automated Code Review on PR

**As a** Developer  
**I want to** have automated code review triggered on every Pull Request  
**So that** code quality issues are caught before merge

**Story Points:** 8  
**Priority:** P3  
**Status:** 📋 Planned  
**Trigger:** After M4 (Google Play Release) — app is stable enough for stricter gates

**Acceptance Criteria:**
- [ ] GitHub Actions workflow triggers on PR to main
- [ ] flutter analyze runs automatically
- [ ] flutter test runs automatically
- [ ] Results posted as PR comment
- [ ] PR cannot be merged if tests fail
- [ ] GitHub Actions minutes usage documented and within free tier limits

---

### US-INF-008: Automated Test Coverage Report

**As a** Developer  
**I want to** see test coverage report on every PR  
**So that** I can track coverage trends and catch regressions

**Story Points:** 5  
**Priority:** P3  
**Status:** 📋 Planned  
**Trigger:** After US-INF-007

**Acceptance Criteria:**
- [ ] Coverage report generated on every PR
- [ ] Coverage percentage visible in PR summary
- [ ] Coverage threshold defined (minimum 80%)
- [ ] PR blocked if coverage drops below threshold
- [ ] Coverage trend tracked over time

**End of Backlog Document**

