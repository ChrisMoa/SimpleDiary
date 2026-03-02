import 'dart:io';

import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

typedef SyncProgressCallback = void Function(int completedItems, int totalItems);

class SupabaseApi {
  static SupabaseClient? _client;
  static bool _initialized = false;

  final String _tablePrefix;

  static const int defaultBatchSize = 50;
  static const Duration defaultDelayBetweenBatches = Duration(milliseconds: 100);
  static const int defaultMaxRetries = 3;

  SupabaseApi({String tablePrefix = ''}) : _tablePrefix = tablePrefix;

  String get _diaryDaysTable => '${_tablePrefix}diary_days';
  String get _notesTable => '${_tablePrefix}notes';
  String get _noteTemplatesTable => '${_tablePrefix}note_templates';

  // Initialize Supabase client
  Future<void> initialize(String url, String anonKey) async {
    try {
      if (!_initialized) {
        LogWrapper.logger.i('Initializing Supabase with URL: $url');
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        _client = Supabase.instance.client;
        _initialized = true;
        LogWrapper.logger.i('Supabase initialized successfully');
      } else {
        _client = Supabase.instance.client;
        LogWrapper.logger.d('Supabase already initialized, reusing instance');
      }
    } catch (e) {
      LogWrapper.logger.e('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  // Authenticate user
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      if (_client == null) {
        LogWrapper.logger.e('Supabase client not initialized');
        throw Exception('Supabase client not initialized');
      }

      LogWrapper.logger.d('Attempting to sign in with email: $email');
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        LogWrapper.logger.i('Successfully signed in to Supabase');
        LogWrapper.logger.d('Auth user ID: ${response.user!.id}');
        return true;
      }
      LogWrapper.logger.w('Sign in failed: No user returned');
      return false;
    } catch (e) {
      LogWrapper.logger.e('Supabase sign in failed: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (_client == null) {
        LogWrapper.logger.e('Supabase client not initialized');
        throw Exception('Supabase client not initialized');
      }

      LogWrapper.logger.d('Signing out from Supabase');
      await _client!.auth.signOut();
      LogWrapper.logger.i('Successfully signed out from Supabase');
    } catch (e) {
      LogWrapper.logger.e('Supabase sign out failed: $e');
      rethrow;
    }
  }

  String? _getAuthenticatedUserId() {
    if (_client == null) {
      LogWrapper.logger.e('Supabase client not initialized');
      throw Exception('Supabase client not initialized');
    }
    final supabaseUserId = _client!.auth.currentUser?.id;
    if (supabaseUserId == null) {
      LogWrapper.logger.e('User not authenticated');
      throw Exception('User not authenticated');
    }
    return supabaseUserId;
  }

  // Sync diary days to Supabase
  Future<void> syncDiaryDays(
    List<DiaryDay> diaryDays,
    String localUserId, {
    SyncProgressCallback? onProgress,
  }) async {
    try {
      final supabaseUserId = _getAuthenticatedUserId()!;

      LogWrapper.logger.i('Syncing ${diaryDays.length} diary days for user: $supabaseUserId');

      final allData = diaryDays.map((diaryDay) => <String, dynamic>{
        'id': '${supabaseUserId}_${diaryDay.primaryKeyValue}',
        'user_id': supabaseUserId,
        'day': diaryDay.day.toIso8601String().split('T')[0],
        'ratings': diaryDay.ratings.map((r) => r.toMap()).toList(),
        'notes': diaryDay.notes.map((note) => note.toMap()).toList(),
      }).toList();

      await _syncInBatches(
        table: _diaryDaysTable,
        data: allData,
        entityName: 'diary days',
        onProgress: onProgress,
      );

      LogWrapper.logger.i('Successfully synced ${diaryDays.length} diary days');
    } catch (e) {
      LogWrapper.logger.e('Failed to sync diary days: $e');
      rethrow;
    }
  }

  // Sync notes to Supabase
  Future<void> syncNotes(
    List<Note> notes,
    String localUserId, {
    SyncProgressCallback? onProgress,
  }) async {
    try {
      final supabaseUserId = _getAuthenticatedUserId()!;

      LogWrapper.logger.i('Syncing ${notes.length} notes for user: $supabaseUserId');

      final allData = notes.map((note) => <String, dynamic>{
        'id': note.id,
        'user_id': supabaseUserId,
        'title': note.title,
        'description': note.description,
        'from': note.from.toIso8601String(),
        'to': note.to.toIso8601String(),
        'is_all_day': note.isAllDay ? 1 : 0,
        'note_category': note.noteCategory.title,
      }).toList();

      await _syncInBatches(
        table: _notesTable,
        data: allData,
        entityName: 'notes',
        onProgress: onProgress,
      );

      LogWrapper.logger.i('Successfully synced ${notes.length} notes');
    } catch (e) {
      LogWrapper.logger.e('Failed to sync notes: $e');
      rethrow;
    }
  }

  // Sync templates to Supabase
  Future<void> syncTemplates(
    List<NoteTemplate> templates,
    String localUserId, {
    SyncProgressCallback? onProgress,
  }) async {
    try {
      final supabaseUserId = _getAuthenticatedUserId()!;

      LogWrapper.logger.i('Syncing ${templates.length} templates for user: $supabaseUserId');

      final allData = templates.map((template) => <String, dynamic>{
        'id': template.id,
        'user_id': supabaseUserId,
        'title': template.title,
        'description': template.description,
        'duration_minutes': template.durationMinutes,
        'note_category': template.noteCategory.title,
        'description_sections': DescriptionSection.encode(template.descriptionSections),
      }).toList();

      await _syncInBatches(
        table: _noteTemplatesTable,
        data: allData,
        entityName: 'templates',
        onProgress: onProgress,
      );

      LogWrapper.logger.i('Successfully synced ${templates.length} templates');
    } catch (e) {
      LogWrapper.logger.e('Failed to sync templates: $e');
      rethrow;
    }
  }

  Future<void> _syncInBatches({
    required String table,
    required List<Map<String, dynamic>> data,
    required String entityName,
    SyncProgressCallback? onProgress,
  }) async {
    if (data.isEmpty) {
      onProgress?.call(0, 0);
      return;
    }

    final totalItems = data.length;
    final totalBatches = (totalItems + defaultBatchSize - 1) ~/ defaultBatchSize;

    LogWrapper.logger.d('Syncing $totalItems $entityName in $totalBatches batch(es)');

    for (var i = 0; i < totalItems; i += defaultBatchSize) {
      final batchEnd = (i + defaultBatchSize).clamp(0, totalItems);
      final batch = data.sublist(i, batchEnd);
      final batchNumber = (i ~/ defaultBatchSize) + 1;

      LogWrapper.logger.d('Upserting $entityName batch $batchNumber/$totalBatches (${batch.length} items)');

      await _retryWithBackoff(
        () => _client!.from(table).upsert(batch),
      );

      onProgress?.call(batchEnd, totalItems);

      if (batchEnd < totalItems) {
        await Future.delayed(defaultDelayBetweenBatches);
      }
    }
  }

  @visibleForTesting
  Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = defaultMaxRetries,
  }) => _retryWithBackoff(operation, maxRetries: maxRetries);

  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = defaultMaxRetries,
  }) async {
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries - 1) rethrow;
        final delay = Duration(milliseconds: 200 * (attempt + 1));
        LogWrapper.logger.w('Retry ${attempt + 1}/$maxRetries after ${delay.inMilliseconds}ms: $e');
        await Future.delayed(delay);
      }
    }
    throw StateError('Unreachable');
  }

  // Fetch diary days from Supabase
  Future<List<DiaryDay>> fetchDiaryDays(String localUserId) async {
    try {
      final supabaseUserId = _getAuthenticatedUserId()!;

      LogWrapper.logger.d('Fetching diary days for user: $supabaseUserId');
      final List<Map<String, dynamic>> response = await _client!
          .from(_diaryDaysTable)
          .select()
          .eq('user_id', supabaseUserId);

      LogWrapper.logger.d('Supabase response type: ${response.runtimeType}');

      if (response.isEmpty) {
        LogWrapper.logger.w('No data received from Supabase');
        return <DiaryDay>[];
      }

      LogWrapper.logger.i('Received ${response.length} diary days from Supabase');

      final diaryDays = <DiaryDay>[];
      for (var i = 0; i < response.length; i++) {
        try {
          final data = response[i];
          LogWrapper.logger.d('Processing diary day ${i + 1}/${response.length}: ${data['id']}');

          // Parse the day string back to DateTime
          final dayStr = data['day'] as String;
          final day = DateTime.parse(dayStr);

          // Parse ratings
          final ratingsData = data['ratings'] as List;
          LogWrapper.logger.d('Diary day has ${ratingsData.length} ratings');
          final ratings = ratingsData.map((r) => DayRating.fromMap(r as Map<String, dynamic>)).toList();

          // Parse notes
          final notesData = data['notes'] as List? ?? [];
          LogWrapper.logger.d('Diary day has ${notesData.length} notes');
          final notes = notesData.map((n) {
            try {
              return Note.fromMap(n as Map<String, dynamic>);
            } catch (e) {
              LogWrapper.logger.e('Failed to parse note: $e, data: $n');
              rethrow;
            }
          }).toList();

          // Create diary day
          final diaryDay = DiaryDay(day: day, ratings: ratings);
          diaryDay.notes = notes;
          diaryDays.add(diaryDay);

          LogWrapper.logger.d('Successfully processed diary day ${i + 1}/${response.length}');
        } catch (e) {
          LogWrapper.logger.e('Failed to process diary day ${i + 1}/${response.length}: $e');
          rethrow;
        }
      }

      LogWrapper.logger.i('Successfully fetched ${diaryDays.length} diary days');
      return diaryDays;
    } catch (e) {
      LogWrapper.logger.e('Failed to fetch diary days: $e');
      rethrow;
    }
  }

  // Fetch notes from Supabase
  Future<List<Note>> fetchNotes(String localUserId) async {
    try {
      final supabaseUserId = _getAuthenticatedUserId()!;

      LogWrapper.logger.d('Fetching notes for user: $supabaseUserId');
      final List<Map<String, dynamic>> response = await _client!
          .from(_notesTable)
          .select()
          .eq('user_id', supabaseUserId);

      LogWrapper.logger.d('Supabase response type: ${response.runtimeType}');

      if (response.isEmpty) {
        LogWrapper.logger.w('No data received from Supabase');
        return <Note>[];
      }

      LogWrapper.logger.i('Received ${response.length} notes from Supabase');

      final notes = <Note>[];
      for (var i = 0; i < response.length; i++) {
        try {
          final data = response[i];
          LogWrapper.logger.d('Processing note ${i + 1}/${response.length}: ${data['id']}');

          // Convert from Supabase format (ISO 8601) to Note model format
          // Supabase returns ISO format: 2025-10-19T07:00:00.000
          // Need to parse and convert to the app's format
          final fromDateTime = DateTime.parse(data['from']);
          final toDateTime = DateTime.parse(data['to']);

          final noteData = <String, dynamic>{
            'id': data['id'],
            'title': data['title'],
            'description': data['description'],
            'from': Utils.toDateTime(fromDateTime),  // Convert ISO to app format
            'to': Utils.toDateTime(toDateTime),      // Convert ISO to app format
            'isAllDay': data['is_all_day'] == 1,
            'noteCategory': data['note_category'],
          };

          notes.add(Note.fromMap(noteData));
          LogWrapper.logger.d('Successfully processed note ${i + 1}/${response.length}');
        } catch (e) {
          LogWrapper.logger.e('Failed to process note ${i + 1}/${response.length}: $e');
          rethrow;
        }
      }

      LogWrapper.logger.i('Successfully fetched ${notes.length} notes');
      return notes;
    } catch (e) {
      LogWrapper.logger.e('Failed to fetch notes: $e');
      rethrow;
    }
  }

  // Fetch templates from Supabase
  Future<List<NoteTemplate>> fetchTemplates(String localUserId) async {
    try {
      final supabaseUserId = _getAuthenticatedUserId()!;

      LogWrapper.logger.d('Fetching templates for user: $supabaseUserId');
      final List<Map<String, dynamic>> response = await _client!
          .from(_noteTemplatesTable)
          .select()
          .eq('user_id', supabaseUserId);

      LogWrapper.logger.d('Supabase response type: ${response.runtimeType}');

      if (response.isEmpty) {
        LogWrapper.logger.w('No data received from Supabase');
        return <NoteTemplate>[];
      }

      LogWrapper.logger.i('Received ${response.length} templates from Supabase');

      final templates = <NoteTemplate>[];
      for (var i = 0; i < response.length; i++) {
        try {
          final data = response[i];
          LogWrapper.logger.d('Processing template ${i + 1}/${response.length}: ${data['id']}');

          // Convert from Supabase format to Template model format
          final templateData = <String, dynamic>{
            'id': data['id'],
            'title': data['title'],
            'description': data['description'],
            'durationMinutes': data['duration_minutes'],
            'noteCategory': data['note_category'],
            'descriptionSections': data['description_sections'] ?? '',
          };

          templates.add(NoteTemplate.fromMap(templateData));
          LogWrapper.logger.d('Successfully processed template ${i + 1}/${response.length}');
        } catch (e) {
          LogWrapper.logger.e('Failed to process template ${i + 1}/${response.length}: $e');
          rethrow;
        }
      }

      LogWrapper.logger.i('Successfully fetched ${templates.length} templates');
      return templates;
    } catch (e) {
      LogWrapper.logger.e('Failed to fetch templates: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _client?.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _client?.auth.currentUser != null;

  // Add method to reset initialization (useful for testing)
  static void resetInitialization() {
    _initialized = false;
    _client = null;
  }
}
