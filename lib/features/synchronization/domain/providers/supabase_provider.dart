import 'package:flutter/foundation.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:day_tracker/features/synchronization/data/repositories/supabase_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Supabase API instance provider
// Debug builds use test_ prefixed tables to avoid polluting production data.
final supabaseApiProvider = Provider<SupabaseApi>((ref) {
  LogWrapper.logger.d('Creating new SupabaseApi instance');
  return SupabaseApi(tablePrefix: kDebugMode ? 'test_' : '');
});

// Supabase settings provider
final supabaseSettingsProvider = StateNotifierProvider<SupabaseSettingsNotifier, SupabaseSettings>((ref) {
  LogWrapper.logger.d('Creating new SupabaseSettingsNotifier');
  return SupabaseSettingsNotifier();
});

class SupabaseSettingsNotifier extends StateNotifier<SupabaseSettings> {
  SupabaseSettingsNotifier() : super(settingsContainer.activeUserSettings.supabaseSettings) {
    LogWrapper.logger.i('Initialized SupabaseSettingsNotifier with settings for user: ${settingsContainer.activeUserSettings.savedUserData.username}');
  }

  void updateSettings(SupabaseSettings settings) {
    LogWrapper.logger.d('Updating all Supabase settings');
    state = settings;
  }

  void updateUrl(String url) {
    LogWrapper.logger.d('Updating Supabase URL');
    state = state.copyWith(supabaseUrl: url);
  }

  void updateAnonKey(String key) {
    LogWrapper.logger.d('Updating Supabase anon key');
    state = state.copyWith(supabaseAnonKey: key);
  }

  void updateEmail(String email) {
    LogWrapper.logger.d('Updating Supabase email');
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    LogWrapper.logger.d('Updating Supabase password');
    state = state.copyWith(password: password);
  }
}

// Supabase synchronization state provider
enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final String message;
  final double progress;

  SyncState({
    required this.status,
    required this.message,
    this.progress = 0.0,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? message,
    double? progress,
  }) {
    return SyncState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
    );
  }
}

// Supabase sync state notifier
class SupabaseSyncNotifier extends StateNotifier<SyncState> {
  final Ref ref;

  SupabaseSyncNotifier(this.ref) : super(SyncState(status: SyncStatus.idle, message: 'Ready to sync')) {
    LogWrapper.logger.i('Initialized SupabaseSyncNotifier');
  }

  Future<void> syncToSupabase() async {
    LogWrapper.logger.i('Starting sync to Supabase');
    try {
      state = state.copyWith(
        status: SyncStatus.syncing,
        message: 'Initializing sync...',
        progress: 0.0,
      );

      final supabaseApi = ref.read(supabaseApiProvider);
      final settings = ref.read(supabaseSettingsProvider);
      final userData = ref.read(userDataProvider);

      LogWrapper.logger.d('Initializing Supabase with URL: ${settings.supabaseUrl}');
      await supabaseApi.initialize(
        settings.supabaseUrl,
        settings.supabaseAnonKey,
      );

      state = state.copyWith(
        message: 'Authenticating...',
        progress: 0.1,
      );

      LogWrapper.logger.d('Authenticating with email: ${settings.email}');
      final success = await supabaseApi.signInWithEmailPassword(
        settings.email,
        settings.password,
      );

      if (!success) {
        LogWrapper.logger.e('Authentication failed');
        throw Exception('Authentication failed');
      }

      state = state.copyWith(
        message: 'Syncing diary days...',
        progress: 0.2,
      );

      final diaryDays = ref.read(diaryDayLocalDbDataProvider);
      LogWrapper.logger.i('Syncing ${diaryDays.length} diary days');
      await supabaseApi.syncDiaryDays(diaryDays, userData.userId!);

      state = state.copyWith(
        message: 'Syncing notes...',
        progress: 0.5,
      );

      final notes = ref.read(notesLocalDataProvider);
      LogWrapper.logger.i('Syncing ${notes.length} notes');
      await supabaseApi.syncNotes(notes, userData.userId!);

      state = state.copyWith(
        message: 'Syncing templates...',
        progress: 0.8,
      );

      final templates = ref.read(noteTemplateLocalDataProvider);
      LogWrapper.logger.i('Syncing ${templates.length} templates');
      await supabaseApi.syncTemplates(templates, userData.userId!);

      LogWrapper.logger.i('Sync completed successfully');
      state = state.copyWith(
        status: SyncStatus.success,
        message: 'Sync completed successfully',
        progress: 1.0,
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Ready to sync',
            progress: 0.0,
          );
        }
      });
    } catch (e) {
      LogWrapper.logger.e('Sync failed: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        message: 'Sync failed: ${e.toString()}',
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Ready to sync',
            progress: 0.0,
          );
        }
      });
    }
  }

  Future<void> syncFromSupabase() async {
    LogWrapper.logger.i('Starting sync from Supabase');
    try {
      state = state.copyWith(
        status: SyncStatus.syncing,
        message: 'Downloading data...',
        progress: 0.0,
      );

      final supabaseApi = ref.read(supabaseApiProvider);
      final settings = ref.read(supabaseSettingsProvider);
      final userData = ref.read(userDataProvider);

      LogWrapper.logger.d('Initializing Supabase with URL: ${settings.supabaseUrl}');
      await supabaseApi.initialize(
        settings.supabaseUrl,
        settings.supabaseAnonKey,
      );

      state = state.copyWith(
        message: 'Authenticating...',
        progress: 0.1,
      );

      LogWrapper.logger.d('Authenticating with email: ${settings.email}');
      final success = await supabaseApi.signInWithEmailPassword(
        settings.email,
        settings.password,
      );

      if (!success) {
        LogWrapper.logger.e('Authentication failed');
        throw Exception('Authentication failed');
      }

      state = state.copyWith(
        message: 'Downloading diary days...',
        progress: 0.2,
      );

      LogWrapper.logger.d('Fetching diary days for user: ${userData.userId}');
      final diaryDays = await supabaseApi.fetchDiaryDays(userData.userId!);
      LogWrapper.logger.i('Fetched ${diaryDays.length} diary days');

      state = state.copyWith(
        message: 'Downloading notes...',
        progress: 0.5,
      );

      LogWrapper.logger.d('Fetching notes for user: ${userData.userId}');
      final notes = await supabaseApi.fetchNotes(userData.userId!);
      LogWrapper.logger.i('Fetched ${notes.length} notes');

      state = state.copyWith(
        message: 'Downloading templates...',
        progress: 0.7,
      );

      LogWrapper.logger.d('Fetching templates for user: ${userData.userId}');
      final templates = await supabaseApi.fetchTemplates(userData.userId!);
      LogWrapper.logger.i('Fetched ${templates.length} templates');

      state = state.copyWith(
        message: 'Updating local database...',
        progress: 0.8,
      );

      final diaryDayNotifier = ref.read(diaryDayLocalDbDataProvider.notifier);
      final notesNotifier = ref.read(notesLocalDataProvider.notifier);
      final templatesNotifier = ref.read(noteTemplateLocalDataProvider.notifier);

      LogWrapper.logger.d('Updating local database with fetched data');
      for (var diaryDay in diaryDays) {
        await diaryDayNotifier.addElement(diaryDay);
      }

      for (var note in notes) {
        await notesNotifier.addElement(note);
      }

      for (var template in templates) {
        await templatesNotifier.addElement(template);
      }

      LogWrapper.logger.i('Download completed successfully');
      state = state.copyWith(
        status: SyncStatus.success,
        message: 'Download completed successfully',
        progress: 1.0,
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Ready to sync',
            progress: 0.0,
          );
        }
      });
    } catch (e) {
      LogWrapper.logger.e('Download failed: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        message: 'Download failed: ${e.toString()}',
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Ready to sync',
            progress: 0.0,
          );
        }
      });
    }
  }
}

// Supabase sync provider
final supabaseSyncProvider = StateNotifierProvider<SupabaseSyncNotifier, SyncState>((ref) {
  LogWrapper.logger.d('Creating new SupabaseSyncNotifier');
  return SupabaseSyncNotifier(ref);
});