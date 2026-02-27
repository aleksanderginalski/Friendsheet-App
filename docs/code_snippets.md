# Friendsheet - Code Snippets & Examples (UPDATED for Google SSO)

**What are code snippets?**
Code snippets are short code fragments that show how to implement specific functionality. 
They serve as examples and technical documentation for developers.

**Responsible Role:** Developer (Dev) + Tech Lead  
**Version:** 1.1 (Updated for Google Sign-In Authentication)  
**Last Updated:** February 14, 2026

---



---





## 3. Main App Entry Point with Auth State Listener (⚡ UPDATED)

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

/// Main entry point of the application
/// 
/// 🎨 THE METAPHOR: This is like the building's main entrance with
/// automatic doors. It checks if you have an active badge (auth state)
/// and opens the right door - either to reception (login) or directly
/// to the office (home) if you're already checked in.
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // 🎨 METAPHOR: Turn on the building's security system
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendsheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50),
        useMaterial3: true,
      ),
      
      // This is the key part - AuthWrapper decides which screen to show
      // based on authentication state
      // 🎨 METAPHOR: The automatic door system that routes you
      // to reception or office based on your badge status
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper widget that handles authentication state
/// 
/// This widget listens to Firebase auth state changes and
/// automatically shows the appropriate screen:
/// - LoginScreen if user is NOT authenticated
/// - HomeScreen if user IS authenticated
/// 
/// 🎨 THE METAPHOR: Think of this as a smart security guard who
/// continuously checks your badge status. If you don't have a badge,
/// they send you to reception. If you have a valid badge, they let
/// you proceed to the office. They also notice when you check out
/// and automatically redirect you back to reception.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    
    // StreamBuilder listens to auth state changes in real-time
    // 🎨 METAPHOR: Like a security camera that continuously monitors
    // who's entering and leaving, updating the display in real-time
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading spinner while checking auth state
        // 🎨 METAPHOR: The security system is booting up...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Check if user is authenticated
        // snapshot.data contains the User object if signed in, null if not
        // 🎨 METAPHOR: Check if this person has an active badge
        final bool isAuthenticated = snapshot.hasData && snapshot.data != null;
        
        // Show appropriate screen based on auth state
        // 🎨 METAPHOR: Route them to the right place
        if (isAuthenticated) {
          return const HomeScreen(); // User has valid badge → go to office
        } else {
          return const LoginScreen(); // No badge → go to reception
        }
      },
    );
  }
}
```

**Why This Pattern Is Powerful:**

```dart
// Without StreamBuilder (manual approach - BAD):
// - You must manually check auth on every screen
// - Easy to forget checks
// - No automatic updates when auth state changes

// With StreamBuilder (reactive approach - GOOD):
// ✅ Automatic routing based on auth state
// ✅ Real-time updates when user signs in/out
// ✅ Single source of truth
// ✅ No manual checks needed
```

---

## 4. Home Screen with Logout (⚡ UPDATED)

```dart
// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Home screen shown to authenticated users
/// 
/// 🎨 THE METAPHOR: The main office area where authenticated users
/// can work. It has a clearly marked exit (logout) for when they
/// want to leave the building.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  /// Handle logout button press
  /// 
  /// 🎨 METAPHOR: User walks to the exit and taps out with their badge
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    // 🎨 METAPHOR: "Are you sure you want to leave the building?"
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out?\n\n'
          'You\'ll need to sign in again to access your meetings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );

    // If user confirmed, proceed with logout
    // 🎨 METAPHOR: User confirmed they want to leave - process checkout
    if (confirmed == true && context.mounted) {
      try {
        final AuthService authService = AuthService();
        await authService.signOut();
        
        // Navigation happens automatically via AuthWrapper
        // 🎨 METAPHOR: Doors automatically redirect to reception after checkout
        
      } catch (e) {
        // Show error if logout fails
        // 🎨 METAPHOR: Checkout system malfunction - show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final String? userName = authService.userDisplayName ?? 'Friend';
    final String? userEmail = authService.userEmail ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('FRIENDSHEET'),
        actions: [
          // Logout button in app bar
          // 🎨 METAPHOR: Exit sign always visible
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      
      // Drawer with user info and logout option
      // 🎨 METAPHOR: Side panel showing your badge info and exit option
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User info header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: authService.userPhotoUrl != null
                    ? NetworkImage(authService.userPhotoUrl!)
                    : null,
                child: authService.userPhotoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF4CAF50),
                      )
                    : null,
              ),
              accountName: Text(userName),
              accountEmail: Text(userEmail),
            ),
            
            // Menu items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistics'),
              subtitle: const Text('Coming Soon'),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              subtitle: const Text('Coming Soon'),
              enabled: false,
            ),
            
            const Divider(),
            
            // Logout option
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _handleLogout(context);
              },
            ),
          ],
        ),
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome message
            Text(
              'Welcome back, $userName! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            
            // Add meeting button (will be implemented in US-010)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to Add Meeting screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add Meeting feature coming in US-010!'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('ADD NEW MEETING'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Meeting Model (UNCHANGED)

```dart
// lib/models/meeting.dart
// This remains the same as before - authentication method doesn't affect data models!

import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String userId; // Still uses userId from Firebase Auth
  final String name;
  final DateTime date;
  final int weight;
  final List<String> participantIds;
  final List<String> activityIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meeting({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.weight,
    required this.participantIds,
    required this.activityIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Meeting(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      weight: data['weight'] ?? 1,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      activityIds: List<String>.from(data['activityIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'participantIds': participantIds,
      'activityIds': activityIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool isValid() {
    return name.isNotEmpty &&
           name.length <= 50 &&
           [1, 2, 3, 5, 8, 13, 21].contains(weight) &&
           participantIds.isNotEmpty &&
           activityIds.isNotEmpty;
  }
}
```

---

## 6. Updated Firestore Security Rules (⚡ SLIGHTLY UPDATED)

```javascript
// firestore.rules
// Security rules work the same with Google Sign-In!
// userId is still unique per user, just comes from Google now

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function - is user authenticated (Google Sign-In or any method)
    // 🎨 METAPHOR: Does this person have a valid badge (regardless of where they got it)?
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function - does document belong to user
    // 🎨 METAPHOR: Does this person's badge match the office they're trying to enter?
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Meetings - user has access only to their own meetings
    match /meetings/{meetingId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
      allow update: if isAuthenticated() && isOwner(resource.data.userId);
      allow delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
    
    // Persons - user has access only to their own contacts
    match /persons/{personId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
      allow update, delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
    
    // Activities - user has access only to their own activities
    match /activities/{activityId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
      allow update, delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
  }
}
```

**Important:** Security rules don't care HOW you authenticated (email/password vs Google Sign-In). They only care that:
1. You ARE authenticated (`request.auth != null`)
2. You OWN the data (`request.auth.uid == userId`)

---

## 7. Widget Tests for Login Screen (⚡ NEW)

```dart
// test/screens/login_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/screens/login_screen.dart';

/// Tests for LoginScreen with Google Sign-In
/// 
/// 🎨 METAPHOR: These tests are like security audits - we check
/// that the reception area (login screen) works correctly and
/// handles all scenarios properly.
void main() {
  group('LoginScreen Tests', () {
    
    testWidgets('displays app branding correctly', (tester) async {
      // Arrange: Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Assert: Check that branding elements are present
      expect(find.text('FRIENDSHEET'), findsOneWidget);
      expect(find.text('Track Your Social Life'), findsOneWidget);
      expect(find.byIcon(Icons.people_alt), findsOneWidget);
    });

    testWidgets('displays Google Sign-In button', (tester) async {
      // Arrange: Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Assert: Check that Google Sign-In button is present
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('shows loading indicator when signing in', (tester) async {
      // This test would require mocking AuthService
      // We'll cover advanced testing in later sprints
      // For now, this is a placeholder
      
      // TODO: Implement with mockito in Sprint 5 (US-016)
    });

    testWidgets('displays terms of service text', (tester) async {
      // Arrange: Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Assert: Check that legal text is present
      expect(
        find.text('By signing in, you agree to our\nTerms of Service'),
        findsOneWidget,
      );
    });
  });
}
```

---

## 8. Android Configuration for Google Sign-In (⚡ NEW)

```gradle
// android/app/build.gradle
// Add this to enable Google Sign-In

android {
    // ... existing configuration ...
    
    defaultConfig {
        // ... existing configuration ...
        
        minSdkVersion 21  // Google Sign-In requires API 21+
    }
}

dependencies {
    // ... existing dependencies ...
    
    // Required for Google Sign-In
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

---

## 9. Firebase Console Configuration Checklist

```markdown
# Firebase Console Setup for Google Sign-In

## Steps to Complete:

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Select your Friendsheet project

2. **Enable Google Sign-In**
   - Navigate to: Authentication → Sign-in method
   - Click on "Google" provider
   - Click "Enable" toggle
   - Add your support email (required)
   - Click "Save"

3. **Get SHA-1 Fingerprint** (for Android)
   
   Run this command in your project root:
   ```
   cd android
   ./gradlew signingReport
   ```
   
   Copy the SHA-1 fingerprint from the output

4. **Add SHA-1 to Firebase**
   - Go to Project Settings → General
   - Scroll to "Your apps" → Select Android app
   - Click "Add fingerprint"
   - Paste SHA-1 and save

5. **Download Updated google-services.json**
   - After adding SHA-1, download new google-services.json
   - Replace android/app/google-services.json with new file

6. **Verify Configuration**
   - Try running the app
   - Click "Sign in with Google"
   - If account picker appears → SUCCESS! ✅
```

---

## 10. Data Models with Freezed (⚡ NEW - US-007)

### Meeting Model Example
```dart
// lib/data/models/meeting.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

/// Meeting model representing a social gathering with friends
@freezed
class Meeting with _$Meeting {
  const Meeting._();
  
  const factory Meeting({
    required String id,
    required String userId,
    required String name,
    required DateTime date,
    required int weight,
    required List<String> participantIds,
    required List<String> activityIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Meeting;

  static const List<int> validWeights = [1, 2, 3, 5, 8, 13, 21];

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meeting(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      weight: data['weight'] ?? 1,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      activityIds: List<String>.from(data['activityIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory Meeting.fromJson(Map<String, dynamic> json) => 
      _$MeetingFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'participantIds': participantIds,
      'activityIds': activityIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool isValid() {
    return name.isNotEmpty &&
           name.length <= 50 &&
           validWeights.contains(weight) &&
           participantIds.isNotEmpty &&
           activityIds.isNotEmpty;
  }
}
```

**Key Features:**
- Freezed provides: `copyWith`, `==`, `hashCode`, `toString` automatically
- Immutability enforced at compile time
- Both JSON and Firestore serialization
- Custom validation logic

**Usage:**
```dart
// Create new meeting
final meeting = Meeting(
  id: 'meeting-1',
  userId: 'user-123',
  name: 'Coffee with Anna',
  date: DateTime.now(),
  weight: 8,
  participantIds: ['person-1'],
  activityIds: ['activity-1'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Update immutably
final updated = meeting.copyWith(name: 'Lunch with Anna');

// Validate
if (meeting.isValid()) {
  // Save to Firestore
  final data = meeting.toFirestore();
}
```

**Generate code after model changes:**
```bash
dart run build_runner build --delete-conflicting-outputs
```
## 11. Person Model — key differences from Meeting

// Optional field handling in factory constructor
String? lastName,

// fullName getter — handles null and empty lastName
String get fullName {
  if (lastName == null || lastName!.trim().isEmpty) {
    return firstName;
  }
  return '$firstName $lastName';
}

// Conditional Firestore write — omit field when null
Map<String, dynamic> toFirestore() {
  return {
    'userId': userId,
    'firstName': firstName,
    // Only include lastName if it has a value
    if (lastName != null) 'lastName': lastName,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

## 12. AddMeetingScreen – ChangeNotifierProvider scoped to screen

Key pattern: Provider is scoped to the screen, not the entire app.
This keeps state isolated and automatically disposed when screen is popped.
```dart
// Outer widget provides the ChangeNotifier
class AddMeetingScreen extends StatelessWidget {
  const AddMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMeetingProvider(),
      child: const _AddMeetingView(), // inner widget consumes it
    );
  }
}

// Inner widget consumes the provider
class _AddMeetingView extends StatelessWidget {
  const _AddMeetingView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddMeetingProvider>();
    // ...
  }
}
```

Why this pattern:
- Provider lives only as long as the screen
- No global state pollution
- Automatically disposed on pop
- Easy to test (just wrap with ChangeNotifierProvider in tests)

## 13. Focus-loss Validation Pattern (US-011)

Pattern for validating form fields when user leaves the field (on focus loss).
Used instead of live validation to avoid showing errors while user is still typing.

### Widget side – FocusNode listener:
```dart
@override
void initState() {
  super.initState();
  // Validate when user leaves the field, not on every keystroke
  _focusNode.addListener(() {
    if (!_focusNode.hasFocus) {
      context.read<AddMeetingProvider>().validateName();
    }
  });
}
```

### Provider side – validation method:
```dart
// Returns true if valid, updates error state and notifies listeners
bool validateName() {
  if (_name.isEmpty) {
    _nameError = 'Meeting name is required';
  } else if (_name.length > 50) {
    _nameError = 'Name cannot exceed 50 characters';
  } else {
    _nameError = null;
  }
  notifyListeners();
  return _nameError == null;
}
```

### Optimization – setName does not call notifyListeners on every keystroke:
```dart
void setName(String value) {
  _name = value;
  // Only notify when clearing an existing error
  if (_nameError != null) {
    _nameError = null;
    notifyListeners();
  }
}
```

### Test pattern – simulating focus loss in widget tests:
```dart
// tapAt() does not reliably trigger FocusNode listeners in test environment
// Use FocusManager.instance.primaryFocus?.unfocus() instead
await tester.tap(find.byType(TextField));
await tester.pump();
FocusManager.instance.primaryFocus?.unfocus();
await tester.pump();
expect(find.text('Meeting name is required'), findsOneWidget);
```

### Read-only date field pattern (InkWell + InputDecorator):
```dart
// Use InkWell + InputDecorator instead of TextField for fields
// that open a picker instead of keyboard input
InkWell(
  onTap: () => _pickDate(context, date),
  child: InputDecorator(
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      suffixIcon: Icon(Icons.calendar_today),
    ),
    child: Text(formattedDate),
  ),
)
```

## 14. Index-based Stepper Pattern (US-012)

Pattern for navigating a fixed set of values using index instead of raw value.
Used for Meeting Weight to ensure only valid Fibonacci values are selectable.

### Provider side — index-based state:
```dart
static const List<int> weightValues = [1, 2, 3, 5, 8, 13, 21];

// Default index 2 → value 3
int _weightIndex = 2;

int get weight => weightValues[_weightIndex];
bool get canDecrement => _weightIndex > 0;
bool get canIncrement => _weightIndex < weightValues.length - 1;

void incrementWeight() {
  if (canIncrement) {
    _weightIndex++;
    notifyListeners();
  }
}

void decrementWeight() {
  if (canDecrement) {
    _weightIndex--;
    notifyListeners();
  }
}
```

### Widget side — stateless, driven by provider:
```dart
MeetingWeightStepper(
  value: provider.weight,
  canDecrement: provider.canDecrement,
  canIncrement: provider.canIncrement,
  onDecrement: provider.decrementWeight,
  onIncrement: provider.incrementWeight,
)
```

Why index-based over raw value:
- Invalid values are impossible at the provider level
- No validation needed in the form
- Widget stays stateless and reusable
- Boundary checks are simple boolean comparisons

## 15. MockRepository Pattern in Provider Tests (US-013)

Problem: Provider tworzy Repository w konstruktorze, Repository wywołuje
FirebaseFirestore.instance → testy crashują bez Firebase.

Rozwiązanie: Wstrzyknij mock przez konstruktor używając @GenerateMocks.
```dart
// 1. Annotate test file with @GenerateMocks
@GenerateMocks([PersonRepository])
void main() {
  late MockPersonRepository mockRepository;
  late AddMeetingProvider provider;

  setUp(() {
    mockRepository = MockPersonRepository();
    // Inject mock instead of real repository
    provider = AddMeetingProvider(personRepository: mockRepository);
  });
}
```

Zasada: Każdy Repository wstrzykiwany przez konstruktor Providera
pozwala testować logikę biznesową bez połączenia z Firebase.

Generowanie mocków po dodaniu @GenerateMocks:
```
dart run build_runner build --delete-conflicting-outputs
```

## 16. Full Name Split Pattern (US-013)

Problem: Użytkownik wpisuje "Małgorzata Bielawska" w pole wyszukiwania
i klika "Add as new person" → cały string trafia do firstName.

Rozwiązanie: Rozdziel string po pierwszej spacji przed otwarciem dialogu.
Obsługuje wieloczłonowe nazwiska (np. "Anna Maria Kowalska").
```dart
final parts = initialName.split(' ');
final firstName = parts.first;
final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
```

Przykłady:
- "Anna" → firstName: "Anna", lastName: ""
- "Anna Kowalska" → firstName: "Anna", lastName: "Kowalska"
- "Anna Maria Kowalska" → firstName: "Anna", lastName: "Maria Kowalska"

## 17. Global + Private Data Pattern (post US-042, US-045)

Pattern for data that has a global read-only template and user-private copies.
Used for ActivityCategory: global template in root collection, user copies in subcollection.

### Repository side — subcollection path per user:
```dart
// Global template — root collection, read-only
CollectionReference _globalRef() =>
    _firestore.collection('activity_categories');

// User-private — subcollection under users/{uid}
CollectionReference _userRef(String userId) => _firestore
    .collection('users')
    .doc(userId)
    .collection('activity_categories');
```

### Firestore Security Rules — path-based userId:
```javascript
match /users/{userId}/activity_categories/{categoryId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

match /activity_categories/{categoryId} {
  allow read: if request.auth != null;
  allow write: if false; // managed via Firebase Console only
}
```

### Data model convention:
- Global record: `isGlobal: true`, `userId: null` — root collection, seeded via script
- Private record: `isGlobal: false`, `userId: String` — user subcollection, batch-copied on first login

**Important:** Legacy `Activity` model and root `/activities` collection are removed (US-042).
Only source of truth: `users/{uid}/activity_categories`.

## 18. Search/Filter Logic in Provider, not Repository (US-014)

Rule: Methods that filter already-loaded local data belong in Provider, not Repository.
Repository is responsible only for communication with external data sources (Firestore, API).

### Wrong — filter in Repository:
```dart
// BAD: Repository doing client-side filtering
List<ActivityCategory> searchCategories(List<ActivityCategory> categories, String query) {
  return activities.where((a) => a.name.contains(query)).toList();
}
```

### Correct — filter in Provider:
```dart
// GOOD: Provider filters its own local state
List<Activity> searchActivities(String query) {
  if (query.trim().isEmpty) return [];
  final lower = query.toLowerCase();
  return _availableActivities
      .where((a) => a.name.toLowerCase().contains(lower))
      .where((a) => !_selectedActivities.contains(a))
      .toList();
}
```

Why this matters for tests:
- Repository methods are mockable — if filter logic is in Repository,
  tests require stubs even for simple string matching
- Provider methods operate on injected state — no stubs needed
- Symptom of wrong placement: MissingStubError in tests for a non-Firestore method

## 19. Provider created at navigation call-site, not inside target screen

Pattern: When a screen needs a Provider that depends on repositories,
create the ChangeNotifierProvider at the navigation call-site rather than
inside the target screen's build method.

// CORRECT — Provider created where navigation happens:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider(
      create: (_) => PersonDetailProvider(
        personRepository: PersonRepository(),
        meetingRepository: MeetingRepository(),
        authService: AuthService(),
      ),
      child: PersonDetailScreen(person: person),
    ),
  ),
);

// Why this pattern:
// - Screen stays a pure Consumer — no repository knowledge
// - Provider is mockable in tests (wrap with mock provider in test)
// - Consistent with MeetingDetailScreen pattern
// - Screen has no responsibility for its own dependency construction

## 20. addPostFrameCallback for Provider initialization in initState

Pattern: When a screen receives its Provider from outside (call-site pattern above),
use addPostFrameCallback to call initialize() because the Provider is not yet
accessible during initState before the widget tree is built.

// CORRECT:
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<PersonDetailProvider>().initialize(widget.person);
  });
}

// WRONG — crashes because Provider not yet accessible:
@override
void initState() {
  super.initState();
  context.read<PersonDetailProvider>().initialize(widget.person); // throws
}

// Why addPostFrameCallback works:
// - Executes after the first frame is built
// - Provider is fully wired into the widget tree at that point
// - Safe to call context.read() inside the callback

## 21. WriteBatch cascade delete pattern (US-024)

Pattern: When deleting an entity that is referenced in other documents,
use WriteBatch to atomically clean up all references before deleting
the entity itself.

// In MeetingRepository:
Future<void> removePersonFromMeetings(String userId, String personId) async {
  final query = await _firestore
      .collection('meetings')
      .where('userId', isEqualTo: userId)
      .where('participantIds', arrayContains: personId)
      .get();

  final batch = _firestore.batch();
  for (final doc in query.docs) {
    batch.update(doc.reference, {
      'participantIds': FieldValue.arrayRemove([personId]),
    });
  }
  await batch.commit();
}

// In PersonRepository.deletePerson — always cascade first:
Future<void> deletePerson(String userId, String personId) async {
  await _meetingRepository.removePersonFromMeetings(userId, personId);
  await _firestore.collection('persons').doc(personId).delete();
}

// Why WriteBatch:
// - Atomic — either all updates succeed or none do
// - Single network round-trip for multiple document updates
// - Safe for Firestore limit of 500 writes per batch (personal scale: safe)

## 21. getAllCategories — Merging Global and Private Firestore Collections (US-026)

Pattern for fetching data that lives in two separate Firestore locations:
global root collection + user's private subcollection.
```dart
Future<List<ActivityCategory>> getAllCategories(String userId) async {
  final globalSnapshot = await _firestore
      .collection('activity_categories')
      .where('isGlobal', isEqualTo: true)
      .get();

  final privateSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('activity_categories')
      .get();

  return [
    ...globalSnapshot.docs.map((doc) => ActivityCategory.fromFirestore(doc)),
    ...privateSnapshot.docs.map((doc) => ActivityCategory.fromFirestore(doc)),
  ];
}
```

Rule: Repository merges sources — Provider and Screen are unaware of the dual source.
Reuse this pattern in Statistics (US-029) when filtering by category hierarchy.

## 22. GestureDetector wrapping ExpansionTile for long-press (US-026)

`ExpansionTile` does not expose `onLongPress`. Wrap with `GestureDetector` to add it.
Guard the gesture with a null check to make global items read-only.
```dart
GestureDetector(
  onLongPress: category.isGlobal ? null : () => _showOptions(context),
  child: ExpansionTile(
    // ... unchanged
  ),
)
```