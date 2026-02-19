# Friendsheet - Architecture Documentation

## 1. Architecture Overview (High-Level)

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter App<br/>Android]
    end
    
    subgraph "Firebase Services"
        B[Firebase Authentication]
        C[Cloud Firestore]
    end
    
    subgraph "Data Storage"
        D[(Firestore Database)]
    end
    
    A -->|Login/Register| B
    A -->|CRUD Operations| C
    C -->|Store/Retrieve| D
    
    style A fill:#4CAF50
    style B fill:#FFC107
    style C fill:#FFC107
    style D fill:#2196F3
```

**Responsible Role:** Solution Architect (SA)

---

## 2. Data Model - Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    USER ||--o{ MEETING : creates
    USER ||--o{ PERSON : owns
    USER ||--o{ ACTIVITY : owns
    USER ||--o{ ACTIVITY_CATEGORY : owns
    MEETING }o--o{ PERSON : has_participants
    MEETING }o--o{ ACTIVITY : has_activities
    ACTIVITY }o--o| ACTIVITY_CATEGORY : belongs_to
    ACTIVITY_CATEGORY }o--o| ACTIVITY_CATEGORY : has_parent

    USER {
        string uid PK
        string email
        string displayName
        datetime createdAt
    }
    
    MEETING {
        string id PK
        string userId FK
        string name
        datetime date
        int weight
        array participantIds
        array activityIds
        datetime createdAt
        datetime updatedAt
    }
    
    PERSON {
        string id PK
        string userId FK
        string firstName
        string lastName
        datetime createdAt
    }
    
    ACTIVITY {
        string id PK
        string userId FK "null if global"
        string name
        string categoryId FK "optional"
        bool isGlobal
        datetime createdAt
    }

    ACTIVITY_CATEGORY {
        string id PK
        string userId FK "null if global"
        string name
        bool isGlobal
        string parentCategoryId FK "optional, max 3 levels"
        datetime createdAt
    }
```

**Responsible Role:** Solution Architect (SA) + Database Administrator (DBA)

---

## 3. Application Layer Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        A1[Login Screen]
        A3[Add Meeting Screen]
    end
    
    subgraph "Business Logic Layer"
        B1[Auth Service]
        B2[Meeting Service]
        B3[Person Service]
        B4[Activity Service]
        B5[Activity Category Service]
    end
    
    subgraph "Data Layer"
        C1[Auth Repository]
        C2[Meeting Repository]
        C3[Person Repository]
        C4[Activity Repository]
        C5[Activity Category Repository]
    end
    
    subgraph "External Services"
        D1[Firebase Auth]
        D2[Firestore]
    end
    
    A1 --> B1
    A3 --> B2
    A3 --> B3
    A3 --> B4
    A3 --> B5
    
    B1 --> C1
    B2 --> C2
    B3 --> C3
    B4 --> C4
    B5 --> C5
    
    C1 --> D1
    C2 --> D2
    C3 --> D2
    C4 --> D2
    C5 --> D2
    
    style A1 fill:#E3F2FD
    style A3 fill:#E3F2FD
    style B1 fill:#FFF3E0
    style B2 fill:#FFF3E0
    style B3 fill:#FFF3E0
    style B4 fill:#FFF3E0
    style B5 fill:#FFF3E0
    style C1 fill:#F3E5F5
    style C2 fill:#F3E5F5
    style C3 fill:#F3E5F5
    style C4 fill:#F3E5F5
    style C5 fill:#F3E5F5
    style D1 fill:#E8F5E9
    style D2 fill:#E8F5E9
```

**Architecture Pattern:** Clean Architecture / MVVM  
**Responsible Role:** Solution Architect (SA) + Tech Lead

**Layer Explanation:**
- **Presentation Layer** - Application screens (UI)
- **Business Logic Layer** - Business logic (Services)
- **Data Layer** - Data access (Repositories)
- **External Services** - External services (Firebase)

---

## 4. Add Meeting Screen - Component Flow

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Add Meeting Screen
    participant MS as Meeting Service
    participant PS as Person Service
    participant AS as Activity Service
    participant FS as Firestore
    
    U->>UI: Fills form
    U->>UI: Selects participants (autocomplete)
    UI->>PS: Get persons list
    PS->>FS: Query persons by userId
    FS-->>PS: Return persons list
    PS-->>UI: Display suggestions
    
    U->>UI: Selects activities (autocomplete)
    UI->>AS: Get activities list
    AS->>FS: Query global activities (isGlobal=true)
    AS->>FS: Query private activities by userId
    FS-->>AS: Return merged activities list
    AS-->>UI: Display suggestions
    
    U->>UI: Clicks "Save"
    UI->>UI: Validate form
    UI->>MS: saveMeeting(meetingData)
    MS->>FS: Create meeting document
    FS-->>MS: Success
    MS-->>UI: Meeting saved
    UI-->>U: Show success message
```

**Responsible Role:** Developer (Dev)

---

## 5. Firestore Data Structure

```mermaid
graph LR
    subgraph "Firestore Collections"
        A[users/]
        B[meetings/]
        C[persons/]
        D[activities/]
        E[activity_categories/]
    end
    
    A --> A1["{userId}"]
    B --> B1["{meetingId}<br/>- userId<br/>- name<br/>- date<br/>- weight<br/>- participantIds[]<br/>- activityIds[]"]
    C --> C1["{personId}<br/>- userId<br/>- firstName<br/>- lastName?"]
    D --> D1["{activityId}<br/>- userId: String?<br/>- name<br/>- categoryId: String?<br/>- isGlobal: bool<br/>- createdAt"]
    E --> E1["{categoryId}<br/>- userId: String?<br/>- name<br/>- isGlobal: bool<br/>- parentCategoryId: String?<br/>- createdAt"]
    
    B1 -.->|references| C1
    B1 -.->|references| D1
    D1 -.->|references| E1
    E1 -.->|"self-reference (max 3 levels)"| E1
    
    style A fill:#BBDEFB
    style B fill:#C8E6C9
    style C fill:#FFCCBC
    style D fill:#F0F4C3
    style E fill:#E1BEE7
```

**Responsible Role:** Database Administrator (DBA) + Solution Architect (SA)

**Global vs Private data pattern:**
- `isGlobal: true` + `userId: null` → managed via Firebase Console, read-only for all users
- `isGlobal: false` + `userId: String` → created and managed by individual user

**Security Rules (Conceptual):**
```javascript
// Each user has access only to their own data.
// Global documents (isGlobal: true) are readable by all authenticated users.

match /meetings/{meetingId} {
  allow read, write: if request.auth.uid == resource.data.userId;
}

match /persons/{personId} {
  allow read, write: if request.auth.uid == resource.data.userId;
}

match /activities/{activityId} {
  // Global activities: read-only for all authenticated users
  allow read: if request.auth != null && resource.data.isGlobal == true;
  // Private activities: full access for owner only
  allow read, write: if request.auth.uid == resource.data.userId;
}

match /activity_categories/{categoryId} {
  // US-019: same pattern as activities
  allow read: if request.auth != null && resource.data.isGlobal == true;
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

---

## 6. Deployment Architecture (Simple Schema)

```mermaid
graph TB
    subgraph "Development"
        A[Local Machine]
        B[Android Emulator]
    end
    
    subgraph "Version Control"
        C[Git Repository]
    end
    
    subgraph "Firebase Project"
        D[Firebase Console]
        E[Firestore Database]
        F[Firebase Auth]
    end
    
    A -->|flutter run| B
    A -->|git push| C
    A -->|Deploy rules| D
    B -->|Connect| E
    B -->|Authenticate| F
    
    style A fill:#4CAF50
    style B fill:#FF9800
    style C fill:#2196F3
    style D fill:#FFC107
    style E fill:#9C27B0
    style F fill:#F44336
```

**Responsible Role:** DevOps Engineer

---

## 7. Technology Stack Details

### Frontend
- **Framework:** Flutter 3.0+
- **Language:** Dart 2.17+
- **State Management:** Provider / Riverpod (TBD)
- **UI Components:** Material Design 3

### Backend
- **BaaS:** Firebase
  - **Authentication:** Firebase Auth (Google Sign-In)
  - **Database:** Cloud Firestore
  - **Hosting:** Firebase Hosting (web version - future)

### Development Tools
- **IDE:** Android Studio / VS Code
- **Version Control:** Git + GitHub
- **CI/CD:** GitHub Actions
- **Testing:** Flutter Test Framework

---

## 8. Design Patterns & Best Practices

### Architecture Pattern: Clean Architecture
```
lib/
├── core/                    # Core utilities, constants
├── data/                    # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Repository implementations
│   └── datasources/        # Firebase datasources
├── domain/                  # Business logic layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business use cases
├── presentation/            # Presentation layer
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable widgets
│   └── providers/          # State management
└── main.dart
```

### Key Principles
1. **Separation of Concerns** - Each layer has single responsibility
2. **Dependency Injection** - Dependencies injected via constructors
3. **Repository Pattern** - Abstract data access
4. **Single Source of Truth** - Firestore as primary data source
5. **Offline First** - Firestore persistence enabled

---

## 9. Security Architecture

### Authentication Flow
```mermaid
sequenceDiagram
    participant U as User
    participant App as Flutter App
    participant Auth as Firebase Auth
    participant Google as Google Sign-In
    participant FS as Firestore
    
    U->>App: Tap "Sign in with Google"
    App->>Google: Trigger Google Sign-In flow
    Google-->>App: Google credential
    App->>Auth: signInWithCredential()
    Auth-->>App: Firebase User
    App->>App: Store user state
    App->>FS: Initialize with userId
    FS-->>App: User's data stream
    App-->>U: Navigate to home
```

### Data Security
- **Authentication Required:** All Firestore operations require authenticated user
- **Row-Level Security:** Each document has `userId` field
- **Global Data:** Read-only for all authenticated users (`isGlobal: true`)
- **Security Rules:** Server-side validation in Firestore Rules
- **HTTPS Only:** All Firebase communication encrypted
- **No Sensitive Data:** Credentials managed by Google and Firebase Auth

---

## 10. Scalability Considerations

### Current MVP (Single User)
- Simple CRUD operations
- Basic queries by userId
- Global + private activities pattern
- Offline persistence

### Future Scalability (Post-MVP)
- **Statistics Generation:** Cloud Functions for heavy computation
- **Data Export:** Batch processing for large datasets
- **Caching:** Redis for frequently accessed data
- **Indexing:** Composite indexes for complex queries (e.g. isGlobal + categoryId)
- **Sharding:** User-based sharding if needed

---

**End of Document - Architecture Documentation**  
**Last Updated:** February 2026 (US-009 - Activity Model + Categories design)
