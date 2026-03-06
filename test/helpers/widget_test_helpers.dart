import 'package:day_tracker/core/database/db_entity.dart';
import 'package:day_tracker/core/database/db_repository.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/settings/settings_provider.dart';
import 'package:day_tracker/features/dashboard/data/models/dashboard_stats.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:day_tracker/features/dashboard/domain/providers/insights_provider.dart';
import 'package:day_tracker/features/dashboard/domain/providers/week_overview_provider.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/favorite_diary_days_provider.dart';
import 'package:day_tracker/features/goals/data/models/goal.dart';
import 'package:day_tracker/features/goals/data/models/goal_progress.dart';
import 'package:day_tracker/features/goals/domain/providers/goal_providers.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';
import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/favorite_notes_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_attachments_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Settings Container Setup ─────────────────────────────────────────────────

/// Initialize the global settingsContainer with test-safe defaults.
void initTestSettingsContainer() {
  // dotenv must be loaded before SettingsContainer is constructed,
  // because its constructor reads dotenv.env['PROJECT_NAME'].
  dotenv.testLoad(fileInput: "PROJECT_NAME=day_tracker");
  // ignore: deprecated_member_use
  settingsContainer = SettingsContainer();
  // Set a valid path so DbRepository constructors don't break
  // ignore: deprecated_member_use
  settingsContainer.applicationDocumentsPath = '/tmp/test_diary';
}

// ── Test DbRepository (skips all SQLite access) ──────────────────────────────

/// A DbRepository subclass that skips all database I/O.
/// Dart dispatches `initDatabase()` to this override even during
/// the super-constructor call, so no filesystem or sqflite access occurs.
class TestDbRepository<T extends DbEntity> extends DbRepository<T> {
  TestDbRepository({
    required super.tableName,
    required super.columns,
    required super.fromMap,
    super.migrations,
    super.applicationDocumentsPath = '/tmp/test_diary',
    List<T>? initialData,
  }) {
    if (initialData != null) state = initialData;
  }

  @override
  Future<void> initDatabase() async {}

  @override
  Future<void> readObjectsFromDatabase() async {}

  @override
  Future<void> addElement(T element) async {
    final exists =
        state.any((cur) => cur.primaryKeyValue == element.primaryKeyValue);
    if (exists) return;
    state = [...state, element];
  }

  @override
  Future<void> addOrUpdateElement(T element) async {
    final existsInState =
        state.any((cur) => cur.primaryKeyValue == element.primaryKeyValue);
    if (existsInState) {
      state = state
          .map((cur) =>
              cur.primaryKeyValue == element.primaryKeyValue ? element : cur)
          .toList();
    } else {
      state = [...state, element];
    }
  }

  @override
  Future<void> editElement(T newElement, T oldElement) async {
    state = state
        .map((cur) =>
            cur.primaryKeyValue == oldElement.primaryKeyValue ? newElement : cur)
        .toList();
  }

  @override
  Future<void> deleteElement(T element) async {
    state = state
        .where((cur) => cur.primaryKeyValue != element.primaryKeyValue)
        .toList();
  }
}

/// Test-safe CategoryLocalDataProvider (skips SQLite).
class TestCategoryProvider extends CategoryLocalDataProvider {
  final List<NoteCategory> _initialCategories;

  TestCategoryProvider([List<NoteCategory>? initial])
      // ignore: deprecated_member_use
      : _initialCategories = initial ?? [], super(settingsContainer) {
    state = _initialCategories;
  }

  @override
  Future<void> initDatabase() async {}

  @override
  Future<void> readObjectsFromDatabase() async {
    state = _initialCategories;
  }

  @override
  Future<void> addElement(NoteCategory element) async {
    state = [...state, element];
  }

  @override
  Future<void> editElement(
      NoteCategory newElement, NoteCategory oldElement) async {
    state = state
        .map((cur) => cur.primaryKeyValue == oldElement.primaryKeyValue
            ? newElement
            : cur)
        .toList();
  }

  @override
  Future<void> deleteElement(NoteCategory element) async {
    state = state
        .where((cur) => cur.primaryKeyValue != element.primaryKeyValue)
        .toList();
  }
}

/// Test-safe NoteAttachmentsProvider (skips SQLite + image storage).
class TestAttachmentProvider extends NoteAttachmentsProvider {
  TestAttachmentProvider() : super(applicationDocumentsPath: '/tmp/test_diary');

  @override
  Future<void> initDatabase() async {}

  @override
  Future<void> readObjectsFromDatabase() async {}

  @override
  Future<void> addElement(NoteAttachment element) async {
    state = [...state, element];
  }

  @override
  Future<void> deleteElement(NoteAttachment element) async {
    state = state
        .where((cur) => cur.primaryKeyValue != element.primaryKeyValue)
        .toList();
  }
}

/// Test-safe NoteTemplateLocalDataProvider (skips SQLite).
class TestNoteTemplateProvider extends NoteTemplateLocalDataProvider {
  TestNoteTemplateProvider() : super(applicationDocumentsPath: '/tmp/test_diary');

  @override
  Future<void> initDatabase() async {}

  @override
  Future<void> readObjectsFromDatabase() async {}

  @override
  Future<void> addElement(NoteTemplate element) async {
    state = [...state, element];
  }

  @override
  Future<void> deleteElement(NoteTemplate element) async {
    state = state
        .where((cur) => cur.primaryKeyValue != element.primaryKeyValue)
        .toList();
  }
}

// ── Test Data Fixtures ───────────────────────────────────────────────────────

List<NoteCategory> get testCategories => [
      NoteCategory(title: 'Work', color: Colors.purple),
      NoteCategory(title: 'Leisure', color: Colors.lightBlue),
      NoteCategory(title: 'Food', color: Colors.amber),
    ];

DashboardStats get testDashboardStats => DashboardStats(
      currentStreak: 3,
      todayLogged: true,
      weekStats: WeekStats(
        averageScore: 14.5,
        completedDays: 5,
        categoryAverages: {'Work': 3.5, 'Leisure': 4.0},
        dailyScores: [],
      ),
      monthlyTrend: {'Week 1': 12.0, 'Week 2': 14.0},
      topActivities: ['Work', 'Food'],
      insights: [
        Insight(
          type: InsightType.milestone,
          title: 'Great streak!',
          description: 'You have logged 3 days in a row.',
          icon: '🔥',
        ),
      ],
    );

// ── Provider Overrides ───────────────────────────────────────────────────────

/// Creates a standard set of provider overrides suitable for most widget tests.
List<Override> createTestOverrides({
  List<NoteCategory>? categories,
  List<Note>? notes,
  List<DiaryDay>? diaryDays,
  DashboardStats? dashboardStats,
  List<Override> additionalOverrides = const [],
}) {
  final cats = categories ?? testCategories;
  final stats = dashboardStats ?? testDashboardStats;

  return [
    // Settings provider (must be first — other providers read from it)
    // ignore: deprecated_member_use
    settingsProvider.overrideWithValue(settingsContainer),

    // Core providers
    categoryLocalDataProvider.overrideWith((_) => TestCategoryProvider(cats)),
    notesLocalDataProvider.overrideWith(
      (_) => TestDbRepository<Note>(
        tableName: Note.tableName,
        columns: Note.columns,
        fromMap: Note.fromDbMap,
        initialData: notes ?? [],
      ),
    ),
    noteAttachmentsProvider.overrideWith((_) => TestAttachmentProvider()),
    noteEditingPageProvider
        .overrideWith((_) => NoteEditingPageProvider()),
    noteTemplateLocalDataProvider
        .overrideWith((_) => TestNoteTemplateProvider()),

    // Diary day providers
    diaryDayLocalDbDataProvider.overrideWith(
      (_) => TestDbRepository<DiaryDay>(
        tableName: DiaryDay.tableName,
        columns: DiaryDay.columns,
        fromMap: DiaryDay.fromDbMap,
        initialData: diaryDays ?? [],
      ),
    ),

    // Dashboard providers
    dashboardStatsProvider.overrideWith((_) async => stats),
    currentStreakProvider.overrideWith((_) => stats.currentStreak),
    todayLoggedProvider.overrideWith((_) => stats.todayLogged),
    weekAverageProvider.overrideWith((_) => stats.weekStats.averageScore),
    insightsProvider.overrideWith((_) async => stats.insights),
    weekOverviewProvider.overrideWith((_) async => stats.weekStats),

    // Goals providers
    goalsLocalDbDataProvider.overrideWith(
      (_) => TestDbRepository<Goal>(
        tableName: Goal.tableName,
        columns: Goal.columns,
        fromMap: Goal.fromDbMap,
      ),
    ),
    activeGoalsWithProgressProvider.overrideWith((_) => <GoalProgress>[]),
    goalStreakProvider.overrideWith((_) => 0),

    // Habits providers
    habitsLocalDbDataProvider.overrideWith(
      (_) => TestDbRepository<Habit>(
        tableName: Habit.tableName,
        columns: Habit.columns,
        fromMap: Habit.fromDbMap,
      ),
    ),
    habitEntriesLocalDbDataProvider.overrideWith(
      (_) => TestDbRepository<HabitEntry>(
        tableName: HabitEntry.tableName,
        columns: HabitEntry.columns,
        fromMap: HabitEntry.fromDbMap,
      ),
    ),
    activeHabitsProvider.overrideWith((_) => <Habit>[]),
    todayHabitsProvider.overrideWith((_) => <Habit>[]),
    todayEntriesProvider.overrideWith((_) => <HabitEntry>[]),
    todayProgressProvider.overrideWith((_) => 0.0),

    // Favorites providers
    favoriteDiaryDaysProvider.overrideWith((_) => <DiaryDay>[]),
    favoriteNotesProvider.overrideWith((_) => <Note>[]),

    ...additionalOverrides,
  ];
}

// ── Test Widget Wrapper ──────────────────────────────────────────────────────

/// Wraps a widget in MaterialApp with localizations and ProviderScope.
Widget createTestApp(
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
