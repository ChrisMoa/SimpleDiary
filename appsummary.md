# SimpleDiary - Application Summary

## 📖 Overview

**SimpleDiary** is a modern, feature-rich diary application built with Flutter for tracking daily activities, moods, and personal growth. The app follows Clean Architecture principles with clear separation between domain, data, and presentation layers.

### Core Concept
- Multi-user diary tracking system
- Category-based daily ratings (Work, Leisure, Sleep, Gym, etc.)
- Visual statistics and insights
- Optional cloud backup via Supabase
- Local-first SQLite database
- Cross-platform support (Android, Linux, Windows, iOS, Web)

---

## 🏗️ Architecture

### **Clean Architecture Pattern**

```
lib/
├── core/                           # Shared core functionality
│   ├── authentication/             # Password/PIN auth service
│   ├── database/                   # SQLite database abstractions
│   ├── encryption/                 # AES encryption for data security
│   ├── log/                        # Custom logging system
│   ├── models/                     # Shared models
│   ├── navigation/                 # App navigation & drawer
│   ├── provider/                   # Core Riverpod providers
│   ├── settings/                 # Settings management
│   ├── theme/                      # Theme configuration
│   ├── utils/                      # Utility functions
│   └── widgets/                    # Shared widgets
│
├── features/                       # Feature modules (Clean Architecture)
│   ├── about/                      # About page
│   ├── app/                        # Main app & settings UI
│   ├── authentication/             # User authentication & management
│   │   ├── data/models/           # User models
│   │   ├── data/repositories/     # User data persistence
│   │   ├── domain/providers/       # User state management
│   │   └── presentation/          # Auth UI (PIN, login, profile)
│   │
│   ├── calendar/                   # Calendar view
│   │
│   ├── dashboard/                  # Main dashboard with statistics
│   │   ├── data/                   # Stats models & repository
│   │   ├── domain/providers/       # Dashboard state (streak, insights, weeks)
│   │   └── presentation/          # UI (charts, heatmaps, stats)
│   │
│   ├── day_rating/                 # Diary entries & wizard
│   │   ├── data/                   # Diary day models & DB
│   │   ├── domain/                 # Wizard state management
│   │   └── presentation/          # Diary wizard & editing UI
│   │
│   ├── notes/                      # Notes & calendar events
│   │   ├── data/                   # Note models & DB
│   │   ├── domain/                 # Note state management
│   │   └── presentation/          # Notes UI (list, edit, view)
│   │
│   ├── note_templates/             # Reusable note templates
│   │   ├── data/                   # Template models & DB
│   │   ├── domain/                 # Template state management
│   │   └── presentation/          # Template management UI
│   │
│   └── synchronization/             # Cloud sync (Supabase integration)
│       ├── data/                   # Sync models & Supabase API
│       ├── domain/                 # Sync state management
│       └── presentation/          # Sync UI
│
└── main.dart                       # App entry point
```

### **Architecture Layers**

#### 1. **Core Layer** (`lib/core/`)
- **Authentication**: Password/PIN-based authentication system
- **Database**: SQLite database abstraction with encryption support
- **Encryption**: AES encryption for sensitive data
- **Logging**: Custom logger with different log levels
- **Navigation**: App drawer and navigation management
- **Providers**: Core Riverpod providers (theme, keyboard, etc.)
- **Settings**: Settings container and management
- **Theme**: Material Design 3 theme configuration
- **Utils**: Utility functions (date formatting, etc.)
- **Widgets**: Reusable UI components

#### 2. **Features Layer** (`lib/features/`)
Each feature follows **Clean Architecture** with three layers:

##### **Data Layer** (`data/`)
- **Models**: Data classes and entities
- **Repositories**: Data persistence implementations (SQLite, Supabase)

##### **Domain Layer** (`domain/`)
- **Providers**: Riverpod state providers and business logic
- State management and business rules

##### **Presentation Layer** (`presentation/`)
- **Pages**: Full-page UI screens
- **Widgets**: Reusable UI components
- **Sections**: Page sections for complex layouts

---

## 🔑 Key Features

### 1. **Multi-User System**
- User authentication via PIN/Password
- Separate diary data per user
- User switching in settings
- Encrypted database per user

### 2. **Daily Diary Entry** (Diary Wizard)
- Guided multi-step entry process
- Category-based ratings:
  - Work
  - Leisure
  - Sleep
  - Gym/Exercise
  - Social Activities
  - Personal Growth
  - Custom categories
- Rich text notes for each category
- Automatic overall score calculation
- Edit/View past entries

### 3. **Dashboard & Statistics**
- **Quick Stats**: Current streak, weekly average, daily status
- **7-Day Overview**: Visual week representation with color-coded scores
- **Mood Trend Chart**: Line chart showing emotional journey
- **Activity Heatmap**: GitHub-style contribution graph
- **Insights**: Smart suggestions based on patterns
- **Week Stats**: Weekly statistics and trends

### 4. **Notes System**
- Calendar-based event notes
- Multiple note categories (Work, Personal, Health, etc.)
- All-day and timed events
- Rich descriptions
- Calendar integration

### 5. **Note Templates**
- Reusable event templates
- Define title, description, duration, category
- Quick creation of recurring events

### 6. **Cloud Synchronization** (Supabase)
- **Upload**: Push local data to Supabase
- **Download**: Retrieve data from Supabase
- **Test Connection**: Verify Supabase credentials
- Automatic user authentication
- Encrypted data storage in cloud
- Sync Diary Days, Notes, and Templates

### 7. **Data Export/Import**
- Export diary data to JSON
- Import from JSON backup
- Password-protected encrypted exports
- Cross-device data transfer

### 8. **Theme Customization**
- Dynamic color schemes
- Material Design 3
- Dark mode support
- Customizable primary colors

### 9. **Cross-Platform**
- Android
- Linux
- Windows
- iOS (configured)
- Web (configured)

---

## 🗄️ Database Schema

### **Local SQLite Database**
Each user has an encrypted SQLite database stored in `app_flutter/SimpleDiary/user_<uuid>.db`

#### **Tables:**
1. **diary_days**
   - `day` (TEXT): Date in `dd.MM.yyyy` format
   - `ratings` (TEXT): JSON array of ratings
   - Primary key: `day`

2. **notes**
   - `id`, `title`, `description`
   - `fromDate`, `toDate` (ISO format)
   - `isAllDay` (INTEGER)
   - `noteCategory` (TEXT)
   - Primary key: `id`

3. **note_templates**
   - `id`, `title`, `description`
   - `durationMinutes` (INTEGER)
   - `noteCategory` (TEXT)
   - Primary key: `id`

### **Supabase Cloud Schema**
Supabase tables mirror local schema with UUID-based user authentication:

1. **diary_days** - Diary entries with JSONB ratings and notes
2. **notes** - Calendar events with user_id and timestamps
3. **note_templates** - Template definitions
4. **RLS Policies** - Row-level security ensuring users only see their data

See `supabase.sql` for complete schema definition.

---

## 📦 Technology Stack

### **State Management**
- **flutter_riverpod** (v2.3.7): Primary state management solution
  - Provider pattern for dependency injection
  - StateNotifier for complex state management
  - ProviderScope for app-wide state

### **Database**
- **sqflite** (v2.3.0): Local SQLite database
- **sqflite_common_ffi** (v2.3.0+2): Desktop SQLite support
- **path_provider** (v2.0.15): File system path management

### **Cloud & Sync**
- **supabase_flutter** (v2.9.0): Supabase integration
  - Auth (email/password)
  - PostgreSQL database
  - Row-level security
- **http** (v1.1.0): HTTP client

### **Security**
- **encrypt** (v5.0.3): AES encryption
- **crypto** (v3.0.3): Cryptographic functions
- User-level encryption keys

### **UI Components**
- **syncfusion_flutter_calendar** (v29.1.38): Calendar widget
- **syncfusion_flutter_charts** (v29.1.38): Charts and graphs
- **fl_chart** (v0.66.0): Line/bar charts
- **flex_color_picker** (v3.3.1): Color picker
- **flutter_rating_bar** (v4.0.1): Rating input widgets

### **Utilities**
- **intl** (v0.18.1): Date/time formatting
- **uuid** (v4.3.3): UUID generation
- **logger** (v2.0.1): Logging
- **google_fonts** (v6.1.0): Custom typography
- **flutter_dotenv** (v5.1.0): Environment variables

### **Others**
- **shared_preferences**: Settings storage
- **permission_handler**: Android permissions
- **speech_to_text**: Voice input (optional)
- **package_info_plus**: App version info
- **path**: File path manipulation

---

## 🔄 Data Flow

### **Creating a Diary Entry**

1. **User Action**: Tap "Diary Wizard" in drawer
2. **UI**: `DiaryDayWizardPage` displays
3. **State**: `DiaryWizardPageStateProvider` manages wizard state
4. **User**: Selects date, rates categories, adds notes
5. **State**: Provider aggregates data into `DiaryDay` model
6. **Data**: `DiaryDayLocalDbProvider` saves to SQLite
7. **Database**: `diary_days` table stores encrypted entry
8. **Sync**: Optional upload to Supabase

### **Dashboard Statistics**

1. **UI**: `NewDashboardPage` displays
2. **Provider**: `DashboardStatsProvider` fetches all diary days
3. **Repository**: Queries local SQLite database
4. **Processing**: Calculates stats (streak, averages, trends)
5. **UI**: Displays charts, heatmaps, insights

### **Cloud Synchronization**

#### **Upload Flow**
1. User taps "Upload to Supabase"
2. `SupabaseSyncNotifier.syncToSupabase()`
3. Initializes Supabase client with credentials
4. Signs in with email/password
5. Fetches local data (diary days, notes, templates)
6. Converts to Supabase format
7. Upserts each item to Supabase
8. Shows success/error message

#### **Download Flow**
1. User taps "Download from Supabase"
2. `SupabaseSyncNotifier.syncFromSupabase()`
3. Authenticates with Supabase
4. Fetches data for authenticated user:
   - `fetchDiaryDays()`: Gets diary entries
   - `fetchNotes()`: Gets calendar notes
   - `fetchTemplates()`: Gets note templates
5. Parses ISO datetime format to app format
6. Saves to local SQLite database
7. Updates UI with downloaded data

---

## 🎯 Recent Improvements (Latest Session)

### **Fixed Supabase Download Issue**
**Problem**: FormatException when downloading notes
```dart
FormatException: Trying to read . from 2025-10-19T07:00:00.000 at 5
```

**Root Cause**: 
- Supabase returns ISO 8601 datetime strings (`2025-10-19T07:00:00.000`)
- App expects custom format (`dd.MM.yyyy HH:mm`)
- Direct parsing failed

**Solution**:
- Parse ISO format with `DateTime.parse()`
- Convert to app format with `Utils.toDateTime()`
- Proper format conversion in `fetchNotes()` method

**Location**: `lib/features/synchronization/data/repositories/supabase_api.dart`

### **Added Test Connection Button**
- New button in Supabase Settings
- Validates all credentials
- Tests authentication
- Shows success/failure messages

### **Improved Logging**
- Comprehensive logging throughout sync process
- Individual item processing logs
- Error details with stack traces
- Debug-friendly output

---

## 🔧 Configuration

### **Environment Variables** (`.env`)
```env
PROJECT_NAME='OwnProjectName'
```

### **Settings Structure**
- Per-user settings in `settings.json`
- Supabase credentials stored per user
- Theme preferences
- Encryption keys per user

### **Build Configuration**
- **Android**: `android/app/build.gradle.kts`
- **iOS**: `ios/Runner.xcodeproj`
- **Linux**: `linux/CMakeLists.txt`
- **Windows**: `windows/CMakeLists.txt`

---

## 📝 Key User Flows

### **Initial Setup**
1. Launch app → PIN/Password authentication page
2. Enter PIN → Auth user data page
3. Enter username → Main page (Dashboard)

### **Adding Diary Entry**
1. Dashboard → Drawer → "Diary Wizard"
2. Select date → Choose categories
3. Rate each category (1-5 stars)
4. Add optional notes
5. Save → Returns to Dashboard

### **Viewing Statistics**
1. Dashboard displays automatically on login
2. Shows: Quick stats, mood chart, activity heatmap, insights
3. Tap specific day to view detailed entry
4. Edit from detail page

### **Cloud Backup**
1. Drawer → "Data Synchronization"
2. Configure Supabase settings (URL, key, email, password)
3. Tap "Test Connection" to verify
4. Tap "Upload to Supabase" to backup
5. Tap "Download from Supabase" to restore

---

## 🚀 Entry Points

### **Main Entry Point** (`main.dart`)
- Initializes FFI for desktop platforms
- Loads environment variables (`.env`)
- Requests Android permissions
- Reads settings
- Initializes logger
- Creates ProviderScope for Riverpod
- Launches MaterialApp

### **Navigation** (`MainPage`)
- Conditional routing:
  - Empty username → `AuthUserDataPage`
  - Not logged in → `PasswordAuthenticationPage`
  - Logged in → Drawer-based navigation
- Drawer items:
  0. Home (Dashboard)
  1. Settings
  2. Calendar
  3. Diary Wizard
  4. Notes Overview
  5. Templates
  6. Data Synchronization
  7. About

---

## 🐛 Known Issues & Considerations

1. **Kotlin Version Warning**: Android build warns about Kotlin 1.8.22
   - Should upgrade to Kotlin 2.1.0+
   
2. **Google Fonts Network Dependency**: Requires internet for first load
   - Falls back gracefully on offline

3. **Encryption**: Uses AES encryption for sensitive data
   - Encryption keys tied to user authentication

4. **Supabase**: Currently configured for local Supabase instance
   - Default URL: `http://192.168.2.201:8000`
   - Can be changed in settings

---

## 📊 Data Model Examples

### **DiaryDay Model**
```dart
class DiaryDay {
  DateTime day;
  List<Note> notes;
  List<DayRating> ratings;
  
  int get overallScore;  // Sum of all ratings
}
```

### **DayRating Model**
```dart
class DayRating {
  String title;  // Category name
  int score;     // 1-5 rating
  String note;   // Optional description
}
```

### **Note Model**
```dart
class Note {
  String id;
  String title;
  String description;
  DateTime from;
  DateTime to;
  bool isAllDay;
  NoteCategory noteCategory;
}
```

---

## 🧪 Testing

### **Test Files**
- `test/widget_test.dart`: Basic widget tests
- `test/export_import_salt_test.dart`: Export/import functionality tests

### **Manual Testing Workflow**
1. Run on Linux: `flutter run -d linux --debug`
2. Run on Android: `flutter run -d R52X605D0LR --debug`
3. Monitor logs with `adb logcat | grep flutter`
4. Test sync functionality
5. Verify data persistence

---

## 📚 Additional Documentation

- **README.md**: User-facing documentation
- **TEST_EXPORT_IMPORT.md**: Export/import testing guide
- **supabase.sql**: Database schema for cloud sync
- **template.env**: Environment variable template

---

**Generated**: 2025-10-26  
**Version**: 1.0.0+1  
**Architecture**: Clean Architecture with Riverpod  
**Platform**: Flutter 3.0+ / Dart 3.0+

