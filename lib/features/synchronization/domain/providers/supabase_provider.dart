import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:day_tracker/features/synchronization/data/repositories/supabase_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Supabase API instance provider
final supabaseApiProvider = Provider<SupabaseApi>((ref) {
  return SupabaseApi();
});

// Supabase settings provider
final supabaseSettingsProvider = StateNotifierProvider<SupabaseSettingsNotifier, SupabaseSettings>((ref) {
  return SupabaseSettingsNotifier();
});

class SupabaseSettingsNotifier extends StateNotifier<SupabaseSettings> {
  SupabaseSettingsNotifier() : super(settingsContainer.activeUserSettings.supabaseSettings);

  void updateSettings(SupabaseSettings settings) {
    state = settings;
  }

  void updateUrl(String url) {
    state = state.copyWith(supabaseUrl: url);
  }

  void updateAnonKey(String key) {
    state = state.copyWith(supabaseAnonKey: key);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
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

  SupabaseSyncNotifier(this.ref) : super(SyncState(status: SyncStatus.idle, message: 'Ready to sync'));

  Future<void> syncToSupabase() async {
    try {
      state = state.copyWith(
        status: SyncStatus.syncing,
        message: 'Initializing sync...',
        progress: 0.0,
      );

      final supabaseApi = ref.read(supabaseApiProvider);
      final settings = ref.read(supabaseSettingsProvider);
      final userData = ref.read(userDataProvider);

      // Initialize Supabase if not already done
      await supabaseApi.initialize(
        settings.supabaseUrl,
        settings.supabaseAnonKey,
      );

      state = state.copyWith(
        message: 'Authenticating...',
        progress: 0.1,
      );

      // Authenticate
      final success = await supabaseApi.signInWithEmailPassword(
        settings.email,
        settings.password,
      );

      if (!success) {
        throw Exception('Authentication failed');
      }

      state = state.copyWith(
        message: 'Syncing diary days...',
        progress: 0.3,
      );

      // Sync diary days
      final diaryDays = ref.read(diaryDayLocalDbDataProvider);
      await supabaseApi.syncDiaryDays(diaryDays, userData.userId!);

      state = state.copyWith(
        message: 'Syncing notes...',
        progress: 0.6,
      );

      // Sync notes
      final notes = ref.read(notesLocalDataProvider);
      await supabaseApi.syncNotes(notes, userData.userId!);

      state = state.copyWith(
        status: SyncStatus.success,
        message: 'Sync completed successfully',
        progress: 1.0,
      );

      // Reset to idle after 3 seconds
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

      // Reset to idle after 5 seconds
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
    try {
      state = state.copyWith(
        status: SyncStatus.syncing,
        message: 'Downloading data...',
        progress: 0.0,
      );

      final supabaseApi = ref.read(supabaseApiProvider);
      final settings = ref.read(supabaseSettingsProvider);
      final userData = ref.read(userDataProvider);

      // Initialize Supabase if not already done
      await supabaseApi.initialize(
        settings.supabaseUrl,
        settings.supabaseAnonKey,
      );

      state = state.copyWith(
        message: 'Authenticating...',
        progress: 0.1,
      );

      // Authenticate
      final success = await supabaseApi.signInWithEmailPassword(
        settings.email,
        settings.password,
      );

      if (!success) {
        throw Exception('Authentication failed');
      }

      state = state.copyWith(
        message: 'Downloading diary days...',
        progress: 0.3,
      );

      // Fetch diary days
      final diaryDays = await supabaseApi.fetchDiaryDays(userData.userId!);

      state = state.copyWith(
        message: 'Downloading notes...',
        progress: 0.6,
      );

      // Fetch notes
      final notes = await supabaseApi.fetchNotes(userData.userId!);

      state = state.copyWith(
        message: 'Updating local database...',
        progress: 0.8,
      );

      // Update local database
      final diaryDayNotifier = ref.read(diaryDayLocalDbDataProvider.notifier);
      final notesNotifier = ref.read(notesLocalDataProvider.notifier);

      for (var diaryDay in diaryDays) {
        await diaryDayNotifier.addElement(diaryDay);
      }

      for (var note in notes) {
        await notesNotifier.addElement(note);
      }

      state = state.copyWith(
        status: SyncStatus.success,
        message: 'Download completed successfully',
        progress: 1.0,
      );

      // Reset to idle after 3 seconds
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

      // Reset to idle after 5 seconds
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
  return SupabaseSyncNotifier(ref);
});
