# Friendsheet - Setup Guide

This guide will help you set up the Friendsheet project on your local machine.

**Estimated Time:** 15-20 minutes

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Flutter SDK** (3.0+)
   - Download: https://docs.flutter.dev/get-started/install
   - Verify: `flutter --version`

2. **Dart** (2.17+)
   - Included with Flutter SDK
   - Verify: `dart --version`

3. **Android Studio** (Latest)
   - Download: https://developer.android.com/studio
   - Install "Android SDK" and "Android Emulator"

4. **Git**
   - Download: https://git-scm.com/downloads
   - Verify: `git --version`

5. **Google Account**
   - Required for Firebase Console access

---

## 🚀 Step-by-Step Setup

### Step 1: Clone the Repository

```powershell
git clone https://github.com/aleksanderginalski/friendsheet-app.git
cd friendsheet
```

---

### Step 2: Install Flutter Dependencies

```powershell
flutter pub get
```

**Expected output:**
```
Resolving dependencies...
Got dependencies!
```

---

### Step 3: Create Firebase Project

**IMPORTANT:** You must create your own Firebase project. The configuration files are gitignored and not included in the repository.

#### 3.1 Create Project

1. Go to: https://console.firebase.google.com
2. Click **"Add project"**
3. **Project name:** `friendsheet-app-[yourname]` (e.g., `friendsheet-app-john`)
4. **Google Analytics:** Enable (recommended)
5. Click **"Create project"**
6. Wait for project creation (~30 seconds)

#### 3.2 Register Android App

1. In Firebase Console, click **Android icon** (green robot 🤖)
2. **Android package name:** `com.friendsheet.app`
   - ⚠️ **CRITICAL:** Must be exactly `com.friendsheet.app`
3. **App nickname:** `Friendsheet`
4. **SHA-1 certificate:** Add your debug SHA-1 fingerprint
   - Run in PowerShell from project root:
```powershell
     cd android
     ./gradlew signingReport
```
   - Copy SHA1 from `Variant: debug` section
   - Paste into Firebase Console
   - After adding SHA-1, download updated `google-services.json`
5. Click **"Register app"**

#### 3.3 Download google-services.json

1. Click **"Download google-services.json"**
2. Save the file
3. **Move to:** `android/app/google-services.json`

**Verify location:**
```
friendsheet/
└── android/
    └── app/
        └── google-services.json  ← Must be here!
```

---

### Step 4: Enable Firestore Database

1. In Firebase Console, go to **"Firestore Database"**
2. Click **"Create database"**
3. **Start mode:** Select **"Test mode"** (we'll secure it later)
4. **Location:** Choose closest to you (e.g., `europe-west` for Europe)
5. Click **"Enable"**

#### 4.1 Configure Security Rules

1. Go to **Firestore Database** → **"Rules"** tab
2. Replace with this code:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    match /activity_categories/{categoryId} {
      allow read: if isAuthenticated() && resource.data.isGlobal == true;
      allow create: if isAuthenticated() &&
                       request.resource.data.isGlobal == false &&
                       isOwner(request.resource.data.userId);
    }

    match /users/{userId} {
      allow read, write: if isAuthenticated() && isOwner(userId);
    }

    match /users/{userId}/activity_categories/{categoryId} {
      allow read, delete: if isAuthenticated() && isOwner(userId);
      allow create, update: if isAuthenticated() && isOwner(userId);
    }

    match /users/{userId}/meetings/{meetingId} {
      allow read, delete: if isAuthenticated() && isOwner(userId);
      allow create, update: if isAuthenticated() && isOwner(userId);
    }

    match /users/{userId}/persons/{personId} {
      allow read, delete: if isAuthenticated() && isOwner(userId);
      allow create, update: if isAuthenticated() && isOwner(userId);
    }
  }
}
```

3. Click **"Publish"**

---

### Step 5: Create firebase_options.dart

You have **two options:**

#### Option A: Manual Creation (Recommended)

1. **Open** `android/app/google-services.json`
2. **Find** these values:
   - `current_key` (under api_key)
   - `mobilesdk_app_id` (under client_info)
   - `project_number` (under project_info)
   - `project_id` (under project_info)

3. **Create** `lib/firebase_options.dart` with this template:

```dart
// File generated for Friendsheet
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured');
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY_HERE',           // from google-services.json: current_key
    appId: 'YOUR_APP_ID_HERE',             // from google-services.json: mobilesdk_app_id
    messagingSenderId: 'YOUR_SENDER_ID',   // from google-services.json: project_number
    projectId: 'YOUR_PROJECT_ID',          // from google-services.json: project_id
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
  );
}
```

4. **Replace** the placeholder values with your actual Firebase values

#### Option B: Using FlutterFire CLI (Advanced)

**Prerequisites:** Node.js installed

```powershell
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Generate firebase_options.dart
flutterfire configure --project=your-project-id --platforms=android
```

---

### Step 6: Verify Setup

```powershell
# Check if files exist
Test-Path android\app\google-services.json
Test-Path lib\firebase_options.dart

# Both should return: True
```

**Verify package name:**
```powershell
Get-Content android\app\google-services.json | Select-String "package_name"

# Should show: "package_name": "com.friendsheet.app"
```

---

### Step 7: Run the App

```powershell
# Start Android Emulator (in Android Studio)
# OR connect physical Android device

# Run the app
flutter run
```

**Expected output:**
```
🚀 Starting Friendsheet...
✅ Flutter binding initialized
🔥 Initializing Firebase...
✅ Firebase initialized successfully!
Running Gradle task 'assembleDebug'...
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

**On emulator, you should see:**
```
┌──────────────────────────┐
│     FRIENDSHEET          │
├──────────────────────────┤
│         👥               │
│  Welcome to Friendsheet! │
│  Firebase Connected ✅   │
└──────────────────────────┘
```

---

## 🔧 Troubleshooting

### Issue: "Failed to load FirebaseOptions"

**Solution:**
1. Verify `firebase_options.dart` exists in `lib/`
2. Check `main.dart` has:
   ```dart
   import 'firebase_options.dart';
   
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

### Issue: Package name mismatch

**Solution:**
1. Check `android/app/build.gradle`:
   ```gradle
   defaultConfig {
       applicationId "com.friendsheet.app"
   }
   ```
2. Verify `google-services.json` has matching package_name

### Issue: Permission denied (Windows)

**Solution:**
```powershell
# Run as Administrator
takeown /F "C:\path\to\friendsheet" /R /D Y
icacls "C:\path\to\friendsheet" /grant "YourUsername:(OI)(CI)F" /T
```

---

---

## 📦 Release APK (Install on Physical Device)

To build and install a release APK on your personal Android device:

### Prerequisites
- Keystore file generated and stored outside project directory
- `android/key.properties` configured with keystore path and passwords
- Release SHA-1 added to Firebase Console

### Step 1 — Generate keystore (one-time)

Run in PowerShell from the parent folder of the project:
```powershell
keytool -genkey -v `
  -keystore friendsheet.jks `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias friendsheet-key
```

Store the keystore file outside the project directory (e.g. `C:\Keys\friendsheet.jks`).
**Write down your password — it cannot be recovered.**

### Step 2 — Create `android/key.properties`
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=friendsheet-key
storeFile=C:\\full\\path\\to\\friendsheet.jks
```

### Step 3 — Add release SHA-1 to Firebase
```powershell
keytool -list -v `
  -keystore C:\path\to\friendsheet.jks `
  -alias friendsheet-key
```

Copy SHA1 → Firebase Console → Project Settings → Your apps → Add fingerprint → Download updated `google-services.json`.

### Step 4 — Build and install
```powershell
flutter build apk --release
```

Transfer `build\app\outputs\flutter-apk\app-release.apk` to your device via Google Drive or USB.
On device: enable "Install unknown apps" when prompted.

## 📝 Next Steps

After successful setup:

1. ✅ Run `flutter analyze` to check code quality
2. ✅ Run `flutter test` to run tests
3. ✅ Read [BACKLOG.md](BACKLOG.md) to see upcoming features
4. ✅ Check [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

---

## 🆘 Need Help?

- Check existing GitHub Issues
- Create a new Issue with:
  - Your OS (Windows/macOS/Linux)
  - Flutter version (`flutter --version`)
  - Error message (full stack trace)
  - Steps to reproduce

---

## 🔐 Security Reminders

**NEVER commit these files:**
- ❌ `android/app/google-services.json`
- ❌ `lib/firebase_options.dart`
- ❌ `*.jks` / `*.keystore` — keystore files
- ❌ `android/key.properties` — contains keystore passwords

These files contain sensitive API keys and credentials and are gitignored!

Each developer must create their own Firebase project and configuration.

---

**Setup complete!** 🎉 You're ready to start developing!
