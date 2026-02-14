# Test Coverage

**Total: 299 passing tests** across 21 test files

Run all tests with:
```bash
flutter test test/core/ test/features/
```

---

## Core

### Authentication (`test/core/authentication/`)

| File | Tests | Covers |
|------|-------|--------|
| `password_auth_service_test.dart` | 13 | PBKDF2 password hashing, salt generation (32-byte random), password verification (correct/wrong/empty/special chars/unicode), database encryption key derivation (consistency, differs from hash), base64 output validation |

**Source:** `lib/core/authentication/password_auth_service.dart`

### Encryption (`test/core/encryption/`)

| File | Tests | Covers |
|------|-------|--------|
| `aes_encryptor_test.dart` | 14 | AES-256-CBC initialization (valid key, short key padding), string encrypt/decrypt round-trip (plain text, unicode), base64 encrypt/decrypt (round-trip, random IV verification, long text, JSON data), invalid data handling, wrong key detection, file encrypt/decrypt round-trip, IV prepending |

**Source:** `lib/core/encryption/aes_encryptor.dart`

### Utils (`test/core/utils/`)

| File | Tests | Covers |
|------|-------|--------|
| `utils_test.dart` | 22 | Date formatting round-trips (`toDateTime`/`fromDateTimeString`, `toDate`/`fromDate`), `removeTime`, `isSameDay` (same/different day/month/year), `isDateTimeWithinTimeSpan` (within/boundary/outside), `generateRandomString` (length, uniqueness), UUID v4 generation, `toTime`, `toFileDateTime`, `printMonth`, `colorToRGBInt` |

**Source:** `lib/core/utils/utils.dart`

---

## Features

### Authentication Models (`test/features/authentication/models/`)

| File | Tests | Covers |
|------|-------|--------|
| `user_data_test.dart` | 12 | UserData construction (all fields, auto-generated userId, fromEmpty, defaults), `clearPassword` not in serialized output, `toMap`/`fromMap` round-trip, backward compatibility (missing salt), `toJson`/`fromJson`, LocalDb interface (`getId`, `toLocalDbMap`/`fromLocalDbMap`) |
| `user_settings_test.dart` | 8 | UserSettings construction (all fields, fromEmpty defaults), `toMap`/`fromMap` round-trip, missing supabaseSettings handling, `toJson`/`fromJson` string serialization, `name` property |

**Sources:** `lib/features/authentication/data/models/user_data.dart`, `user_settings.dart`

### Dashboard (`test/features/dashboard/`)

| File | Tests | Covers |
|------|-------|--------|
| `repositories/dashboard_repository_test.dart` | 30 | **Streak calculation:** empty data, single day (today/yesterday), consecutive days, 2+ day gap breaks streak, single-day gap tolerance, longest vs current, inactive old entries, 7-day milestone, lastEntryDate. **isTodayLogged:** logged/not logged/empty. **Week stats:** empty data, average score, category averages, note counts per day, incomplete days. **Monthly trend:** empty data, week grouping, excludes other months. **Top activities:** empty, sorted by frequency, max 5. **Insights:** today-not-logged suggestion, perfect week achievement, best category, streak milestone. **generateDashboardStats:** combined output, empty data |
| `models/dashboard_models_test.dart` | 25 | **StreakData:** empty factory, `isMilestone` (7/30/100/365 and non-milestones), `milestoneText` (Jahr/100 Tage/30 Tage/Woche/empty), `copyWith`. **WeekStats:** construction, `copyWith`. **DayScore:** construction, `copyWith`. **Insight:** construction (with/without metadata), `copyWith`, InsightType enum values. **DashboardStats:** construction, `copyWith` |

**Sources:** `lib/features/dashboard/data/repositories/dashboard_repository.dart`, `models/dashboard_stats.dart`, `streak_data.dart`, `week_stats.dart`, `insight.dart`

### Day Rating (`test/features/day_rating/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/day_rating_test.dart` | 12 | `DayRatings` enum `stringToEnum` (all valid values, invalid/empty/case-sensitive), `DayRating` default score (-1), custom score, `toMap`/`fromMap` round-trip for all types, Firestore map conversion (`toFirestoreMap` structure, `fromFirestoreMap` parsing), score mutation |
| `models/diary_day_test.dart` | 11 | DiaryDay construction (required fields, `fromEmpty`), `overallScore` (sum, empty, single), `toMap`/`fromMap` (data, with notes, keys), LocalDb map (JSON-encoded ratings round-trip), `getId` (ISO date format, padding) |
| `wizard_logic_test.dart` | 22 | **isDayFullyScheduled:** empty, full coverage (7:00-22:00), gaps, contiguous, late start, early end, overlapping, unsorted input. **nextAvailableTimeSlot:** empty (7:00 default), gap at beginning/middle/end, fully booked (next day). **isDayFinished (15-min chunks):** empty, full, 30-min gap detection, contiguous, many small notes. **DayRatings:** default initialization (score 3), update preserves others, reset. **Note date filtering** |

**Sources:** `lib/features/day_rating/data/models/day_rating.dart`, `diary_day.dart`, `lib/features/day_rating/domain/providers/diary_wizard_providers.dart`

### Notes (`test/features/notes/models/`)

| File | Tests | Covers |
|------|-------|--------|
| `note_test.dart` | 14 | Note construction (all fields, auto UUID, `fromEmpty`), `copyWith` (partial/full), `toMap`/`fromMap` round-trip, all-day note, `toJson`, LocalDb map (`isAllDay` int conversion, `fromDate`/`toDate` keys), `getId` |
| `note_category_test.dart` | 13 | `availableNoteCategories` (5 defaults, titles, colors), `fromString` (existing, all defaults, unknown fallback, case-sensitive), equality (title-based, hashCode), `copyWith`, LocalDb map (`colorValue`), auto-generated id |
| `category_logic_test.dart` | 10 | `categoryNameExists` (existing, case-insensitive, non-existing, `excludeId` for rename, conflicts with others, empty list), `getCategoryById` (found/not found/empty), default category provider logic (first/null for empty) |

**Sources:** `lib/features/notes/data/models/note.dart`, `note_category.dart`, `lib/features/notes/domain/providers/category_local_db_provider.dart`

### Note Templates (`test/features/note_templates/models/`)

| File | Tests | Covers |
|------|-------|--------|
| `note_template_test.dart` | 14 | NoteTemplate construction (all fields, auto UUID, `fromEmpty`), `hasDescriptionSections`, `generateDescription` (from sections, plain fallback), `copyWith` (partial/full), `toMap`/`fromMap` (with/without sections), `toJson`, LocalDb map round-trip, `getId` |
| `description_section_test.dart` | 10 | DescriptionSection construction (title only, title+hint), `toMap`/`fromMap` (round-trip, missing keys), `copyWith`, `encode`/`decode` (list round-trip, empty list, empty string, invalid JSON, single section) |

**Sources:** `lib/features/note_templates/data/models/note_template.dart`, `description_section.dart`

### Synchronization (`test/features/synchronization/`)

| File | Tests | Covers |
|------|-------|--------|
| `export_data_test.dart` | 15 | **ExportMetadata:** `toMap`/`fromMap`, `toJson`/`fromJson`, null handling. **ExportData.isNewFormat:** new format detection, legacy array, invalid JSON, missing keys. **Unencrypted parsing:** data as list, data as string, `fromJson`. **Encrypted:** decrypt with correct password, missing password, missing salt, wrong password. **Round-trips:** unencrypted, encrypted |
| `file_db_provider_test.dart` | 10 | FileDbProvider `exportToString` (unencrypted JSON with metadata, encrypted base64, parseable back unencrypted/encrypted), file round-trip (`exportWithMetadata` + `import` unencrypted/encrypted), legacy format import, empty data export |
| `ics_converter_test.dart` | 11 | `noteToIcsEvent` (timed note, all-day, category), `createCalendar` (multiple/empty), `icsEventsToNotes` (known categories, unknown fallback, empty), ICS string round-trip (`calendarToString`/`stringToCalendar`, invalid string), multi-note round-trip |
| `ics_file_provider_test.dart` | 15 | **IcsExportMetadata:** `toMap`/`fromMap`, null handling, missing noteCount. **IcsFileProvider:** `exportToString` (unencrypted with ICS metadata, encrypted), `exportPlainIcs` (raw ICS without JSON wrapper), `importFromIcs` (wrapped unencrypted/encrypted, plain ICS, missing password error). **Round-trips:** unencrypted, encrypted. Empty data export |
| `json_serialization_test.dart` | 8 | DiaryDay list JSON round-trip (with ratings, empty, with notes), Note list JSON round-trip (timed, all-day), NoteTemplate list JSON round-trip (with sections), mixed data combined export, encryption readiness (UTF-8 encode/decode) |
| `models/supabase_settings_test.dart` | 8 | SupabaseSettings construction (all fields, empty defaults), `toMap`/`fromMap` (round-trip, snake_case keys, missing keys), `copyWith` (partial/full) |

**Sources:** `lib/features/synchronization/data/models/export_data.dart`, `lib/features/synchronization/domain/providers/file_db_provider.dart`, `ics_file_provider.dart`, `lib/features/synchronization/data/repositories/ics_converter.dart`

---

## Coverage Summary by Area

| Area | Status | Notes |
|------|--------|-------|
| Password hashing & verification | Covered | PBKDF2, salt, key derivation |
| AES encryption/decryption | Covered | String, base64, file, IV handling |
| Date/time utilities | Covered | Formatting, parsing, comparisons |
| All data models | Covered | Serialization, round-trips, edge cases |
| Dashboard statistics | Covered | Streaks, week/month stats, insights |
| Export/import (JSON) | Covered | Encrypted + plain, format detection, legacy compat |
| Export/import (ICS) | Covered | Plain ICS, wrapped JSON, encrypted, categories |
| Wizard scheduling logic | Covered | Time slots, gaps, 15-min chunks, day coverage |
| Category management | Covered | Name validation, lookup, defaults |
| Supabase settings | Covered | Model serialization |

### Not covered (requires integration/widget tests)

| Area | Reason |
|------|--------|
| Riverpod provider state (with ProviderContainer) | Requires mocking database layer |
| SQLite database operations (LocalDbHelper) | Requires real/mock SQLite database |
| Widget/UI tests (pages, forms, navigation) | Requires `WidgetTester` with full app setup |
| Supabase API calls | Requires network mocking or test server |
| File picker / permission handler | Platform-specific, requires integration tests |

---

## Bugs Found by Tests

1. **DayRating Firestore format inconsistency:** `toFirestoreMap()` stores `integerValue` as `int`, but `fromFirestoreMap()` calls `int.parse()` expecting a `String` (standard Firestore REST API format). Documented in `day_rating_test.dart`.
