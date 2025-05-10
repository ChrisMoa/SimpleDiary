import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApi {
  static SupabaseClient? _client;
  static bool _initialized = false;

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

  // Sync diary days to Supabase
  Future<void> syncDiaryDays(List<DiaryDay> diaryDays, String localUserId) async {
    try {
      if (_client == null) {
        LogWrapper.logger.e('Supabase client not initialized');
        throw Exception('Supabase client not initialized');
      }

      // Get the authenticated user's ID from Supabase
      final supabaseUserId = _client!.auth.currentUser?.id;
      if (supabaseUserId == null) {
        LogWrapper.logger.e('User not authenticated');
        throw Exception('User not authenticated');
      }

      LogWrapper.logger.i('Syncing ${diaryDays.length} diary days for user: $supabaseUserId');
      for (var diaryDay in diaryDays) {
        final data = {
          'id': '${supabaseUserId}_${diaryDay.getId()}',
          'user_id': supabaseUserId,
          'day': diaryDay.day.toIso8601String().split('T')[0],
          'ratings': diaryDay.ratings.map((r) => r.toMap()).toList(),
          'notes': diaryDay.notes.map((note) => note.toMap()).toList(),
        };

        LogWrapper.logger.d('Upserting diary day: ${data['id']}');
        await _client!.from('diary_days').upsert(data);
      }
      LogWrapper.logger.i('Successfully synced ${diaryDays.length} diary days');
    } catch (e) {
      LogWrapper.logger.e('Failed to sync diary days: $e');
      rethrow;
    }
  }

  // Sync notes to Supabase
  Future<void> syncNotes(List<Note> notes, String localUserId) async {
    try {
      if (_client == null) {
        LogWrapper.logger.e('Supabase client not initialized');
        throw Exception('Supabase client not initialized');
      }

      // Get the authenticated user's ID from Supabase
      final supabaseUserId = _client!.auth.currentUser?.id;
      if (supabaseUserId == null) {
        LogWrapper.logger.e('User not authenticated');
        throw Exception('User not authenticated');
      }

      LogWrapper.logger.i('Syncing ${notes.length} notes for user: $supabaseUserId');
      for (var note in notes) {
        final data = <String, dynamic>{
          'id': note.id,
          'user_id': supabaseUserId,
          'title': note.title,
          'description': note.description,
          'from': note.from.toIso8601String(),
          'to': note.to.toIso8601String(),
          'is_all_day': note.isAllDay ? 1 : 0,
          'note_category': note.noteCategory.title,
        };

        LogWrapper.logger.d('Upserting note: ${data['id']}');
        await _client!.from('notes').upsert(data);
      }
      LogWrapper.logger.i('Successfully synced ${notes.length} notes');
    } catch (e) {
      LogWrapper.logger.e('Failed to sync notes: $e');
      rethrow;
    }
  }

  // Fetch diary days from Supabase
  Future<List<DiaryDay>> fetchDiaryDays(String localUserId) async {
    try {
      if (_client == null) {
        LogWrapper.logger.e('Supabase client not initialized');
        throw Exception('Supabase client not initialized');
      }

      // Get the authenticated user's ID from Supabase
      final supabaseUserId = _client!.auth.currentUser?.id;
      if (supabaseUserId == null) {
        LogWrapper.logger.e('User not authenticated');
        throw Exception('User not authenticated');
      }

      LogWrapper.logger.d('Fetching diary days for user: $supabaseUserId');
      final response = await _client!.from('diary_days').select().eq('user_id', supabaseUserId);

      final diaryDays = <DiaryDay>[];
      for (var data in response) {
        // Parse the day string back to DateTime
        final dayStr = data['day'] as String;
        final day = DateTime.parse(dayStr);

        // Parse ratings
        final ratingsData = data['ratings'] as List;
        final ratings = ratingsData.map((r) => DayRating.fromMap(r)).toList();

        // Parse notes
        final notesData = data['notes'] as List? ?? [];
        final notes = notesData.map((n) => Note.fromMap(n)).toList();

        // Create diary day
        final diaryDay = DiaryDay(day: day, ratings: ratings);
        diaryDay.notes = notes;
        diaryDays.add(diaryDay);
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
      if (_client == null) {
        LogWrapper.logger.e('Supabase client not initialized');
        throw Exception('Supabase client not initialized');
      }

      // Get the authenticated user's ID from Supabase
      final supabaseUserId = _client!.auth.currentUser?.id;
      if (supabaseUserId == null) {
        LogWrapper.logger.e('User not authenticated');
        throw Exception('User not authenticated');
      }

      LogWrapper.logger.d('Fetching notes for user: $supabaseUserId');
      final response = await _client!.from('notes').select().eq('user_id', supabaseUserId);

      final notes = <Note>[];
      for (var data in response) {
        // Convert from Supabase format to Note model format
        final noteData = <String, dynamic>{
          'id': data['id'],
          'title': data['title'],
          'description': data['description'],
          'from': data['from'],
          'to': data['to'],
          'isAllDay': data['is_all_day'] == 1,
          'noteCategory': data['note_category'],
        };

        notes.add(Note.fromMap(noteData));
      }

      LogWrapper.logger.i('Successfully fetched ${notes.length} notes');
      return notes;
    } catch (e) {
      LogWrapper.logger.e('Failed to fetch notes: $e');
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
