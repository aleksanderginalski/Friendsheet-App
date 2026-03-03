# Friendsheet - Product Backlog

**Project:** Friendsheet  
**Version:** 2.0  
**Last Updated:** February 20, 2026  
**Product Owner:** Aleksander Ginalski  

---

## 📊 Backlog Overview

| Milestone | Name | Status |
|-----------|------|--------|
| M1 | Add Meeting | ✅ COMPLETED |
| M2 | Management & CRUD | 🔜 Next |
| M3 | Statistics & Export | 📋 Planned |
| M4 | Google Play Release | 📋 Planned |
| M5 | Social: Data Sharing | 📋 Planned |
| M6 | Google Photos Integration | 📋 Planned |
| M7 | Custom Dashboard | 📋 Planned |
| M8 | AI Assistant | 💡 Future |

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
└── FEATURE-009: Core Statistics
└── FEATURE-010: Data Export
└── FEATURE-017: Sideload Release

EPIC-004: Friendsheet M4 - Google Play Release
└── FEATURE-011: Store Release Preparation

EPIC-005: Friendsheet M5 - Social: Data Sharing
└── FEATURE-012: Invitation Code System

EPIC-006: Friendsheet M6 - Google Photos Integration
└── FEATURE-013: Photo-based Meeting Creation

EPIC-007: Friendsheet M7 - Custom Dashboard
└── FEATURE-014: Configurable Metrics Dashboard

EPIC-008: Friendsheet M8 - AI Assistant
└── FEATURE-015: AI-powered Insights
```

---

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
---

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
---

### US-004: User Registration

**As a** new or returning user  
**I want to** sign in with my Google account  
**So that** I can quickly and securely access the application without creating a new password
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

---

## 💾 FEATURE-003: Data Models

**Role:** Developer + Solution Architect
**Status:** ✅ COMPLETED 
---

### US-007: Meeting Model

**As a** Developer  
**I want to** have a Meeting data model  
**So that** I can represent meeting data in the application
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
---

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
**Acceptance Criteria:**
- [x] Name TextField with 50 character limit
- [x] Character counter displayed (X/50)
- [x] Date picker integrated
- [x] Default date is today
- [ ] Validation: name required, date required
- [ ] Error messages for invalid input

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
---

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
**Status:** 📋 Planned
**Status:** ✅ COMPLETED 
---

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
**Status:** 📋 Planned
**Status:** ✅ COMPLETED 
---

### US-024: Persons List Screen
**Status:** ✅ COMPLETED (February 23, 2026)

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
**Status:** 📋 Planned
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
**Status:** 📋 Planned
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
**Status:** 📋 Planned
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
**Status:** 📋 Planned
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
**Status:** 📋 Planned
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

---

## 📥 FEATURE-016: Data Import

**Priority:** P0
**Role:** Developer
**Status:** 📋 Planned

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
**Status:** 🔄 In Progress

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


### US-049: Activity Breakdown — Smooth Bar Reordering Animation

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
- [x] **TASK-US-049.1:** Add debug logging to trace targetLeft values across rebuilds — identify root cause of spurious position changes
- [x] **TASK-US-049.2:** Fix tween initialization so stationary bars receive begin == end == targetLeft
- [x] **TASK-US-049.3:** Verify fix across multiple year changes (including mid-animation changes)
- [x] **TASK-US-049.4:** Remove debug logging, run dart format + flutter analyze + flutter test

### US-051: Statistics Carousel — Swipeable metric cards on Home screen

**As a** user
**I want to** swipe between statistics on the Home screen instead of seeing them all at once
**So that** I can focus on one metric at a time without being overwhelmed

**Story Points:** 5
**Priority:** P1
**Labels:** `statistics`, `ux`, `home-screen`
**Status:** 📋 Planned
**Milestone:** M3
✅ COMPLETED (March 02, 2026)

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
**Status:** 📋 Planned
**Milestone:** M3
✅ COMPLETED (March 03, 2026)

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
**Status:** 📋 Planned

---

### US-031: JSON Export to Device

**As a** user
**I want to** export all my meeting data as a JSON file to my device
**So that** I can back up my data and ensure portability

**Story Points:** 5
**Priority:** P1

**Acceptance Criteria:**
- [ ] Export option accessible from Settings or Home tab
- [ ] Exports all meetings from `users/{uid}/meetings` to JSON
- [ ] File saved to device Downloads folder
- [ ] Success confirmation with file path shown to user
- [ ] Error handling for storage permission issues

**Tasks:**
- [ ] **TASK-031.1:** Implement ExportService (Firestore → JSON)
- [ ] **TASK-031.2:** Add file write using path_provider + dart:io
- [ ] **TASK-031.3:** Build export trigger UI (button + confirmation)
- [ ] **TASK-031.4:** Write tests

## 📱 FEATURE-017: Sideload Release

**Description:** Enables the developer to install Friendsheet on a personal Android device
without Google Play — producing a signed release APK and configuring Firebase
for the release signing key. Serves as the Epic 3 capstone: real data, real device.

**Priority:** P0
**Role:** Developer + DevOps
**Status:** 📋 Planned

---

### US-042: Install Friendsheet on Personal Device via APK

**As a** developer
**I want to** build a signed release APK and install it on my personal Android phone
**So that** I can use Friendsheet daily with real data without needing a connected computer

**Story Points:** 5
**Priority:** P0
**Labels:** `release`, `android`, `devops`

**Acceptance Criteria:**
- [ ] Keystore generated and stored securely outside the repository
- [ ] `key.properties` configured and added to `.gitignore`
- [ ] `build.gradle` configured with release signing config
- [ ] `flutter build apk --release` completes without errors
- [ ] APK installed on personal Android device (sideload via USB or file transfer)
- [ ] SHA-1 fingerprint of release keystore added to Firebase Console
- [ ] Google Sign-In works on the installed release build
- [ ] App runs stably — no crash on launch, data loads correctly

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
- [ ] **TASK-042.1:** Update `.gitignore` — add keystore and `key.properties` entries
- [ ] **TASK-042.2:** Generate keystore with `keytool` and store securely outside repo
- [ ] **TASK-042.3:** Create `android/key.properties` with signing config
- [ ] **TASK-042.4:** Configure release signing in `android/app/build.gradle`
- [ ] **TASK-042.5:** Run `flutter build apk --release` and verify output
- [ ] **TASK-042.6:** Extract SHA-1 from release keystore and add to Firebase Console
- [ ] **TASK-042.7:** Install APK on device and verify Google Sign-In + data load

**Relation to US-032 (Google Play Release):**
- Keystore created here is reused directly in US-032
- `build.gradle` signing config created here requires only minor changes for AAB
- US-032 adds: version name/code, ProGuard rules, App Bundle target

---

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

**Story Points:** 5  
**Priority:** P0

**Acceptance Criteria:**
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (min 2, phone format)
- [ ] Short description (max 80 chars)
- [ ] Full description
- [ ] Privacy Policy published at accessible URL

**Tasks:**
- [ ] **TASK-155:** Design app icon - 2h
- [ ] **TASK-156:** Create store screenshots - 2h
- [ ] **TASK-157:** Write store description - 1h
- [ ] **TASK-158:** Create and publish Privacy Policy page - 2h

---

### US-032: Production Build Configuration

**As a** developer  
**I want to** configure a signed production build  
**So that** the app can be published on Google Play

**Story Points:** 5  
**Priority:** P0

**Acceptance Criteria:**
- [ ] Keystore generated and securely stored (NOT in git)
- [ ] `key.properties` file configured and gitignored
- [ ] Release build variant configured in build.gradle
- [ ] App Bundle (.aab) generated successfully
- [ ] Version code and version name set
- [ ] ProGuard/R8 rules configured if needed

**Tasks:**
- [ ] **TASK-159:** Generate keystore and document storage - 1h
- [ ] **TASK-160:** Configure signing in build.gradle - 1h
- [ ] **TASK-161:** Update .gitignore for keystore files - 30min
- [ ] **TASK-162:** Build and test release AAB - 1h
- [ ] **TASK-163:** Update CI/CD for release builds - 1h

---

### US-033: Google Play Developer Account Setup

**As a** developer  
**I want to** set up my Google Play Developer account  
**So that** I can publish and manage the app

**Story Points:** 3  
**Priority:** P0

**Acceptance Criteria:**
- [ ] Google Play Developer account created ($25 one-time fee)
- [ ] Account verified
- [ ] App created in Play Console
- [ ] Internal testing track configured
- [ ] App tested via Internal Testing before public release

**Tasks:**
- [ ] **TASK-164:** Create Google Play Developer account - 30min
- [ ] **TASK-165:** Create app in Play Console - 30min
- [ ] **TASK-166:** Upload to Internal Testing track - 1h
- [ ] **TASK-167:** Test Internal build on real device - 1h
- [ ] **TASK-168:** Submit for production review - 1h

---

---

# 📦 EPIC-005: Friendsheet M5 - Social: Data Sharing

**Goal:** Allow users to share their meeting history with friends who join the app

**Business Value:** Solves the "cold start problem" — new users get instant value by receiving shared meeting history instead of starting from empty app.

**Architecture Notes:**
- Uses copy-based sharing (Option A) — data is duplicated into recipient's Firestore, not shared in real-time
- No changes to core data model required — isolation per user maintained
- Invitation codes stored as Firestore documents with TTL (time-to-live)
- Shared package contains only meetings where both users were participants
- Future upgrade path to real-time sharing (Option B) is possible without full rewrite

**Decision Log:**
- Date: February 20, 2026
- Decision: Copy-based sharing (Option A) over real-time shared documents (Option B)
- Rationale: Simpler architecture, no Firestore cost risk, no conflict resolution needed, maintains data isolation model
- Trade-off: Data diverges after sharing — Person A can update a meeting and Person B won't see the change

---

## 🤝 FEATURE-012: Invitation Code System

**Priority:** P0  
**Role:** Developer  
**Status:** 📋 Planned

---

### US-034: Generate Invitation Code

**As a** user who has been using Friendsheet for a while  
**I want to** generate an invitation code for a friend  
**So that** they can receive all meetings we shared together

**Story Points:** 8  
**Priority:** P0

**Acceptance Criteria:**
- [ ] "Share with friend" option accessible from Person Detail screen
- [ ] User selects which person (from their list) to generate code for
- [ ] System creates invitation document in Firestore with: code, senderId, targetPersonId, expiresAt (48h TTL), status: pending
- [ ] 6-character alphanumeric code generated (e.g. "FR4K9X")
- [ ] Code displayed with copy button and share sheet option
- [ ] Code expires after 48 hours
- [ ] User can see active/expired codes they generated

**Tasks:**
- [ ] **TASK-169:** Create InvitationCode model and Firestore collection - 2h
- [ ] **TASK-170:** Implement code generation logic in InvitationService - 2h
- [ ] **TASK-171:** Add Firestore Security Rules for invitations collection - 1h
- [ ] **TASK-172:** Build GenerateInvitationScreen UI - 2h
- [ ] **TASK-173:** Implement share sheet integration - 1h
- [ ] **TASK-174:** Write tests - 1h

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

# 📦 EPIC-006: Friendsheet M6 - Google Photos Integration

**Goal:** Allow users to create meetings based on photos from their device gallery

**Business Value:** Reduces friction for retroactive data entry — user sees a photo, remembers a meeting, adds it in seconds. Also teaches OAuth integration with external API.

**Architecture Notes:**
- Requires Google Photos Library API (separate OAuth scope from Firebase Auth)
- User must grant additional permission: `https://www.googleapis.com/auth/photoslibrary.readonly`
- Date of photo used as pre-filled meeting date
- Photo is NOT stored in Firestore — only the date is used as a hint
- OAuth token managed separately from Firebase Auth token

---

## 📷 FEATURE-013: Photo-based Meeting Creation

**Priority:** P0  
**Role:** Developer  
**Status:** 📋 Planned

---

### US-036: Google Photos Permission & Connection

**As a** user  
**I want to** connect my Google Photos to Friendsheet  
**So that** I can browse my photos to create meetings

**Story Points:** 5  
**Priority:** P0

**Acceptance Criteria:**
- [ ] "Browse Photos" option available in Add Meeting flow
- [ ] First-time: permission request explains why access is needed
- [ ] Google Photos OAuth consent screen shown
- [ ] Permission can be revoked from app Settings
- [ ] Graceful handling if permission denied

**Tasks:**
- [ ] **TASK-181:** Add Google Photos API OAuth scope - 1h
- [ ] **TASK-182:** Implement GooglePhotosService with auth flow - 3h
- [ ] **TASK-183:** Build permission request UI - 1h
- [ ] **TASK-184:** Write tests - 1h

---

### US-037: Browse Photos & Create Meeting

**As a** user  
**I want to** browse my photos and select one to create a meeting  
**So that** the meeting date is automatically filled from the photo

**Story Points:** 8  
**Priority:** P0

**Acceptance Criteria:**
- [ ] Photo grid showing device photos (paginated)
- [ ] Tapping photo opens "Create meeting from this photo" flow
- [ ] Meeting date pre-filled from photo's creation date
- [ ] User proceeds to normal Add Meeting screen with pre-filled date
- [ ] Photo is NOT saved — only date is transferred
- [ ] Back navigation returns to photo grid

**Tasks:**
- [ ] **TASK-185:** Implement Google Photos API fetch (paginated) - 3h
- [ ] **TASK-186:** Build PhotoGridScreen - 2h
- [ ] **TASK-187:** Implement date extraction from photo metadata - 1h
- [ ] **TASK-188:** Bridge to AddMeetingScreen with pre-filled date - 1h
- [ ] **TASK-189:** Write tests - 1h

---

---

# 📦 EPIC-007: Friendsheet M7 - Custom Dashboard

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

# 📦 EPIC-008: Friendsheet M8 - AI Assistant

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
