# Test Coverage

**Total: 631 passing tests** across 39 test files (+ 11 optional Supabase integration tests)

Run all tests with:
```bash
flutter test test/core/ test/features/ test/l10n/
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

### Providers (`test/core/provider/`)

| File | Tests | Covers |
|------|-------|--------|
| `locale_provider_test.dart` | 10 | Locale/language state management, initialization, locale switching, persistence to settings, listener notifications, handling of unsupported locales |

**Source:** `lib/core/provider/locale_provider.dart`

### Settings (`test/core/settings/`)

| File | Tests | Covers |
|------|-------|--------|
| `notification_settings_test.dart` | 11 | NotificationSettings defaults (`fromEmpty`), `toMap`/`fromMap` (all fields, missing fields with defaults), JSON round-trip, `copyWith` (partial/full/no-args), `toString` (time format), list independence, map key completeness |
| `biometric_settings_test.dart` | 10 | BiometricSettings defaults (`fromEmpty`), `toMap`/`fromMap` (all fields, missing fields with defaults), JSON round-trip, `copyWith` (partial/no-args), `toString`, map key completeness, zero timeout (immediate lock) |

**Sources:** `lib/core/settings/notification_settings.dart`, `lib/core/settings/biometric_settings.dart`

### Utils (`test/core/utils/`)

| File | Tests | Covers |
|------|-------|--------|
| `utils_test.dart` | 22 | Date formatting round-trips (`toDateTime`/`fromDateTimeString`, `toDate`/`fromDate`), `removeTime`, `isSameDay` (same/different day/month/year), `isDateTimeWithinTimeSpan` (within/boundary/outside), `generateRandomString` (length, uniqueness), UUID v4 generation, `toTime`, `toFileDateTime`, `printMonth`, `colorToRGBInt` |
| `debug_auto_login_test.dart` | 10 | Debug auto-login utility enable/disable logic, credential retrieval from environment variables, password/username validation rules |

**Source:** `lib/core/utils/utils.dart`, `lib/core/utils/debug_auto_login.dart`

---

## Features

### Authentication (`test/features/authentication/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/user_data_test.dart` | 12 | UserData construction (all fields, auto-generated userId, fromEmpty, defaults), `clearPassword` not in serialized output, `toMap`/`fromMap` round-trip, backward compatibility (missing salt), `toJson`/`fromJson`, LocalDb interface (`getId`, `toLocalDbMap`/`fromLocalDbMap`) |
| `models/user_settings_test.dart` | 8 | UserSettings construction (all fields, fromEmpty defaults), `toMap`/`fromMap` round-trip, missing supabaseSettings handling, `toJson`/`fromJson` string serialization, `name` property |
| `providers/debug_auto_login_provider_test.dart` | 7 | UserDataProvider debug auto-login: creating new debug users, logging in existing users, credential validation, enable/disable states |

**Sources:** `lib/features/authentication/data/models/user_data.dart`, `user_settings.dart`, `lib/features/authentication/domain/providers/user_data_provider.dart`

### Dashboard (`test/features/dashboard/`)

| File | Tests | Covers |
|------|-------|--------|
| `repositories/dashboard_repository_test.dart` | 30 | **Streak calculation:** empty data, single day (today/yesterday), consecutive days, 2+ day gap breaks streak, single-day gap tolerance, longest vs current, inactive old entries, 7-day milestone, lastEntryDate. **isTodayLogged:** logged/not logged/empty. **Week stats:** empty data, average score, category averages, note counts per day, incomplete days. **Monthly trend:** empty data, week grouping, excludes other months. **Top activities:** empty, sorted by frequency, max 5. **Insights:** today-not-logged suggestion, perfect week achievement, best category, streak milestone. **generateDashboardStats:** combined output, empty data |
| `models/dashboard_models_test.dart` | 25 | **StreakData:** empty factory, `isMilestone` (7/30/100/365 and non-milestones), `milestoneValue` (365/100/30/7/0), `copyWith`. **WeekStats:** construction, `copyWith`. **DayScore:** construction, `copyWith`. **Insight:** construction (with/without metadata), `copyWith`, InsightType enum values (9 types). **DashboardStats:** construction, `copyWith` |
| `services/mood_correlation_service_test.dart` | 26 | **Correlation Analysis:** Pearson correlation (perfect positive/negative/no correlation/insufficient data/mismatched lengths/zero variance), activity-rating correlation (insufficient days/positive correlation detection/impact calculation/case-insensitive matching), strong correlation finding (empty/sorting/threshold filtering). **Day of Week Analysis:** best/worst day identification, day names, empty handling. **Trend Detection:** insufficient data/improving/declining/stable trends, all trends filtering. **Model Tests:** CorrelationResult (strengthLabel/isPositive), DayOfWeekAnalysis (variance threshold), TrendAnalysis (significance validation) |

**Sources:** `lib/features/dashboard/data/repositories/dashboard_repository.dart`, `data/services/mood_correlation_service.dart`, `data/models/dashboard_stats.dart`, `streak_data.dart`, `week_stats.dart`, `insight.dart`

### Day Rating (`test/features/day_rating/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/day_rating_test.dart` | 12 | `DayRatings` enum `stringToEnum` (all valid values, invalid/empty/case-sensitive), `DayRating` default score (-1), custom score, `toMap`/`fromMap` round-trip for all types, Firestore map conversion (`toFirestoreMap` structure, `fromFirestoreMap` parsing), score mutation |
| `models/diary_day_test.dart` | 11 | DiaryDay construction (required fields, `fromEmpty`), `overallScore` (sum, empty, single), `toMap`/`fromMap` (data, with notes, keys), LocalDb map (JSON-encoded ratings round-trip), `getId` (ISO date format, padding) |
| `wizard_logic_test.dart` | 22 | **isDayFullyScheduled:** empty, full coverage (7:00-22:00), gaps, contiguous, late start, early end, overlapping, unsorted input. **nextAvailableTimeSlot:** empty (7:00 default), gap at beginning/middle/end, fully booked (next day). **isDayFinished (15-min chunks):** empty, full, 30-min gap detection, contiguous, many small notes. **DayRatings:** default initialization (score 3), update preserves others, reset. **Note date filtering** |

**Sources:** `lib/features/day_rating/data/models/day_rating.dart`, `diary_day.dart`, `lib/features/day_rating/domain/providers/diary_wizard_providers.dart`

### Notes (`test/features/notes/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/note_test.dart` | 14 | Note construction (all fields, auto UUID, `fromEmpty`), `copyWith` (partial/full), `toMap`/`fromMap` round-trip, all-day note, `toJson`, LocalDb map (`isAllDay` int conversion, `fromDate`/`toDate` keys), `getId` |
| `models/note_category_test.dart` | 13 | `availableNoteCategories` (5 defaults, titles, colors), `fromString` (existing, all defaults, unknown fallback, case-sensitive), equality (title-based, hashCode), `copyWith`, LocalDb map (`colorValue`), auto-generated id |
| `models/category_logic_test.dart` | 10 | `categoryNameExists` (existing, case-insensitive, non-existing, `excludeId` for rename, conflicts with others, empty list), `getCategoryById` (found/not found/empty), default category provider logic (first/null for empty) |
| `providers/note_search_state_test.dart` | 11 | NoteSearchState immutable model: active state detection, `copyWith` operations, helper methods for clearing category and date filters |
| `providers/note_search_provider_test.dart` | 12 | NoteSearchProvider state management: query updates, category filter, date range, `clearAll` operations, combined filter states |
| `providers/filtered_notes_test.dart` | 23 | `filterNotes` function: text search (title/description), category filtering, date range filtering, combined filters, sorting by date, edge cases (empty query, no matches, all-day notes) |
| `widgets/text_highlighting_test.dart` | 20 | `buildHighlightSpans` function: empty queries, matching/non-matching text, case-insensitivity, multiple matches, overlapping matches, special characters, style preservation |

**Sources:** `lib/features/notes/data/models/note.dart`, `note_category.dart`, `lib/features/notes/domain/providers/category_local_db_provider.dart`, `note_search_provider.dart`, `filtered_notes_provider.dart`, `lib/features/notes/presentation/widgets/text_highlighting.dart`

### Note Templates (`test/features/note_templates/models/`)

| File | Tests | Covers |
|------|-------|--------|
| `note_template_test.dart` | 14 | NoteTemplate construction (all fields, auto UUID, `fromEmpty`), `hasDescriptionSections`, `generateDescription` (from sections, plain fallback), `copyWith` (partial/full), `toMap`/`fromMap` (with/without sections), `toJson`, LocalDb map round-trip, `getId` |
| `description_section_test.dart` | 10 | DescriptionSection construction (title only, title+hint), `toMap`/`fromMap` (round-trip, missing keys), `copyWith`, `encode`/`decode` (list round-trip, empty list, empty string, invalid JSON, single section) |

**Sources:** `lib/features/note_templates/data/models/note_template.dart`, `description_section.dart`

### Goals (`test/features/goals/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/goal_test.dart` | 17 | Goal construction (required fields, auto UUID, status defaults), factory methods (weekly with correct 7-day range, monthly with correct month end date), calculated properties (daysRemaining/daysElapsed/timeProgress for active goals), `isInProgress` (active goal in period, completed goal excluded, past goals), `hasEnded` detection, database serialization (`toLocalDbMap`/`fromLocalDbMap` round-trip with all fields including nullable completedAt), `copyWith` (status update with completedAt), enum values (GoalTimeframe 2 values, GoalStatus 4 values) |
| `models/goal_progress_test.dart` | 17 | GoalProgress calculation (absolute progress percent, gap to target), achievement detection (`isAchieved` true/false), status determination (completed/ahead/onTrack/behind/failed with time-based progress tracking), status messages for each state, projection (final average from current/previous, success prediction), endowed progress effect (baseline from previous period, progress from 3.0→3.5 toward 4.0 = 50%), progress clamping (max 1.5), ProgressStatus enum (5 values) |
| `repositories/goal_repository_test.dart` | 29 | **calculateProgress:** correct average for goal period (5 entries = 3.8 avg), ignores days outside period (only counts 3 of 6 days), previous period baseline calculation, empty data handling. **suggestTarget:** 15% improvement (3.2 avg → 3.68), clamps to max 5.0, default 3.0 for empty data, custom improvement factor (25% → 5.0). **checkGoalCompletions:** marks achieved goals as completed (with completedAt timestamp), marks unachieved as failed, skips goals not yet ended. **calculateGoalStreak:** counts consecutive completions (3 in a row), breaks on gap >7 days, returns 0 for empty/no completed goals. **getCategoryStats:** per-category totals/completion/success rate (50% for 1/2), handles empty list (0% success rate for all categories). **CategoryGoalStats:** failed goals calculation (10 total - 7 completed = 3 failed), success rate percentage formatting (80%) |

**Sources:** `lib/features/goals/data/models/goal.dart`, `goal_progress.dart`, `lib/features/goals/data/repositories/goal_repository.dart`

### Synchronization (`test/features/synchronization/`)

| File | Tests | Covers |
|------|-------|--------|
| `export_data_test.dart` | 15 | **ExportMetadata:** `toMap`/`fromMap`, `toJson`/`fromJson`, null handling. **ExportData.isNewFormat:** new format detection, legacy array, invalid JSON, missing keys. **Unencrypted parsing:** data as list, data as string, `fromJson`. **Encrypted:** decrypt with correct password, missing password, missing salt, wrong password. **Round-trips:** unencrypted, encrypted |
| `file_db_provider_test.dart` | 10 | FileDbProvider `exportToString` (unencrypted JSON with metadata, encrypted base64, parseable back unencrypted/encrypted), file round-trip (`exportWithMetadata` + `import` unencrypted/encrypted), legacy format import, empty data export |
| `ics_converter_test.dart` | 11 | `noteToIcsEvent` (timed note, all-day, category), `createCalendar` (multiple/empty), `icsEventsToNotes` (known categories, unknown fallback, empty), ICS string round-trip (`calendarToString`/`stringToCalendar`, invalid string), multi-note round-trip |
| `ics_file_provider_test.dart` | 15 | **IcsExportMetadata:** `toMap`/`fromMap`, null handling, missing noteCount. **IcsFileProvider:** `exportToString` (unencrypted with ICS metadata, encrypted), `exportPlainIcs` (raw ICS without JSON wrapper), `importFromIcs` (wrapped unencrypted/encrypted, plain ICS, missing password error). **Round-trips:** unencrypted, encrypted. Empty data export |
| `json_serialization_test.dart` | 8 | DiaryDay list JSON round-trip (with ratings, empty, with notes), Note list JSON round-trip (timed, all-day), NoteTemplate list JSON round-trip (with sections), mixed data combined export, encryption readiness (UTF-8 encode/decode) |
| `pdf_export_test.dart` | 68 | **DateRange factories:** `lastWeek` (7-day), `lastMonth` (30-day), `currentMonth` (1st of month), `all` (empty/non-empty), `forMonth` (non-leap/leap Feb, Dec, Jan, 30-day month), `forWeek` (Monday-Sunday, week 1, week 52). **DateRange edge cases:** equality/inequality, hashCode, single date, duplicate dates, currentMonth bounds. **File naming:** CW format (week), YYMM (currentMonth), 30d range (month), YYMMDD-YYMMDD (custom/all), `forWeek`/`forMonth` exact format, no spaces/special chars, zero-padded week numbers, year boundary. **PDF generation:** valid header (%PDF), empty data, ratings-only, notes-only, single-day range, size bounds (1KB-5MB). **PDF content verification (text extraction):** username on cover, "Diary Report" title, "Summary"/"Report Period"/"Daily Breakdown" section headers, category names, note titles, score values. **PDF page structure:** minimum 3 pages, more pages with diary entries. **Large datasets:** 30/90/365 days valid PDF, PDF size scales with data. **Edge cases:** all-day notes ("All day" text), max scores (20/20), min scores (4/20), year boundary ranges, favorite days, empty title fallback to category, all 5 note categories, notes outside range excluded from top activities, custom theme colors, empty ratings (Score: 0), multiple notes per day. **Date range filtering precision:** inclusive boundaries, exclusion of out-of-range days, empty range produces valid PDF |
| `models/supabase_settings_test.dart` | 8 | SupabaseSettings construction (all fields, empty defaults), `toMap`/`fromMap` (round-trip, snake_case keys, missing keys), `copyWith` (partial/full) |
| `models/sync_state_test.dart` | 9 | `SyncStatus` enum values (idle/syncing/success/error), `SyncState` construction (required fields, all fields), `copyWith` (preserves unchanged, updates all, no mutation), progress default, typical sync lifecycle, error state preserves progress |
| `supabase_integration_test.dart` | 11 (optional) | **Skipped when `test/.env` is missing.** Connection (initialize + sign in, wrong password, sign out), diary day sync round-trip, note sync round-trip (timed + all-day), template sync round-trip, full upload + download round-trip, error handling (uninitialized, unauthenticated sync/fetch) |

**Sources:** `lib/features/synchronization/data/models/export_data.dart`, `lib/features/synchronization/domain/providers/file_db_provider.dart`, `ics_file_provider.dart`, `lib/features/synchronization/data/repositories/ics_converter.dart`, `lib/features/synchronization/data/services/pdf_report_generator.dart`, `lib/features/synchronization/domain/providers/pdf_export_provider.dart`, `supabase_api.dart`, `supabase_provider.dart`

---

## Localization (`test/l10n/`)

| File | Tests | Covers |
|------|-------|--------|
| `arb_validity_test.dart` | 6 | ARB JSON syntax validation (English + German), placeholder consistency (messages match metadata definitions), value type checks (all non-metadata are strings), ICU message format validation, unclosed placeholder detection |
| `arb_completeness_test.dart` | 6 | Translation completeness: all English keys exist in German, no extra German keys, no empty string values, orphaned metadata detection, key count parity between locales, locale marker correctness |

**Sources:** `lib/l10n/app_en.arb`, `lib/l10n/app_de.arb`

---

## Coverage Summary by Area

| Area | Status | Notes |
|------|--------|-------|
| Password hashing & verification | Covered | PBKDF2, salt, key derivation |
| AES encryption/decryption | Covered | String, base64, file, IV handling |
| Locale/language management | Covered | Switching, persistence, unsupported locales |
| Date/time utilities | Covered | Formatting, parsing, comparisons |
| Debug auto-login | Covered | Utility + provider, credentials, validation |
| All data models | Covered | Serialization, round-trips, edge cases |
| Dashboard statistics | Covered | Streaks, week/month stats, insights |
| Export/import (JSON) | Covered | Encrypted + plain, format detection, legacy compat |
| Export/import (ICS) | Covered | Plain ICS, wrapped JSON, encrypted, categories |
| PDF export | Covered | DateRange model, file naming, PDF generation, content verification, large datasets, edge cases |
| Note search & filtering | Covered | Search state, provider, filterNotes function, text highlighting |
| Wizard scheduling logic | Covered | Time slots, gaps, 15-min chunks, day coverage |
| Category management | Covered | Name validation, lookup, defaults |
| Goals & progress tracking | Covered | Goal models, progress calculation, streaks, repository logic |
| Localization (ARB) | Covered | JSON validity, completeness, placeholders, ICU format |
| Supabase settings | Covered | Model serialization |
| Biometric settings | Covered | Settings model serialization, defaults, backwards compat |
| Supabase sync state | Covered | SyncStatus enum, SyncState construction/copyWith |
| Supabase API (optional) | Covered | Requires `test/.env` with credentials; skipped otherwise |

### Not covered (requires integration/widget tests)

| Area | Reason |
|------|--------|
| Riverpod provider state (with ProviderContainer) | Requires mocking database layer |
| SQLite database operations (LocalDbHelper) | Requires real/mock SQLite database |
| Widget/UI tests (pages, forms, navigation) | Requires `WidgetTester` with full app setup |
| File picker / permission handler | Platform-specific, requires integration tests |

---

## Bugs Found by Tests

1. **DayRating Firestore format inconsistency:** `toFirestoreMap()` stores `integerValue` as `int`, but `fromFirestoreMap()` calls `int.parse()` expecting a `String` (standard Firestore REST API format). Documented in `day_rating_test.dart`.
