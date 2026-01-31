# Toker - Data Integration Guide

## 📋 Overview

This document explains how the **Toker frontend** is structured and where the **Data/NLP team** can integrate their matching algorithm based on interest vectorization.

---

## 🏗️ Project Structure

```
lib/
├── models/              # Data models
│   ├── profile.dart     # User profile (interests, photos, prompts)
│   ├── prompt.dart      # Prompt questions & answers
│   ├── swipe.dart       # Swipe actions (nope/like/superlike)
│   ├── match.dart       # Match data
│   └── message.dart     # Chat messages
├── services/
│   └── mock_data_service.dart  # Mock data generator (REPLACE THIS)
├── screens/             # UI screens
└── theme/               # Design system (colors, etc.)
```

---

## 📊 Data Models

### Profile Model

**Location**: `lib/models/profile.dart`

```dart
class Profile {
  final String id;
  final String name;
  final int age;
  final DateTime? birthdate;
  final String gender;  // "Male", "Female", "Non-binary", "Other"
  final String bio;
  final List<String> interests;  // 5-7 interests (auto-detected)
  final List<String> photos;     // 3-6 photo URLs
  final List<Prompt> prompts;    // 2-3 prompts (question + answer)
  final String location;
  final String interestedIn;     // "Men", "Women", "Everyone"
  final Map<String, double> interestVector;  // FOR NLP TEAM
  
  // Current compatibility calculation (MOCK)
  double calculateCompatibility(Profile other) {
    final commonInterests = interests
        .where((interest) => other.interests.contains(interest))
        .length;
    final totalInterests = (interests.length + other.interests.length) / 2;
    return (commonInterests / totalInterests * 100).clamp(0, 100);
  }
}
```

**Key Fields for Data Team**:
- `interests`: List of interest strings (e.g., "Gaming", "Travel", "Music")
- `interestVector`: Map<String, double> - **This is where you inject your NLP vectors**
- `calculateCompatibility()`: **This is the method to replace with your algorithm**

---

### Swipe Model

**Location**: `lib/models/swipe.dart`

```dart
enum SwipeAction {
  nope,
  like,
  superlike,
}

class Swipe {
  final String id;
  final String fromUserId;
  final String toUserId;
  final SwipeAction action;
  final DateTime timestamp;
}
```

**Usage**: Track all user swipe actions for analytics and matching feedback.

---

### Prompt Model

**Location**: `lib/models/prompt.dart`

```dart
class Prompt {
  final String question;
  final String answer;
  
  static const List<String> availableQuestions = [
    'Dans mon groupe d\'amis je suis...',
    'Le truc le plus random que j\'adore...',
    // ... 15 total questions
  ];
}
```

**Potential Use**: Prompts can be analyzed for NLP-based personality matching (future enhancement).

---

## 🔌 Integration Points

### 1. Replace Mock Data Service

**Current**: `lib/services/mock_data_service.dart`

This file currently generates fake profiles with random interests. **You need to replace this with real API calls.**

**What to replace**:

```dart
// CURRENT (MOCK)
List<Profile> generateProfiles({int count = 20}) {
  // Generates fake profiles with random interests
}

// REPLACE WITH
Future<List<Profile>> fetchProfiles(String userId) async {
  // 1. Call your backend API
  // 2. Get profiles with pre-computed interest vectors
  // 3. Return List<Profile>
}
```

---

### 2. Inject Interest Vectors

When creating a `Profile` object from your API response:

```dart
Profile.fromJson(Map<String, dynamic> json) {
  return Profile(
    id: json['id'],
    name: json['name'],
    // ... other fields
    interests: List<String>.from(json['interests']),
    interestVector: Map<String, double>.from(json['interestVector'] ?? {}),
  );
}
```

**Expected `interestVector` format**:

```json
{
  "interestVector": {
    "gaming": 0.85,
    "travel": 0.72,
    "music": 0.91,
    "sports": 0.45,
    // ... vectorized representation of interests
  }
}
```

---

### 3. Replace Compatibility Calculation

**Current location**: `lib/models/profile.dart` → `calculateCompatibility()`

**Current implementation** (simple interest overlap):

```dart
double calculateCompatibility(Profile other) {
  final commonInterests = interests
      .where((interest) => other.interests.contains(interest))
      .length;
  final totalInterests = (interests.length + other.interests.length) / 2;
  return (commonInterests / totalInterests * 100).clamp(0, 100);
}
```

**Replace with your NLP algorithm**:

```dart
double calculateCompatibility(Profile other) {
  // Option 1: Use pre-computed score from backend
  if (interestVector.containsKey('compatibility_${other.id}')) {
    return interestVector['compatibility_${other.id}']!;
  }
  
  // Option 2: Compute on-device using vectors
  return _computeVectorSimilarity(this.interestVector, other.interestVector);
}

double _computeVectorSimilarity(
  Map<String, double> vectorA,
  Map<String, double> vectorB,
) {
  // Implement cosine similarity, dot product, or your custom metric
  // Return score between 0-100
}
```

---

## 🎯 API Contract

### Expected Backend Endpoints

#### 1. Get Recommended Profiles

```
GET /api/profiles/recommendations?userId={userId}&limit=20
```

**Response**:

```json
{
  "profiles": [
    {
      "id": "profile_123",
      "name": "Emma Martin",
      "age": 25,
      "birthdate": "1999-03-15T00:00:00Z",
      "gender": "Female",
      "bio": "Amoureuse de voyages...",
      "interests": ["Travel", "Music", "Photography"],
      "photos": [
        "https://cdn.toker.app/photos/123_1.jpg",
        "https://cdn.toker.app/photos/123_2.jpg",
        "https://cdn.toker.app/photos/123_3.jpg"
      ],
      "prompts": [
        {
          "question": "Dans mon groupe d'amis je suis...",
          "answer": "Celle qui organise toujours les sorties"
        },
        {
          "question": "Ma passion secrète c'est...",
          "answer": "La photographie urbaine"
        }
      ],
      "location": "Paris, France",
      "interestedIn": "Men",
      "interestVector": {
        "travel": 0.92,
        "music": 0.78,
        "photography": 0.85
      },
      "compatibilityScore": 87.5  // Pre-computed by your algorithm
    }
  ]
}
```

#### 2. Record Swipe

```
POST /api/swipes
```

**Request Body**:

```json
{
  "fromUserId": "user_0",
  "toUserId": "profile_123",
  "action": "like",  // "nope", "like", or "superlike"
  "timestamp": "2026-01-30T15:30:00Z"
}
```

**Response**:

```json
{
  "success": true,
  "isMatch": false  // true if mutual like
}
```

#### 3. Get Likes Received

```
GET /api/likes/received?userId={userId}
```

**Response**: Same format as recommendations endpoint.

---

## 🧪 How to Test Integration

### Step 1: Update MockDataService

Replace `generateProfiles()` with your API call:

```dart
class ApiDataService {
  Future<List<Profile>> fetchProfiles(String userId) async {
    final response = await http.get(
      Uri.parse('https://api.toker.app/profiles/recommendations?userId=$userId'),
    );
    
    final data = json.decode(response.body);
    return (data['profiles'] as List)
        .map((json) => Profile.fromJson(json))
        .toList();
  }
}
```

### Step 2: Update Profile Model

Ensure `calculateCompatibility()` uses your algorithm or pre-computed scores.

### Step 3: Test in App

1. Run the app: `flutter run`
2. Complete onboarding
3. View recommended profiles in the Discover tab
4. Check that compatibility scores are accurate
5. Swipe and verify swipes are recorded

---

## 📈 Current Mock Data Behavior

For reference, here's what the **mock service currently does**:

1. **Auto-detects interests**: Assigns 5-7 random interests per profile
2. **Generates photos**: Uses placeholder URLs (`https://i.pravatar.cc/400?img=X`)
3. **Generates prompts**: Creates 2-3 prompts with realistic French answers
4. **Calculates compatibility**: Simple interest overlap (common interests / total interests)
5. **Tracks swipes**: Stores in-memory (lost on app restart)

**All of this should be replaced with real backend calls.**

---

## 🔄 Migration Path

### Phase 1: Keep Mock, Add Vectors

1. Keep `MockDataService` for now
2. Add `interestVector` to mock profiles
3. Update `calculateCompatibility()` to use vectors
4. Test that UI still works

### Phase 2: Hybrid (Mock + API)

1. Create `ApiDataService` alongside `MockDataService`
2. Add a feature flag to switch between them
3. Test API integration without breaking existing flow

### Phase 3: Full API

1. Remove `MockDataService`
2. Use `ApiDataService` everywhere
3. Handle loading states, errors, pagination

---

## 🚀 Next Steps for Data Team

1. **Define your interest vector schema**: What dimensions? What values?
2. **Build the matching algorithm**: Cosine similarity? Custom metric?
3. **Create the backend API**: Endpoints listed above
4. **Provide sample data**: Share JSON examples for testing
5. **Coordinate with frontend**: We'll integrate your API

---

## 🎯 Gender Filtering (NEW)

### Current Implementation

The app now supports gender-based profile filtering based on user preferences:

```dart
// In MockDataService
List<Profile> generateProfiles({int count = 20, String? genderFilter}) {
  // Uses current user's interestedIn preference by default
  // Filters: 'Women' → Female profiles
  //          'Men' → Male profiles  
  //          'Everyone' → All genders (Female, Male, Non-binary)
}
```

### SQL Implementation

When fetching profiles from your database, apply the gender filter:

```sql
-- For user interested in Women
SELECT * FROM users 
WHERE gender = 'Female' 
  AND id != :current_user_id
ORDER BY compatibility_score DESC
LIMIT 20;

-- For user interested in Everyone
SELECT * FROM users 
WHERE id != :current_user_id
ORDER BY compatibility_score DESC
LIMIT 20;
```

**Backend API should respect the `interestedIn` field** when returning recommendations.

---

## 📸 Photo Storage Strategy

### Overview

Photos will be stored in the SQL database. We recommend **storing URLs** rather than binary data.

### Recommended Approach: URLs + CDN

**Database Schema**:

```sql
CREATE TABLE photos (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  photo_url VARCHAR(500),  -- URL to CDN/Cloud Storage
  position INT,            -- Display order (0-5)
  caption_prompt_id UUID,  -- Optional: reference to prompt
  caption_answer TEXT,     -- Optional: photo caption
  created_at TIMESTAMP
);
```

**Workflow**:
1. User uploads photo → Frontend sends to backend
2. Backend uploads to cloud storage (AWS S3, Google Cloud Storage, etc.)
3. Backend stores URL in database
4. Frontend fetches and displays using URL

**Advantages**:
- ✅ Lightweight database
- ✅ Fast loading with CDN
- ✅ Easy to scale
- ✅ Can change storage provider without DB migration

### Alternative: Base64 (NOT Recommended)

```sql
CREATE TABLE photos (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  photo_data TEXT,  -- Base64 encoded image
  position INT
);
```

**Disadvantages**:
- ❌ Very large database size
- ❌ Slow queries
- ❌ No CDN caching
- ❌ Not production-ready

### PhotoStorageService

We've created an abstraction layer in `lib/services/photo_storage_service.dart`:

```dart
abstract class PhotoStorageService {
  Future<String> uploadPhoto(dynamic photoData, String userId, int position);
  String getPhotoUrl(String photoReference);
  Future<void> deletePhoto(String photoReference);
  Future<List<String>> getUserPhotos(String userId);
}
```

**Current**: `MockPhotoStorageService` (uses placeholder URLs)  
**Future**: `SQLPhotoStorageService` (your implementation)

### Photo Captions

Photos can have optional captions (Hinge-style):

```dart
// In Profile model
final Map<int, String> photoCaptions;  // position → caption text

// Example
photoCaptions: {
  0: "Mon endroit préféré à Paris\nLa Tour Eiffel au coucher du soleil",
  2: "En mode aventure\nRandonnée dans les Alpes"
}
```

Store in database:

```sql
-- Option 1: In photos table
ALTER TABLE photos ADD COLUMN caption TEXT;

-- Option 2: Separate table (more flexible)
CREATE TABLE photo_captions (
  photo_id UUID REFERENCES photos(id),
  prompt_question TEXT,
  prompt_answer TEXT
);
```

---

## 📞 Questions?

Contact the frontend team if you need:
- Clarification on data models
- Help with JSON serialization
- Testing support
- UI adjustments for your algorithm

**Remember**: The frontend is **ready** for your algorithm. Just replace `MockDataService` and `calculateCompatibility()` with your implementation!
