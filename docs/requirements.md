# Friendsheet - Requirements Documentation

**Version:** 1.1 (Updated for Google Sign-In Authentication)  
**Date:** February 14, 2026  
**Author:** Product Owner  
**Status:** Updated Draft

**🔄 Major Change:** Authentication method changed from email/password to Google Sign-In (SSO)
---

## 1. Introduction

### 1.1 Document Purpose
This document defines the functional and non-functional requirements for Friendsheet - a tool for tracking meetings with friends.

### 1.2 Application Purpose
The application enables users to track meetings with friends with the ability to later generate statistics (e.g., who you meet most often, which activities you prefer).

### 1.3 MVP Scope (Minimum Viable Product)
**In MVP scope:**
- ✅ User authentication via Google Sign-In (SSO)
- ✅ Adding meetings
- ✅ Saving meeting participants
- ✅ Saving activity types

**Out of MVP scope (future phases):**
- ❌ Viewing meeting list
- ❌ Generating statistics
- ❌ Editing meetings
- ❌ Deleting meetings
- ❌ Email/password authentication (may be added post-MVP if needed)

---

## 2. Functional Requirements

### FR-001: User Authentication
**Priority:** MUST HAVE  
**Role:** BA (Business Analyst)

**Description:**  
User must be able to log in to the application using Firebase Authentication.

**Acceptance Criteria:**
- ✅ User can sign in using their Google account
- ✅ Login screen displays "Sign in with Google" button
- ✅ Clicking sign-in button triggers Google account selection
- ✅ User can select from existing Google accounts on device
- ✅ First-time users are automatically registered (no separate registration flow)
- ✅ Returning users are automatically logged in
- ✅ User's email and display name are retrieved from Google account
- ✅ System displays appropriate error messages for authentication failures
- ✅ After successful authentication, user is redirected to main application screen
- ✅ Authentication state persists across app restarts
- ✅ User can log out (signs out from both Google and Firebase)
- ✅ Network errors are handled gracefully
- ✅ User cancellation is handled gracefully

**Technical Requirements:**
- Google Sign-In SDK integration (`google_sign_in` package)
- Firebase Authentication with Google provider enabled
- SHA-1 certificate fingerprint configured in Firebase
- Google Play Services available on device (Android requirement)
- OAuth 2.0 credential handling
- Secure token storage and management

**User Experience Requirements:**
- One-tap sign-in experience
- Loading indicators during authentication
- Clear error messages for failures
- Confirmation dialog for logout
- Persistent authentication across app launches
- Automatic sign-in for returning users

**Security Requirements:**
- HTTPS communication (enforced by Firebase and Google)
- Secure token exchange
- Automatic token refresh
- Complete sign-out from both providers
- No credential storage in app (handled by OS)

**Error Handling:**
- Network connection failures
- User cancellation of sign-in
- Google Play Services not available/outdated
- Invalid or expired credentials
- Account disabled by administrator
- Generic authentication failures

---

### FR-002: Adding a Meeting
**Priority:** MUST HAVE  
**Role:** BA (Business Analyst)

**Description:**  
User can add a new meeting with friends.

**Acceptance Criteria:**
- User can enter meeting name (max 50 characters)
- User can select meeting date from calendar
- User can select meeting weight (values: 1, 2, 3, 5, 8, 13, 21)
- User can add minimum 1 participant
- User can add minimum 1 activity
- System validates form before saving
- After saving, user sees confirmation message

---

### FR-003: Managing Meeting Participants
**Priority:** MUST HAVE  
**Role:** BA (Business Analyst)

**Description:**  
User can add participants to a meeting with the ability to choose from existing ones or create new ones.

**Acceptance Criteria:**
- System displays list of existing friends with autocomplete
- User can add a new person (first name required, last name optional)
- User can add multiple participants to one meeting
- System prevents adding the same person twice to the same meeting

---

### FR-004: Managing Meeting Activities
**Priority:** MUST HAVE  
**Role:** BA (Business Analyst)

**Description:**  
User can add activities to a meeting with the ability to choose from existing ones or create new ones.

**Acceptance Criteria:**
- System displays list of existing activities with autocomplete
- User can add a new activity (name)
- System prevents adding the same activity twice to the same meeting
- User can add zero or more activities (field is optional)
- Activities support future categorization via categoryId

---

### FR-005: User Logout (⚡ NEW - Added for Completeness)
**Priority:** MUST HAVE  
**Role:** BA (Business Analyst)

**Description:**  
User must be able to securely log out of the application.

**Acceptance Criteria:**
- ✅ Logout option is easily accessible (app bar or navigation drawer)
- ✅ User is signed out from both Google Sign-In and Firebase Authentication
- ✅ All local cached authentication data is cleared
- ✅ User is redirected to login screen after logout
- ✅ Optional confirmation dialog shown before logout
- ✅ After logout, user cannot access protected screens
- ✅ User must re-authenticate to access app again

**Technical Requirements:**
- Sign out from Google Sign-In SDK
- Sign out from Firebase Authentication
- Clear all authentication tokens
- Reset app authentication state
- Navigate user to login screen
---

## 3. Non-Functional Requirements

### NFR-001: Data Storage
**Role:** SA (Solution Architect)

- Data must be stored in Firestore
- Each user has access only to their own data
- Data must be stored in a way that enables statistics generation (future functionality)

---

### NFR-002: Performance (⚡ UPDATED)
**Role:** SA (Solution Architect)

- Meeting save time cannot exceed 3 seconds
- Autocomplete should respond in real-time (< 500ms)
- **NEW:** Google Sign-In authentication should complete within 5 seconds (excluding user interaction time)
- **NEW:** App should display login screen within 2 seconds of launch
- **NEW:** Authentication state check should complete within 1 second

**Performance Improvements with Google SSO:**
- Faster authentication flow (no email verification wait time)
- Reduced server load (no password validation, reset emails)
- Cached authentication state for instant login

---

### NFR-003: Security (⚡ UPDATED)
**Role:** SA (Solution Architect)

- Communication with Firebase must be encrypted (HTTPS)
- Firestore Security Rules must be configured so user has access only to their own data
- **NEW:** OAuth 2.0 tokens must be securely managed by Firebase SDK
- **NEW:** No authentication credentials stored in app code
- **NEW:** Automatic token refresh handled by Firebase
- **NEW:** User must sign out from both Google and Firebase for complete logout
- **NEW:** SHA-1 certificate fingerprint must be configured in Firebase for Android

**Security Enhancements with Google SSO:**
- ✅ No password storage in database (Google handles authentication)
- ✅ Multi-factor authentication support (if enabled on Google account)
- ✅ Automatic security updates from Google
- ✅ Professional-grade authentication infrastructure
- ✅ Reduced attack surface (no password reset flow to exploit)

---

### NFR-004: Offline Availability (⚡ UPDATED)
**Role:** SA (Solution Architect)

- Application should work offline (Firestore offline persistence)
- Data should synchronize automatically after connection returns
- **NEW:** Previously authenticated users remain logged in offline
- **NEW:** New authentication requires internet connection
- **NEW:** Logout requires internet connection to fully sign out from Google

**Offline Behavior:**
- Authenticated users can access app without internet
- Firestore data cached for offline access
- Authentication state persisted locally
- New sign-in requires network connectivity

---

### NFR-005: Compatibility (⚡ NEW)
**Role:** SA (Solution Architect)

**Google Sign-In Requirements:**
- Android API Level 21+ (Android 5.0 Lollipop or higher)
- Google Play Services installed and up-to-date
- Google account configured on device
- Internet connection for initial authentication

**Browser Compatibility (future web version):**
- Modern browsers with OAuth 2.0 support
- JavaScript enabled
- Cookies enabled for authentication flow

---

### NFR-006: Accessibility (NEW)
**Role:** UX/UI Designer

**Authentication Screen:**
- Google Sign-In button meets WCAG 2.1 Level AA standards
- Minimum touch target size of 48dp
- Proper color contrast ratios (4.5:1 minimum)
- Screen reader compatible
- Keyboard navigation support (for web)
- Clear focus indicators

---

### NFR-007: User Experience (NEW)
**Role:** UX/UI Designer

**Authentication Flow:**
- One-tap sign-in experience
- Clear visual feedback during authentication
- Helpful error messages in plain language
- No technical jargon in user-facing messages
- Loading indicators for async operations
- Smooth transitions between screens

---

## 4. Data Model

### 4.1 Entities

#### User (Firebase Authentication)
```
- uid: string (auto-generated by Firebase)
- email: string (from Google account)
- displayName: string (from Google account)
- photoURL: string (from Google account)
- providerId: "google.com"
- createdAt: timestamp (Firebase managed)
- lastSignInTime: timestamp (Firebase managed)
```

**Note:** User entity is now managed entirely by Firebase Authentication. We don't need to create a separate users collection for authentication purposes.

#### Meeting
```
- id: string (auto-generated)
- userId: string (owner)
- name: string (max 50 characters)
- date: DateTime
- weight: int (1, 2, 3, 5, 8, 13, 21)
- participantIds: List<string> (references to Person)
- activityIds: List<string> (references to Activity)
- createdAt: DateTime
- updatedAt: DateTime
```

#### Person
```
- id: string (auto-generated)
- userId: string (owner)
- firstName: string
- lastName: string (optional)
- createdAt: DateTime
```

#### Activity
```
- id: string (auto-generated)
- userId: string (owner, null for global)
- name: string
- categoryId: string? (optional, references ActivityCategory)
- isGlobal: bool (false for user-created)
- createdAt: DateTime
```

### 4.2 Relationships
- Meeting ↔ Person (many-to-many) - via participantIds
- Meeting ↔ Activity (many-to-many) - via activityIds
- Person ↔ Activity (many-to-many) - derived from above relationships

---

## 5. Technical Dependencies

### 5.1 Technology Stack
- **Framework:** Flutter (Dart)
- **Backend:** Firebase
  - Firebase Authentication (Auth)
  - Cloud Firestore (Database)
- **Target Platform:** Android (MVP)

### 5.2 Minimum Requirements
- Flutter SDK: 3.0+
- Dart: 2.17+
- Android SDK: API 21+ (Android 5.0)

---

## 8. Glossary

- **MVP** - Minimum Viable Product - minimum version of product with basic functionalities
- **Meeting Weight** - metric determining meeting "importance" on Fibonacci scale (1, 2, 3, 5, 8, 13, 21)
- **Autocomplete** - functionality suggesting existing values while typing
- **Firestore** - NoSQL cloud database from Google (Firebase)

---


**End of Document**
