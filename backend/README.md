# Toker Backend

> Backend application for social media data collection, processing, and storage

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Current Status](#current-status)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Data Format](#data-format)
- [Development](#development)

---

## 🎯 Overview

The Toker backend handles:
- **Social media data retrieval** from TikTok, Instagram, and X (Twitter)
- **Data validation and processing** (cleaning, vectorization)
- **Database storage** with CRUD operations
- **API endpoints** for frontend communication

## 🏗 Architecture

### Core Components

| Component | Description | Status |
|-----------|-------------|--------|
| `API_geter.py` | Main API data retrieval orchestrator | 🟡 Mocked |
| `TikTok_API.py` | TikTok data fetching functions | 🟡 Mocked |
| `Insta_API.py` | Instagram data fetching functions | 🟡 Mocked |
| `X_API.py` | X (Twitter) data fetching functions | 🟡 Mocked |
| `User_creation.py` | User profile creation and validation | ✅ Functional |
| `Data_processing.py` | Data cleaning and vectorization | 🔄 In Progress |
| `Database.py` | Database connection and CRUD operations | ✅ Functional |
| `API_server.py` | Django REST API endpoints | 🔄 Planned |
| `cli.py` | **Command-line interface (Current Entry Point)** | ✅ Functional |

*functionnal at a certain level

## 🚧 Current Status

**Phase: Development (CLI Version)**

### ⚠️ Important Notes

- **All social media APIs are currently mocked** - They return properly formatted fake data for development purposes
- **CLI is the primary interface** - The Django API server is not yet implemented
- **Data validation is active** - User profiles require minimum 100 likes to be stored in database

### User Flow (Mocked)

```
User connects with social account (TikTok/Instagram/X)
    ↓
API_geter.py retrieves data (mocked)
    ↓
Data validation (min. 100 likes)
    ↓
Profile created in database
```

---

## 📦 Installation

### Prerequisites

- Python 3.12+
- Poetry (Python dependency manager)

### Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies with Poetry
poetry install

# Activate virtual environment
poetry shell
```

---

## 🚀 Usage

### CLI Commands

The CLI (`cli.py`) is the current working interface for the backend.

#### Create a Fake User

Generate and store a fake user profile:

```bash
poetry run python cli.py create <platform> [--user-id USER_ID]
```

**Examples:**

```bash
# Create a TikTok user with random data
poetry run python cli.py create tiktok

# Create an Instagram user with specific ID
poetry run python cli.py create instagram --user-id custom_user_123

# Create an X (Twitter) user
poetry run python cli.py create x
```

#### List All Users (Summary)

```bash
poetry run python cli.py list
```

**Output example:**
```
================================================================================
Total: 3 utilisateur(s)
================================================================================

ID: 1 | Platform: tiktok | Username: example_user
  Likes: 6000 | Vidéos likées: 10
  Créé le: 2025-10-06 14:30:22
```

#### List All Users (Full Details)

```bash
poetry run python cli.py listfull
```

Displays complete user data including:
- Profile information (username, verification status, etc.)
- Statistics (followers, likes, videos, etc.)
- Liked videos with categories and hashtags
- Shared videos
- Top 5 categories and hashtags
- Raw JSON data

---

## 📁 Project Structure

```
backend/
├── cli.py                    # CLI interface (current entry point)
├── core/                     # Core application logic
│   ├── API_geter.py         # API orchestrator
│   ├── Data_processing.py   # Data processing utilities
│   ├── Database.py          # Database manager
│   ├── Insta_API.py         # Instagram API (mocked)
│   ├── TikTok_API.py        # TikTok API (mocked)
│   ├── User_creation.py     # User creation logic
│   └── X_API.py             # X API (mocked)
├── db/                       # Database files
├── toker.db                 # SQLite database
├── poetry.lock              # Poetry lock file
└── pyproject.toml           # Poetry configuration
```

---

## 📊 Data Format

### User Profile Schema

```json
{
  "user_id": "123456",
  "username": "example_user",
  "user_pseudo": "example_pseudo",
  "verified": false,
  "followers_count": 1500,
  "following_count": 300,
  "likes_count": 5000,
  "videos_count": 100,
  "number_of_comments": 200,
  "number_of_likes_on_own_videos": 4500,
  "number_of_likes": 6000,
  "number_of_shares": 800,
  "liked_videos": [
    {
      "video_id": "967235098701",
      "categories": ["Technology", "Education"],
      "likes": 300,
      "comments": 20,
      "shares": 15
    },
    {
      "video_id": "967235098702",
      "hashtags": ["#fun", "#entertainment"],
      "likes": 500,
      "comments": 50,
      "shares": 30
    }
  ],
  "shared_videos": [
    {
      "video_id": "967235098703",
      "categories": ["Music", "Dance"],
      "likes": 400,
      "comments": 25,
      "shares": 20
    }
  ]
}
```

### Validation Rules

- ✅ **Minimum 100 likes** required for profile storage
- ✅ All numeric fields must be non-negative
- ✅ Video IDs must be unique

---

## 🛠 Development

### Technology Stack

- **Language**: Python 3.12
- **Dependency Manager**: Poetry
- **Database**: SQLite (development)
- **Future**: Django REST Framework (API server)

### Adding Dependencies

```bash
poetry add <package-name>
```

### Development Workflow

1. Activate Poetry shell: `poetry shell`
2. Run CLI commands for testing
3. Check database with: `poetry run python cli.py listfull`

### TODO

- [ ] Implement real API integrations (TikTok, Instagram, X)
- [ ] Complete Data_processing.py (vectorization logic)
- [ ] Develop Django REST API (API_server.py)
- [ ] Add authentication and authorization
- [ ] Implement data vectorization for ML/matching
- [ ] Add comprehensive error handling
- [ ] Write unit tests
- [ ] Translate French comments to English
- [ ] Set up CI/CD pipeline

---

## 📝 Notes

- **Language**: Code comments are currently in French and will be translated to English
- **Database**: Using SQLite for development; consider PostgreSQL for production
- **Mocked Data**: All social media API calls return fake but properly formatted data
- **CLI First**: The CLI is the primary interface during initial development
