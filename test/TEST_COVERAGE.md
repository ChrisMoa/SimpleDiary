# Test Coverage

**Total: 1001+ passing tests** across 67 test files (+ 16 optional/skipped Supabase integration tests)

Run all tests with:
```bash
flutter test test/core/ test/features/ test/l10n/ test/integration/
```

---

## Core

### Authentication (`test/core/authentication/`)

| File | Tests | Covers |
|------|-------|--------|
| `password_auth_service_test.dart` | 15 | PBKDF2 password hashing, salt generation (32-byte random), password verification (correct/wrong/empty/special chars/unicode), database encryption key derivation (consistency, differs from hash), base64 output validation |

**Source:** `lib/core/authentication/password_auth_service.dart`

### Database (`test/core/database/`)

| File | Tests | Covers |
|------|-------|--------|
| `db_column_test.dart` | 14 | `toSqlDefinition` (text primary key, text not null, text nullable, text with default, integer not null, integer with default, real not null, custom column type), `createTableSql` (valid CREATE TABLE statement, single column table), convenience constructors (`textPrimaryKey` sets isPrimaryKey, `text`/`integer`/`real` default to isNotNull) |

**Source:** `lib/core/database/db_column.dart`

### Encryption (`test/core/encryption/`)

| File | Tests | Covers |
|------|-------|--------|
| `aes_encryptor_test.dart` | 14 | AES-256-CBC initialization (valid key, short key padding), string encrypt/decrypt round-trip (plain text, unicode), base64 encrypt/decrypt (round-trip, random IV verification, long text, JSON data), invalid data handling, wrong key detection, file encrypt/decrypt round-trip, IV prepending |

**Source:** `lib/core/encryption/aes_encryptor.dart`

### Providers (`test/core/provider/`)

| File | Tests | Covers |
|------|-------|--------|
| `locale_provider_test.dart` | 9 | Locale/language state management, initialization, locale switching, persistence to settings, listener notifications, handling of unsupported locales |

**Source:** `lib/core/provider/locale_provider.dart`

### Settings (`test/core/settings/`)

| File | Tests | Covers |
|------|-------|--------|
| `notification_settings_test.dart` | 21 | NotificationSettings defaults (`fromEmpty` incl. smart reminder + weekly review fields), `toMap`/`fromMap` (all fields incl. `maxSmartRemindersPerDay`/`quietHoursStartMinutes`/`quietHoursEndMinutes`/`weeklyReviewEnabled`/`weeklyReviewDay`/`weeklyReviewTimeMinutes`, missing fields with defaults, backward compat), JSON round-trip, `copyWith` (partial/full/no-args/new fields/weekly review fields), `toString` (time + quiet hours + weekly review format), `quietHoursStart`/`quietHoursEnd`/`weeklyReviewTime` getters/setters (minutes↔TimeOfDay), list independence, map key completeness |
| `biometric_settings_test.dart` | 10 | BiometricSettings defaults (`fromEmpty`), `toMap`/`fromMap` (all fields, missing fields with defaults), JSON round-trip, `copyWith` (partial/no-args), `toString`, map key completeness, zero timeout (immediate lock) |
| `backup_settings_test.dart` | 30 | BackupSettings defaults (`fromEmpty`), `toMap`/`fromMap` (all fields incl. `cloudSyncEnabled`, missing fields with defaults), JSON round-trip, `copyWith` (partial/no-args/cloudSyncEnabled), `preferredTime` getter/setter (minutes↔TimeOfDay), `lastBackupDateTime` parsing (valid/null), `isBackupOverdue` (never/disabled/daily/weekly/monthly thresholds), `toString`, BackupFrequency enum (toJson/fromJson/unknown fallback) |

**Sources:** `lib/core/settings/notification_settings.dart`, `lib/core/settings/biometric_settings.dart`, `lib/core/settings/backup_settings.dart`

### Backup (`test/core/backup/`)

| File | Tests | Covers |
|------|-------|--------|
| `backup_metadata_test.dart` | 21 | BackupMetadata `isSuccessful` (no error/with error), `formattedSize` (bytes/KB/MB), `toMap`/`fromMap` (all fields incl. `encrypted`/`cloudSynced`, missing optional fields), JSON round-trip (success/error/encrypted/cloudSynced), `copyWith` (cloudSynced/no-args), `toString`, defaults, BackupType enum (toJson/fromJson/unknown fallback) |

**Source:** `lib/core/backup/backup_metadata.dart`

### Onboarding (`test/core/onboarding/`)

| File | Tests | Covers |
|------|-------|--------|
| `onboarding_status_test.dart` | 9 | `OnboardingStatus.initial()` defaults, `load()` from empty prefs, `markComplete()` (default + demo mode), `completedAt` ISO-8601 timestamp, `clearDemoMode()` preserves completed flag, `clear()` full reset, `toString()` content, round-trip |
| `onboarding_service_test.dart` | 13 | `shouldShowOnboarding()` (true when empty / false after completion / false after demo), `markOnboardingComplete()` (normal + demo), `isDemoMode()` (empty / normal / demo), `exitDemoMode()` keeps onboarding done, `resetOnboarding()` re-enables flow + clears demo, full demo lifecycle, full normal lifecycle including simulated app restart |

**Sources:** `lib/core/onboarding/onboarding_status.dart`, `lib/core/services/onboarding_service.dart`

### Services (`test/core/services/`)

| File | Tests | Covers |
|------|-------|--------|
| `smart_reminder_algorithm_test.dart` | 25 | `shouldSendReminder` (entry exists → false, max reached → false, quiet hours midnight-crossing → false, early morning → false, all conditions met → true, below max → true, boundary at end → true, boundary at start → false, exceeded max → false), `calculateIntensity` (0 → gentle, negative → gentle, 1 → normal, 2 → urgent, many → urgent), `isInQuietHours` (midnight-crossing after start/before end/outside, same-day inside/outside/at start/at end, equal start=end disables, midnight, end boundary), `ReminderIntensity` enum values |
| `diary_status_service_test.dart` | 10 | `hasEntryForToday` (no entry → false, after mark → true, different day → false), `markEntryWritten` (stores ISO date), `getRemindersSentToday` (0 initially, preserves on same day, resets on new day), `incrementReminderCount` (single/multiple increments, increment after day reset starts from 1) |
| `weekly_review_status_service_test.dart` | 13 | `isReviewDueForLastWeek` (true when empty, false after marking current previous week, true for older reviewed week, true when only year/week stored), `markReviewShown` (stores year+week, overwrites previous), `getLastReviewedWeek` (null initially, returns year+week after mark, null when partial data), `clear` (removes state, restores due status), full lifecycle (due→mark→not due→clear→due) |

| `supabase_auto_sync_service_test.dart` | 1 | `resetDebounce` (clears last sync time without error) |

**Sources:** `lib/core/services/smart_reminder_algorithm.dart`, `lib/core/services/diary_status_service.dart`, `lib/core/services/weekly_review_status_service.dart`, `lib/core/services/supabase_auto_sync_service.dart`

---

### Utils (`test/core/utils/`)

| File | Tests | Covers |
|------|-------|--------|
| `utils_test.dart` | 25 | Date formatting round-trips (`toDateTime`/`fromDateTimeString`, `toDate`/`fromDate`), `removeTime`, `isSameDay` (same/different day/month/year), `isDateTimeWithinTimeSpan` (within/boundary/outside), `generateRandomString` (length, uniqueness), UUID v4 generation, `toTime`, `toFileDateTime`, `printMonth`, `colorToRGBInt` |
| `debug_auto_login_test.dart` | 12 | Debug auto-login utility enable/disable logic, credential retrieval from environment variables, password/username validation rules |

**Source:** `lib/core/utils/utils.dart`, `lib/core/utils/debug_auto_login.dart`

---

## Features

### Authentication (`test/features/authentication/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/user_data_test.dart` | 10 | UserData construction (all fields, auto-generated userId, fromEmpty, defaults), `clearPassword` not in serialized output, `toMap`/`fromMap` round-trip, backward compatibility (missing salt), `toJson`/`fromJson` |
| `models/user_settings_test.dart` | 10 | UserSettings construction (all fields, fromEmpty defaults), `toMap`/`fromMap` round-trip, missing supabaseSettings handling, `toJson`/`fromJson` string serialization, `name` property |
| `providers/debug_auto_login_provider_test.dart` | 6 | UserDataProvider debug auto-login: creating new debug users, logging in existing users, credential validation, enable/disable states |

**Sources:** `lib/features/authentication/data/models/user_data.dart`, `user_settings.dart`, `lib/features/authentication/domain/providers/user_data_provider.dart`

### Dashboard (`test/features/dashboard/`)

| File | Tests | Covers |
|------|-------|--------|
| `repositories/dashboard_repository_test.dart` | 32 | **Streak calculation:** empty data, single day (today/yesterday), consecutive days, 2+ day gap breaks streak, single-day gap tolerance, longest vs current, inactive old entries, 7-day milestone, lastEntryDate. **isTodayLogged:** logged/not logged/empty. **Week stats:** empty data, average score, category averages, note counts per day, incomplete days, moodQuadrant from enhanced rating (populated/null without). **Monthly trend:** empty data, week grouping, excludes other months. **Top activities:** empty, sorted by frequency, max 5. **Insights:** today-not-logged suggestion, perfect week achievement, best category, streak milestone. **generateDashboardStats:** combined output, empty data |
| `models/dashboard_models_test.dart` | 25 | **StreakData:** empty factory, `isMilestone` (7/30/100/365 and non-milestones), `milestoneValue` (365/100/30/7/0), `copyWith`. **WeekStats:** construction, `copyWith`. **DayScore:** construction, `copyWith`, `moodQuadrant` (defaults null, construction with value, copyWith update). **Insight:** construction (with/without metadata), `copyWith`, InsightType enum values. **DashboardStats:** construction, `copyWith` |
| `services/mood_correlation_service_test.dart` | 26 | **Correlation Analysis:** Pearson correlation (perfect positive/negative/no correlation/insufficient data/mismatched lengths/zero variance), activity-rating correlation (insufficient days/positive correlation detection/impact calculation/case-insensitive matching), strong correlation finding (empty/sorting/threshold filtering). **Day of Week Analysis:** best/worst day identification, day names, empty handling. **Trend Detection:** insufficient data/improving/declining/stable trends, all trends filtering. **Model Tests:** CorrelationResult (strengthLabel/isPositive), DayOfWeekAnalysis (variance threshold), TrendAnalysis (significance validation) |
| `providers/granular_providers_test.dart` | 11 | **currentStreakProvider:** returns streak from stats, returns 0 before load, updates on invalidation. **todayLoggedProvider:** returns true/false, returns false before load. **weekAverageProvider:** returns average, returns 0.0 before load, handles zero average. **Selective rebuild:** all providers derive from shared source, consistent values across providers |

**Sources:** `lib/features/dashboard/data/repositories/dashboard_repository.dart`, `data/services/mood_correlation_service.dart`, `data/models/dashboard_stats.dart`, `streak_data.dart`, `week_stats.dart`, `insight.dart`, `lib/features/dashboard/domain/providers/dashboard_stats_provider.dart`

### Day Rating (`test/features/day_rating/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/day_rating_test.dart` | 10 | `DayRatings` enum `stringToEnum` (all valid values, invalid/empty/case-sensitive), `DayRating` default score (-1), custom score, `toMap`/`fromMap` round-trip for all types, Firestore map conversion (`toFirestoreMap` structure, `fromFirestoreMap` parsing), score mutation |
| `models/diary_day_test.dart` | 11 | DiaryDay construction (required fields, `fromEmpty`), `overallScore` (sum, empty, single), `toMap`/`fromMap` (data, with notes, keys), LocalDb map (JSON-encoded ratings round-trip), `primaryKeyValue` (ISO date format, padding) |
| `models/enhanced_day_rating_test.dart` | 39 | **MoodPosition:** valence/arousal storage, quadrant detection (all 4 quadrants), label generation (Excited/Anxious/Calm/Sad/Pleasant/Neutral), `copyWith`, `toMap`/`fromMap` round-trip. **WellbeingRating:** defaults (all zero), `totalScore`, `averageScore` (excludes zeros, 0.0 when empty), `isComplete`, `copyWith`, `toMap`/`fromMap` round-trip, missing keys default to zero, `WellbeingRating.empty()`. **EmotionEntry:** construction, `copyWith`, `toMap`/`fromMap` round-trip, unknown emotion fallback to neutral. **ContextualFactors:** defaults (all null/empty), `copyWith`, `toMap`/`fromMap` round-trip (sleepHours/quality/exercised/stressLevel/tags), missing keys, `ContextualFactors.empty()`. **EnhancedDayRating:** `empty()` factory, `overallScore` (0 when empty, scales 0-30→0-20, half wellbeing→12), `copyWith`, `toMap`/`fromMap` round-trip (with/without quickMood, emotions, context), `toJson`/`fromJson` round-trip |
| `models/rating_preferences_test.dart` | 10 | **RatingPreferences:** default values (mode=balanced, showQuickMood=true, 6 enabled dimensions), `copyWith` (single/multiple/no-args), `toMap`/`fromMap` round-trip (all fields, missing keys→defaults, unknown mode→balanced), `toJson`/`fromJson` round-trip. **RatingMode enum:** distinct names, 4 values (quick/balanced/detailed/custom) |
| `wizard_logic_test.dart` | 23 | **isDayFullyScheduled:** empty, full coverage (7:00-22:00), gaps, contiguous, late start, early end, overlapping, unsorted input. **nextAvailableTimeSlot:** empty (7:00 default), gap at beginning/middle/end, fully booked (next day). **isDayFinished (15-min chunks):** empty, full, 30-min gap detection, contiguous, many small notes. **DayRatings:** default initialization (score 3), update preserves others, reset. **Note date filtering** |

**Sources:** `lib/features/day_rating/data/models/day_rating.dart`, `diary_day.dart`, `enhanced_day_rating.dart`, `rating_preferences.dart`, `lib/features/day_rating/domain/providers/diary_wizard_providers.dart`

### Notes (`test/features/notes/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/note_test.dart` | 12 | Note construction (all fields, auto UUID, `fromEmpty`), `copyWith` (partial/full), `toMap`/`fromMap` round-trip, all-day note, `toJson`, LocalDb map (`isAllDay` int conversion, `fromDate`/`toDate` keys), `primaryKeyValue` |
| `models/note_category_test.dart` | 14 | `availableNoteCategories` (5 defaults, titles, colors), `fromString` (existing, all defaults, unknown fallback, case-sensitive), equality (title-based, hashCode), `copyWith`, LocalDb map (`colorValue`), auto-generated id |
| `models/note_attachment_test.dart` | 20 | NoteAttachment construction (all fields, auto UUID, unique IDs, with remoteUrl), `copyWith` (preserves unchanged, updates all), `toMap`/`fromMap` round-trip (all keys, missing fileSize defaults to 0, remoteUrl null by default), `toJson`/`fromJson` round-trip (valid JSON, data preserved), LocalDb map round-trip (same keys as toMap), `primaryKeyValue` returns id, remoteUrl serialization round-trip, backward compat (missing remoteUrl key → null) |
| `models/category_logic_test.dart` | 12 | `categoryNameExists` (existing, case-insensitive, non-existing, `excludeId` for rename, conflicts with others, empty list), `getCategoryById` (found/not found/empty), default category provider logic (first/null for empty) |
| `providers/note_search_state_test.dart` | 12 | NoteSearchState immutable model: active state detection, `copyWith` operations, helper methods for clearing category and date filters |
| `providers/note_search_provider_test.dart` | 11 | NoteSearchProvider state management: query updates, category filter, date range, `clearAll` operations, combined filter states |
| `providers/filtered_notes_test.dart` | 21 | `filterNotes` function: text search (title/description), category filtering, date range filtering, combined filters, sorting by date, edge cases (empty query, no matches, all-day notes) |
| `widgets/text_highlighting_test.dart` | 18 | `buildHighlightSpans` function: empty queries, matching/non-matching text, case-insensitivity, multiple matches, overlapping matches, special characters, style preservation |

**Sources:** `lib/features/notes/data/models/note.dart`, `note_category.dart`, `note_attachment.dart`, `lib/features/notes/domain/providers/category_local_db_provider.dart`, `note_search_provider.dart`, `filtered_notes_provider.dart`, `lib/features/notes/presentation/widgets/text_highlighting.dart`

### Note Templates (`test/features/note_templates/models/`)

| File | Tests | Covers |
|------|-------|--------|
| `note_template_test.dart` | 15 | NoteTemplate construction (all fields, auto UUID, `fromEmpty`), `hasDescriptionSections`, `generateDescription` (from sections, plain fallback), `copyWith` (partial/full), `toMap`/`fromMap` (with/without sections), `toJson`, LocalDb map round-trip, `primaryKeyValue` |
| `description_section_test.dart` | 12 | DescriptionSection construction (title only, title+hint), `toMap`/`fromMap` (round-trip, missing keys), `copyWith`, `encode`/`decode` (list round-trip, empty list, empty string, invalid JSON, single section) |

**Sources:** `lib/features/note_templates/data/models/note_template.dart`, `description_section.dart`

### Goals (`test/features/goals/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/goal_test.dart` | 13 | Goal construction (required fields, auto UUID, status defaults), factory methods (weekly with correct 7-day range, monthly with correct month end date), calculated properties (daysRemaining/daysElapsed/timeProgress for active goals), `isInProgress` (active goal in period, completed goal excluded, past goals), `hasEnded` detection, database serialization (`toDbMap`/`fromDbMap` round-trip with all fields including nullable completedAt), `copyWith` (status update with completedAt), enum values (GoalTimeframe 2 values, GoalStatus 4 values) |
| `models/goal_progress_test.dart` | 16 | GoalProgress calculation (absolute progress percent, gap to target), achievement detection (`isAchieved` true/false), status determination (completed/ahead/onTrack/behind/failed with time-based progress tracking), status messages for each state, projection (final average from current/previous, success prediction), endowed progress effect (baseline from previous period, progress from 3.0→3.5 toward 4.0 = 50%), progress clamping (max 1.5), ProgressStatus enum (5 values) |
| `repositories/goal_repository_test.dart` | 19 | **calculateProgress:** correct average for goal period, ignores days outside period, previous period baseline calculation, empty data handling. **suggestTarget:** 15% improvement, clamps to max 5.0, default 3.0 for empty data, custom improvement factor. **checkGoalCompletions:** marks achieved goals as completed (with completedAt timestamp), marks unachieved as failed, skips goals not yet ended. **calculateGoalStreak:** counts consecutive completions, breaks on gap >7 days, returns 0 for empty/no completed goals. **getCategoryStats:** per-category totals/completion/success rate, handles empty list |

**Sources:** `lib/features/goals/data/models/goal.dart`, `goal_progress.dart`, `lib/features/goals/data/repositories/goal_repository.dart`

### Habits (`test/features/habits/`)

| File | Tests | Covers |
|------|-------|--------|
| `data/models/habit_test.dart` | 13 | Habit construction (required fields, all fields, auto UUID), `toDbMap`/`fromDbMap` round-trip (all fields, archived flag as integer), `primaryKeyValue`, `copyWith` (updates fields, preserves unchanged), `isDueOnDay` (daily every day, weekdays Mon-Fri only, weekends Sat-Sun only, specificDays selected days only, timesPerWeek always due), HabitFrequency enum (5 values) |
| `data/models/habit_entry_test.dart` | 10 | HabitEntry construction (required fields with defaults, all fields), `dateKey` format (ISO date, zero-padded), `primaryKeyValue`, `toDbMap`/`fromDbMap` round-trip (all fields, boolean as integer), `copyWith` (updates fields, preserves unchanged), column schema (6 columns, id primary key) |
| `data/repositories/habits_repository_test.dart` | 16 | **getCurrentStreak:** empty entries, consecutive completed days, streak breaks on missing day, skips non-due days for weekday habits. **getBestStreak:** empty entries, best streak across history. **getCompletionRate:** empty entries, correct rate for daily habit. **getHabitStats:** default stats for empty entries, total completions count. **getGridData:** empty habits, 365 days of data, completion ratio calculation. **getTodayProgress:** no habits due (1.0), correct ratio, all completed (1.0) |

**Sources:** `lib/features/habits/data/models/habit.dart`, `habit_entry.dart`, `habit_frequency.dart`, `lib/features/habits/data/repositories/habits_repository.dart`

### Weekly Review (`test/features/weekly_review/`)

| File | Tests | Covers |
|------|-------|--------|
| `models/weekly_review_data_test.dart` | 24 | WeeklyReviewData construction (required fields, UUID auto-generation, defaults for optional fields), `primaryKeyValue` (returns id), `weekLabel` (formatted "CW XX / YYYY"), `toDbMap`/`fromDbMap` round-trip (all 16 columns, JSON-encoded fields), typed JSON accessors (`dailyScoresTyped`, `categoryAveragesTyped`, `permaAveragesTyped`, `topEmotionsTyped`, `contextSummaryTyped`, `moodTrendTyped`, `highlightsTyped`), `copyWith` (partial/full), `isoWeekNumber` (mid-year, early Jan, year boundary), `mondayOfWeek` (week 10, week 1, next-year week 1), schema validation (tableName, column count) |
| `repositories/weekly_review_repository_test.dart` | 19 | **generateReview:** week boundaries (Monday–Sunday), empty data (zero scores, 0 completedDays), average score calculation, date filtering (excludes out-of-range days), daily scores array (7-day with gaps), category averages from legacy DayRating, PERMA+ averages from EnhancedDayRating wellbeing, top emotions extraction (frequency-sorted, max 5), context summary (sleep avg, sleep quality, exercise days, stress level), mood trend from quickMood positions, highlights (favorite days + notes). **previousWeek:** returns Monday of last completed week |

**Sources:** `lib/features/weekly_review/data/models/weekly_review_data.dart`, `lib/features/weekly_review/data/repositories/weekly_review_repository.dart`

### Synchronization (`test/features/synchronization/`)

| File | Tests | Covers |
|------|-------|--------|
| `export_data_test.dart` | 22 | **ExportMetadata:** `toMap`/`fromMap`, `toJson`/`fromJson`, null handling. **ExportData.isNewFormat:** new format detection, legacy array, invalid JSON, missing keys. **Unencrypted parsing:** data as list, data as string, `fromJson`. **Encrypted:** decrypt with correct password, missing password, missing salt, wrong password. **Round-trips:** unencrypted, encrypted. **Attachments field (v1.1):** defaults to empty, round-trip with attachments, v1.1 format detection, backward compat (missing key → empty list), attachment data preserved through encrypt/decrypt |
| `file_db_provider_test.dart` | 8 | FileDbProvider `exportToString` (unencrypted JSON with metadata, encrypted base64, parseable back unencrypted/encrypted), file round-trip (`exportWithMetadata` + `import` unencrypted/encrypted), legacy format import, empty data export |
| `ics_converter_test.dart` | 12 | `noteToIcsEvent` (timed note, all-day, category), `createCalendar` (multiple/empty), `icsEventsToNotes` (known categories, unknown fallback, empty), ICS string round-trip (`calendarToString`/`stringToCalendar`, invalid string), multi-note round-trip |
| `ics_file_provider_test.dart` | 13 | **IcsExportMetadata:** `toMap`/`fromMap`, null handling, missing noteCount. **IcsFileProvider:** `exportToString` (unencrypted with ICS metadata, encrypted), `exportPlainIcs` (raw ICS without JSON wrapper), `importFromIcs` (wrapped unencrypted/encrypted, plain ICS, missing password error). **Round-trips:** unencrypted, encrypted. Empty data export |
| `json_serialization_test.dart` | 8 | DiaryDay list JSON round-trip (with ratings, empty, with notes), Note list JSON round-trip (timed, all-day), NoteTemplate list JSON round-trip (with sections), mixed data combined export, encryption readiness (UTF-8 encode/decode) |
| `pdf_export_test.dart` | 68 | **DateRange factories:** `lastWeek` (7-day), `lastMonth` (30-day), `currentMonth` (1st of month), `all` (empty/non-empty), `forMonth` (non-leap/leap Feb, Dec, Jan, 30-day month), `forWeek` (Monday-Sunday, week 1, week 52). **DateRange edge cases:** equality/inequality, hashCode, single date, duplicate dates, currentMonth bounds. **File naming:** CW format (week), YYMM (currentMonth), 30d range (month), YYMMDD-YYMMDD (custom/all), `forWeek`/`forMonth` exact format, no spaces/special chars, zero-padded week numbers, year boundary. **PDF generation:** valid header (%PDF), empty data, ratings-only, notes-only, single-day range, size bounds (1KB-5MB). **PDF content verification (text extraction):** username on cover, "Diary Report" title, "Summary"/"Report Period"/"Daily Breakdown" section headers, category names, note titles, score values. **PDF page structure:** minimum 3 pages, more pages with diary entries. **Large datasets:** 30/90/365 days valid PDF, PDF size scales with data. **Edge cases:** all-day notes ("All day" text), max scores (20/20), min scores (4/20), year boundary ranges, favorite days, empty title fallback to category, all 5 note categories, notes outside range excluded from top activities, custom theme colors, empty ratings (Score: 0), multiple notes per day. **Date range filtering precision:** inclusive boundaries, exclusion of out-of-range days, empty range produces valid PDF |
| `models/supabase_settings_test.dart` | 22 | SupabaseSettings construction (all fields, empty defaults, auto-sync defaults, full settings with auto-sync), `isConfigured` (true when all set, false for each empty field, false for empty factory), `lastAutoSyncDateTime` (null when no timestamp, valid ISO parse, null for invalid), `toMap`/`fromMap` (round-trip, auto-sync round-trip, snake_case keys, missing keys defaults, missing auto-sync keys defaults), `copyWith` (partial/full, auto-sync fields, no-args preserves all) |
| `models/sync_state_test.dart` | 14 | `SyncStatus` enum values (idle/syncing/success/error), `SyncPhase` enum values (16 phases incl. syncAttachments/uploadAttachmentFiles/downloadAttachments/downloadAttachmentFiles), `SyncState` construction (required fields, all fields), `message` getter (phase-based messages incl. attachment phases, error message, default failed), `copyWith` (preserves unchanged, updates all, no mutation), progress default, typical sync lifecycle, error state preserves progress, batch progress tracking |
| `zip_export_service_test.dart` | 20 | **createZipExport:** basic structure (manifest.json + images/), manifest contains metadata + data keys, image files present in archive, empty attachments (no images dir), missing local file skipped gracefully, encrypted manifest (base64 data field), attachment filePaths in manifest. **extractZipImport:** round-trip (diary days + notes + attachments preserved), images restored to target dir, encrypted round-trip, missing images dir handled, manifest-only ZIP. **isZipFile:** valid ZIP detected, non-ZIP rejected, empty file rejected. **Edge cases:** multiple notes with attachments, attachment noteId grouping in archive, large manifest handling |
| `supabase_batch_sync_test.dart` | 12 | **retryWithBackoff:** succeeds on first attempt, retries and succeeds on 2nd/3rd attempt, throws after max retries exceeded, custom max retries, correct return type, rethrows original exception type, delay increases between retries, maxRetries=1 means no retry. **SyncProgressCallback:** type definition. **Constants:** defaultBatchSize (50), defaultDelayBetweenBatches (100ms), defaultMaxRetries (3) |
| `supabase_integration_test.dart` | 11 (optional) | **Skipped when `test/.env` is missing.** Connection (initialize + sign in, wrong password, sign out), diary day sync round-trip, note sync round-trip (timed + all-day), template sync round-trip, full upload + download round-trip, error handling (uninitialized, unauthenticated sync/fetch) |

**Sources:** `lib/features/synchronization/data/models/export_data.dart`, `lib/features/synchronization/domain/providers/file_db_provider.dart`, `ics_file_provider.dart`, `lib/features/synchronization/data/repositories/ics_converter.dart`, `lib/features/synchronization/data/services/pdf_report_generator.dart`, `lib/features/synchronization/data/services/zip_export_service.dart`, `lib/features/synchronization/domain/providers/pdf_export_provider.dart`, `supabase_api.dart`, `supabase_provider.dart`

---

## Widget Tests

### Notes (`test/features/notes/presentation/pages/`)

| File | Tests | Covers |
|------|-------|--------|
| `note_editing_page_test.dart` | 9 | Form fields render (TextFormField, DropdownButtonFormField, Checkbox), title hint & description header (l10n), from/to date-time pickers with arrow icons, category dropdown opens and shows all categories, all-day checkbox toggle, save/reload buttons with `addAdditionalSaveButton`, AppBar save action & close button with `navigateBack`, pre-filled form when editing existing note, allDay checkbox label |

**Source:** `lib/features/notes/presentation/pages/note_editing_page.dart`

### Day Rating (`test/features/day_rating/presentation/`)

| File | Tests | Covers |
|------|-------|--------|
| `pages/diary_day_wizard_page_test.dart` | 6 | Shimmer loading placeholders on first frame, transition from loading to DiaryDayEditingWizardWidget, tab navigation bar with Calendar/Note Details/Day Rating labels, tab icons (calendar_today, edit_note, rate_review_outlined), SafeArea wrapping after load, tab navigation switches between views |
| `widgets/mood_quadrant_display_widget_test.dart` | 13 | **Normal display:** renders header icon + title, mood labels for all 7 states (Excited/Anxious/Calm/Sad/Neutral/Pleasant/Unpleasant) based on valence/arousal. **Compact display:** no header/label in compact mode, custom compact size. **quadrantColor helper:** returns correct semantic color for all 4 MoodQuadrant values (orange/green/red/blueGrey) |

**Sources:** `lib/features/day_rating/presentation/pages/diary_day_wizard_page.dart`, `lib/features/day_rating/presentation/widgets/mood_quadrant_display_widget.dart`

### Dashboard (`test/features/dashboard/presentation/pages/`)

| File | Tests | Covers |
|------|-------|--------|
| `new_dashboard_page_test.dart` | 6 | Scaffold with FloatingActionButton, FAB "New Entry" label with add icon, RefreshIndicator for pull-to-refresh, mobile layout on narrow screen (SliverToBoxAdapters), rendering with custom DashboardStats, responsive LayoutBuilder |

**Source:** `lib/features/dashboard/presentation/pages/new_dashboard_page.dart`

### App (`test/features/app/presentation/pages/`)

| File | Tests | Covers |
|------|-------|--------|
| `settings_page_test.dart` | 6 | Settings title rendering, top settings sections (ThemeSettingsWidget, LanguageSettingsWidget), all 6 settings sections visible on tall surface (Theme, Language, Notification, Biometric, Backup, Supabase), category management section with "Manage Categories" text and chevron icon, SettingsSection components, CustomScrollView scrollability |

**Source:** `lib/features/app/presentation/pages/settings_page.dart`

### Test Helpers (`test/helpers/`)

| File | Purpose |
|------|---------|
| `widget_test_helpers.dart` | Shared test harness: `TestDbRepository` (skips SQLite), `TestCategoryProvider`, `TestAttachmentProvider`, `TestNoteTemplateProvider`, `createTestOverrides()` (overrides all DB-backed providers), `createTestApp()` (MaterialApp + l10n + ProviderScope) |

---

## Localization (`test/l10n/`)

| File | Tests | Covers |
|------|-------|--------|
| `arb_validity_test.dart` | 6 | ARB JSON syntax validation (English + German), placeholder consistency (messages match metadata definitions), value type checks (all non-metadata are strings), ICU message format validation, unclosed placeholder detection |
| `arb_completeness_test.dart` | 6 | Translation completeness: all English keys exist in German, no extra German keys, no empty string values, orphaned metadata detection, key count parity between locales, locale marker correctness |

**Sources:** `lib/l10n/app_en.arb`, `lib/l10n/app_de.arb`

---

## Integration Tests (`test/integration/`)

Workflow-level tests that verify multi-feature provider interactions using `ProviderContainer` and `TestDbRepository`.

### Diary Entry Workflow (`test/integration/diary_entry_workflow_test.dart`)

| File | Tests | Covers |
|------|-------|--------|
| `diary_entry_workflow_test.dart` | 9 | **Provider chain:** DayRatingsNotifier updates, DiaryDay construction + save, `diaryDayFullDataProvider` note association, `isDiaryOfDayCompleteProvider` (complete/empty). **Wizard providers:** `wizardDayNotesProvider` date filtering, dynamic note addition, `createEmptyNoteProvider` defaults. **Enhanced rating:** resets on date change |

**Sources:** `lib/features/day_rating/domain/providers/diary_wizard_providers.dart`, `diary_day_local_db_provider.dart`

### Note Search Workflow (`test/integration/note_search_workflow_test.dart`)

| File | Tests | Covers |
|------|-------|--------|
| `note_search_workflow_test.dart` | 9 | **Full provider chain:** notes appear in `filteredNotesProvider`, text search filters in real-time, category filter, combined category+text search, date range filter, `clearAll` resets, adding note while filter active updates results, deleting note updates results, favorites filter |

**Sources:** `lib/features/notes/domain/providers/note_local_db_provider.dart`, `note_search_provider.dart`

### Settings Persistence Workflow (`test/integration/settings_persistence_workflow_test.dart`)

| File | Tests | Covers |
|------|-------|--------|
| `settings_persistence_workflow_test.dart` | 7 | **Cross-provider persistence:** theme seed color survives `ThemeProvider` recreation, dark mode toggle + restore, default seed color, locale auto-persists to `settingsContainer`, locale survives recreation, combined theme+locale+dark mode workflow, independent user settings, ThemeProvider vs LocaleProvider persistence asymmetry |

**Sources:** `lib/core/provider/theme_provider.dart`, `locale_provider.dart`, `lib/core/settings/settings_container.dart`

### Export/Import Workflow (`test/integration/export_import_workflow_test.dart`)

| File | Tests | Covers |
|------|-------|--------|
| `export_import_workflow_test.dart` | 10 | **Data round-trip with notes:** diary days with embedded notes, multiple days with mixed content, file-based round-trip, encrypted round-trip preserves notes, import populates provider state. **Cross-feature integrity:** note categories preserved, all 4 DayRating types, EnhancedDayRating (PERMA+), empty data, large dataset (30 days) |

**Sources:** `lib/features/synchronization/domain/providers/file_db_provider.dart`, `lib/features/synchronization/data/models/export_data.dart`

---

## Coverage Summary by Area

| Area | Status | Notes |
|------|--------|-------|
| Password hashing & verification | Covered | PBKDF2, salt, key derivation |
| Database schema (DbColumn) | Covered | SQL generation, column types, CREATE TABLE |
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
| Note attachments | Covered | Model serialization, round-trips, copyWith, remoteUrl field, backward compat |
| ZIP export/import | Covered | Archive creation/extraction, manifest structure, image bundling, encryption, isZipFile detection, round-trips |
| Wizard scheduling logic | Covered | Time slots, gaps, 15-min chunks, day coverage |
| Category management | Covered | Name validation, lookup, defaults |
| Goals & progress tracking | Covered | Goal models, progress calculation, streaks, repository logic |
| Habits & habit entries | Covered | Models, frequency scheduling, streaks, completion rates, grid data |
| Localization (ARB) | Covered | JSON validity, completeness, placeholders, ICU format |
| Supabase settings | Covered | Model serialization, auto-sync fields, isConfigured, lastAutoSyncDateTime |
| Supabase auto-sync service | Covered | resetDebounce |
| Biometric settings | Covered | Settings model serialization, defaults, backwards compat |
| Backup settings & metadata | Covered | Settings model, metadata model, overdue detection, frequency enum |
| Supabase sync state | Covered | SyncStatus/SyncPhase enums (16 phases incl. attachment sync), SyncState construction/copyWith, phase-based messages, batch progress |
| Supabase batch sync & retry | Covered | retryWithBackoff (success/retry/failure/types/delay), SyncProgressCallback, batch constants |
| Supabase API (optional) | Covered | Requires `test/.env` with credentials; skipped otherwise |
| Onboarding status & service | Covered | SharedPreferences persistence, all lifecycle states, demo mode flag |
| Smart reminder algorithm | Covered | shouldSendReminder (all conditions), calculateIntensity, isInQuietHours (midnight-crossing, same-day, boundaries) |
| Diary status service | Covered | SharedPreferences-based entry tracking, reminder counter with day-reset |
| Weekly review status service | Covered | SharedPreferences-based due/shown tracking, mark/clear lifecycle, partial data handling |
| Widget: NoteEditingPage | Covered | Form fields, category dropdown, checkbox toggle, save actions, editing pre-fill |
| Widget: DiaryDayWizardPage | Covered | Loading shimmer, tab navigation, tab icons, SafeArea, view switching |
| Dashboard granular providers | Covered | currentStreakProvider, todayLoggedProvider, weekAverageProvider: value extraction, default before load, selective rebuild |
| Widget: NewDashboardPage | Covered | FAB, RefreshIndicator, responsive layout, custom stats rendering |
| Widget: SettingsPage | Covered | Settings title, all 6 settings sections, category management, scrollability |
| Widget: MoodQuadrantDisplayWidget | Covered | Normal/compact display modes, all 7 mood labels, quadrantColor helper |
| Integration: Diary entry workflow | Covered | Provider chain + wizard providers + enhanced rating reset |
| Integration: Note search workflow | Covered | Full filteredNotesProvider chain with CRUD + filters |
| Integration: Settings persistence | Covered | Cross-provider state + restart simulation |
| Weekly review data model | Covered | Construction, serialization, JSON accessors, ISO week calculation, schema |
| Weekly review repository | Covered | Review generation, aggregations (scores, PERMA+, emotions, context, mood, highlights) |
| Integration: Export/import round-trip | Covered | Notes in diary days, encryption, large datasets |

### Not covered

| Area | Reason |
|------|--------|
| SQLite database operations (LocalDbHelper) | Requires real SQLite database |
| File picker / permission handler | Platform-specific, requires device |

---

## Bugs Found by Tests

1. **DayRating Firestore format inconsistency:** `toFirestoreMap()` stores `integerValue` as `int`, but `fromFirestoreMap()` calls `int.parse()` expecting a `String` (standard Firestore REST API format). Documented in `day_rating_test.dart`.
