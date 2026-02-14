# SimpleDiary (Day Tracker) - Technology Stack & Architecture

> **Purpose:** Quick reference document for understanding the project structure, patterns, and technologies. Use this to onboard quickly without scanning the entire codebase.

---

## Project Overview

| Property | Value |
|----------|-------|
| **App Name** | SimpleDiary (package: `day_tracker`) |
| **Version** | 1.0.1+1 |
| **Platform Support** | Android, Linux, Windows |
| **Dart SDK** | >=3.0.3 <4.0.0 |
| **Flutter Version (CI)** | 3.29.3 stable |
| **Primary Language** | Dart |
| **License** | Private (not published to pub.dev) |

### What It Does

A personal diary/journal application that allows users to:
- Create and manage daily diary entries with ratings
- Add notes with categories, timestamps, and descriptions
- View calendar with scheduled notes
- Track mood/day quality over time with charts and insights
- Use templates for quick note creation
- Export/import data and sync with Supabase
- Support multiple user profiles with password authentication

---

## Core Dependencies

### Flutter SDK Packages
```yaml
flutter_localizations: sdk: flutter  # i18n support
intl: any                             # Internationalization utilities
```

### State Management
| Package | Version | Usage |
|---------|---------|-------|
| `flutter_riverpod` | ^2.3.7 | Primary state management (StateNotifier pattern) |
| `provider` | ^6.0.5 | Legacy/secondary state management |

### Database & Storage
| Package | Version | Usage |
|---------|---------|-------|
| `sqflite` | ^2.3.0 | SQLite database (Android) |
| `sqflite_common_ffi` | ^2.3.0+2 | SQLite FFI for desktop (Windows/Linux) |
| `path_provider` | ^2.0.15 | App document directories |
| `shared_preferences` | ^2.2.2 | Simple key-value storage |

### UI & Design
| Package | Version | Usage |
|---------|---------|-------|
| `google_fonts` | ^6.1.0 | Typography |
| `flex_color_picker` | ^3.3.1 | Color selection (theme/categories) |
| `flutter_rating_bar` | ^4.0.1 | Star rating input |
| `shimmer` | ^3.0.0 | Loading placeholder effects |
| `animations` | ^2.0.8 | Material motion animations |
| `loading_animation_widget` | ^1.2.0+4 | Loading indicators |

### Calendar & Charts
| Package | Version | Usage |
|---------|---------|-------|
| `syncfusion_flutter_calendar` | ^29.1.38 | Calendar view |
| `syncfusion_flutter_charts` | ^29.1.38 | Dashboard charts |
| `fl_chart` | ^0.66.0 | Additional charting |

### Cloud & Sync
| Package | Version | Usage |
|---------|---------|-------|
| `supabase_flutter` | ^2.9.0 | Backend sync (optional) |
| `http` | ^1.1.0 | HTTP client |

### Security & Authentication
| Package | Version | Usage |
|---------|---------|-------|
| `crypto` | ^3.0.3 | Password hashing |
| `encrypt` | ^5.0.3 | AES encryption |

### Utilities
| Package | Version | Usage |
|---------|---------|-------|
| `uuid` | ^4.3.3 | UUID generation for IDs |
| `logger` | ^2.0.1 | Structured logging |
| `equatable` | ^2.0.7 | Value equality |
| `collection` | ^1.18.0 | Collection utilities |
| `flutter_dotenv` | ^5.1.0 | Environment variables |
| `permission_handler` | ^12.0.0+1 | Runtime permissions |
| `package_info_plus` | ^8.3.0 | App version info |

### File Handling
| Package | Version | Usage |
|---------|---------|-------|
| `file_picker` | ^8.1.6 | File selection dialogs |
| `filesystem_picker` | ^4.1.0 | Filesystem navigation |
| `enough_icalendar` | ^0.17.0 | iCal import/export |

### Input
| Package | Version | Usage |
|---------|---------|-------|
| `speech_to_text` | ^7.0.0 | Voice input |

---

## Architecture

### Directory Structure

```
lib/
├── core/                          # Shared infrastructure
│   ├── authentication/            # Password auth service
│   ├── database/                  # LocalDbHelper, LocalDbElement interface
│   ├── encryption/                # AES encryptor
│   ├── log/                       # Logger configuration
│   ├── navigation/                # Drawer items
│   ├── provider/                  # Global providers (theme, keyboard)
│   ├── settings/                  # SettingsContainer singleton
│   ├── theme/                     # Theme definitions
│   ├── utils/                     # Utilities, platform detection
│   └── widgets/                   # Shared widgets
│
├── features/                      # Feature modules (Clean Architecture style)
│   ├── about/                     # About page
│   ├── app/                       # Main app shell, settings page
│   ├── authentication/            # User login/signup, user data
│   ├── calendar/                  # Calendar view
│   ├── dashboard/                 # Home dashboard, stats, insights
│   ├── day_rating/                # Diary wizard, day ratings
│   ├── note_templates/            # Note templates
│   ├── notes/                     # Notes, categories
│   └── synchronization/           # File export/import, Supabase sync
│
└── main.dart                      # App entry point
```

### Feature Module Structure

Each feature follows a layered architecture:

```
feature/
├── data/
│   ├── models/           # Data classes (toMap, fromMap, copyWith)
│   └── repositories/     # Database access (*_local_db.dart)
├── domain/
│   └── providers/        # Riverpod providers
└── presentation/
    ├── pages/            # Full-screen widgets
    └── widgets/          # Reusable UI components
```

---

## Key Patterns & Conventions

### State Management: Riverpod StateNotifier

```dart
// Provider definition (lib/core/provider/theme_provider.dart)
class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider() : super(initialTheme);

  void updateThemeFromSeedColor(Color newColor) {
    state = /* new theme */;
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>(
  (ref) => ThemeProvider(),
);

// Usage in widgets
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    // ...
  }
}
```

### Database: LocalDbHelper + LocalDbElement

All database entities implement `LocalDbElement`:

```dart
abstract class LocalDbElement {
  Map<String, dynamic> toLocalDbMap(LocalDbElement element);
  LocalDbElement fromLocalDbMap(Map<String, dynamic> map);
  dynamic getId();
}
```

Database tables extend `LocalDbHelper`:

```dart
class NotesLocalDb extends LocalDbHelper {
  NotesLocalDb() : super(
    tableName: 'notes',
    primaryKey: 'id',
    dbFile: File('$path/notes.db'),
  );

  @override
  Future<void> onCreateSqlTable() async {
    await database!.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        ...
      )
    ''');
  }
}
```

### Model Serialization

Models implement multiple serialization methods:

```dart
class DiaryDay implements LocalDbElement {
  // For JSON export/import
  Map<String, dynamic> toMap() { ... }
  factory DiaryDay.fromMap(Map<String, dynamic> map) { ... }

  // For SQLite (may differ, e.g., nested JSON as strings)
  Map<String, dynamic> toLocalDbMap(LocalDbElement element) { ... }
  factory DiaryDay.fromLocalDbMap(Map<String, dynamic> map) { ... }

  // Empty factory for initialization
  factory DiaryDay.fromEmpty() { ... }
}
```

### Global Settings Singleton

```dart
// lib/core/settings/settings_container.dart
class SettingsContainer {
  UserSettings activeUserSettings = UserSettings.fromEmpty();
  String lastLoggedInUsername = '';
  List<UserSettings> userSettings = [];
  String applicationDocumentsPath = '';
  // ...
}

var settingsContainer = SettingsContainer();  // Global instance
```

**Used for:** Theme preferences, user data, debug mode, file paths.

### Platform Detection

```dart
// lib/core/utils/platform_utils.dart
enum ActivePlatform { android, ios, linux, windows, web }

class PlatformUtils {
  ActivePlatform get platform { ... }
}

var activePlatform = PlatformUtils();
```

### Logging

```dart
import 'package:day_tracker/core/log/logger_instance.dart';

LogWrapper.logger.i('Info message');
LogWrapper.logger.d('Debug message');
LogWrapper.logger.e('Error message');
LogWrapper.logger.t('Trace message');
```

---

## Key Data Models

### DiaryDay
- `DateTime day` - The date (primary key via ISO date string)
- `List<DayRating> ratings` - Day quality ratings
- `List<Note> notes` - Associated notes (loaded separately)

### Note
- `String id` - UUID
- `String title`, `String description`
- `DateTime from`, `DateTime to` - Time range
- `bool isAllDay`
- `NoteCategory noteCategory` - Category with color

### NoteCategory
- `String title`
- `Color color`
- `List<String> tagList` - Optional tags

### NoteTemplate
- `String id`, `String title`
- `List<DescriptionSection> sections` - Template sections

### UserSettings
- `bool darkThemeMode`
- `Color themeSeedColor`
- `UserData savedUserData` - Profile info
- `SupabaseSettings? supabaseSettings`

### UserData
- `String username`
- `String? passwordHash`
- `bool isLoggedIn`

---

## Authentication Flow

1. **App Start** (`main.dart`):
   - Load `.env` file
   - Read settings from `settings.json`
   - Initialize database (FFI for desktop)

2. **MainPage** checks `userDataProvider`:
   - No username → `AuthUserDataPage` (register/select user)
   - Username but not logged in → `PasswordAuthenticationPage`
   - Logged in → Show app with drawer navigation

3. **Password Storage**:
   - Passwords hashed with SHA-256 + salt
   - Stored in `UserData.passwordHash`

---

## Navigation Structure

```dart
// lib/core/navigation/drawer_item_builder.dart
enum DrawerItem {
  home,        // NewDashboardPage
  calendar,    // CalendarPage
  diaryWizard, // DiaryDayWizardPage
  notes,       // NotesOverviewPage
  templates,   // NoteTemplatePage
  settings,    // SettingsPage (inside app feature)
  sync,        // SynchronizePage
  about,       // AboutPage
}
```

Main navigation via `Drawer` in `MainPage`.

---

## Database Schema (SQLite)

### Tables

| Table | Primary Key | Description |
|-------|-------------|-------------|
| `diary_days` | `day` (ISO date) | Daily diary entries with ratings |
| `notes` | `id` (UUID) | Individual notes with categories |
| `note_categories` | `title` | Category definitions |
| `note_templates` | `id` (UUID) | Note templates |

### Notes Table Schema
```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT,
  description TEXT,
  fromDate TEXT,     -- ISO datetime
  toDate TEXT,       -- ISO datetime
  isAllDay INTEGER,  -- 0 or 1
  noteCategory TEXT  -- Foreign key to categories.title
)
```

---

## Testing

### Test Structure
```
test/
├── widget_test.dart              # Default (unused)
├── core/
│   ├── authentication/           # Password service tests
│   ├── encryption/               # AES encryptor tests
│   └── utils/                    # Utility function tests
└── features/
    ├── authentication/models/    # UserData, UserSettings tests
    ├── dashboard/
    │   ├── models/               # Dashboard model tests
    │   └── repositories/         # Dashboard repository tests
    ├── day_rating/models/        # DiaryDay, DayRating tests
    ├── notes/models/             # Note, NoteCategory tests
    ├── note_templates/models/    # NoteTemplate tests
    └── synchronization/          # Export, sync tests
```

### Running Tests
```bash
flutter test                           # All tests
flutter test test/core/                # Core tests only
flutter test test/features/            # Feature tests only
```

### Test Patterns
- **Unit tests** for models (serialization round-trips)
- **Unit tests** for repositories (data logic)
- **No widget tests** currently (default template only)

---

## CI/CD Pipeline

**File:** `.github/workflows/main_flutter_build.yml`

### Jobs

1. **test** (ubuntu-latest)
   - Runs `flutter test test/core/ test/features/`
   - Creates `.env` from secrets

2. **build-windows** (needs: test)
   - Builds Windows release
   - Uploads artifact: `release-windows`

3. **build-linux** (needs: test)
   - Installs GTK3 dependencies
   - Builds Linux release
   - Uploads artifact: `release-linux`

4. **build-android** (needs: test)
   - Builds APK and App Bundle
   - Uploads artifacts: `release-apk`, `release-aab`

### Triggers
- Push/PR to `main` or `master`
- Manual dispatch

---

## Environment Configuration

### .env File
```env
PROJECT_NAME=day_tracker    # Used for app document paths
```

### Assets
```
assets/
├── app_logo.png           # App icon
├── images/
│   ├── chat.png
│   ├── assistant_icon.png
│   └── User-icon-256-blue.png
└── .env                   # Environment file (bundled)
```

---

## Code Style

- **Linting:** `flutter_lints` (standard Flutter rules)
- **Analysis:** Default `analysis_options.yaml`
- **Naming:**
  - Files: `snake_case.dart`
  - Classes: `PascalCase`
  - Variables/methods: `camelCase`
  - Private: `_prefixedWithUnderscore`
- **Imports:** Package imports with full `package:day_tracker/` paths

---

## Known Technical Debt

1. **Mixed Languages:** UI strings are hardcoded in both German and English (see Issue #47)
2. **Unused Dependencies:** Some packages may be unused (`flutter_localization` was replaced)
3. **Global Singletons:** `settingsContainer` and `activePlatform` are global singletons (testability concern)
4. **No Widget Tests:** Only unit tests exist; widget tests use default Flutter template
5. **DrawerItemBuilder:** Builds items without `BuildContext`, making localization difficult

---

## Sync Architecture

### File Export/Import
- JSON format with `ExportData` wrapper
- Supports date range filtering
- Can export/import `DiaryDay` entries with embedded notes

### Supabase Integration
- Optional cloud sync
- Configured via `SupabaseSettings` in user settings
- Stores credentials encrypted

### ICS Support
- Can export notes as iCalendar (.ics) format
- Uses `enough_icalendar` package

---

## Quick Reference Commands

```bash
# Development
flutter run -d linux           # Run on Linux
flutter run -d windows         # Run on Windows
flutter run -d <device_id>     # Run on Android

# Build
flutter build linux --release
flutter build windows --release
flutter build apk --release

# Testing
flutter test
flutter analyze

# Dependencies
flutter pub get
flutter pub upgrade
flutter pub outdated

# Code Generation (for localization)
flutter gen-l10n

# Clean
flutter clean
```

---

## Adding New Features Checklist

1. Create feature directory under `lib/features/<feature_name>/`
2. Add models in `data/models/`
3. Add database repository in `data/repositories/` (extend `LocalDbHelper`)
4. Add Riverpod providers in `domain/providers/`
5. Create pages in `presentation/pages/`
6. Create widgets in `presentation/widgets/`
7. Add navigation entry in `DrawerItemBuilder` if top-level
8. Add tests in `test/features/<feature_name>/`
9. Update this document if significant architectural additions
10. Update the build nr if manual and automatic tests are valid

---

*Last updated: 2026-02-14*
