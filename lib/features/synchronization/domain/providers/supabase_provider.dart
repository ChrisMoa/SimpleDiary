import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/settings/settings_provider.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_attachments_provider.dart';
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
  final settings = ref.read(settingsProvider);
  return SupabaseSettingsNotifier(settings);
});

class SupabaseSettingsNotifier extends StateNotifier<SupabaseSettings> {
  SupabaseSettingsNotifier(SettingsContainer settings) : super(settings.activeUserSettings.supabaseSettings) {
    LogWrapper.logger.i('Initialized SupabaseSettingsNotifier with settings for user: ${settings.activeUserSettings.savedUserData.username}');
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

  void updateAutoSyncEnabled(bool enabled) {
    LogWrapper.logger.d('Updating auto-sync enabled: $enabled');
    state = state.copyWith(autoSyncEnabled: enabled);
  }

  void updateAutoSyncDebounceSeconds(int seconds) {
    LogWrapper.logger.d('Updating auto-sync debounce: ${seconds}s');
    state = state.copyWith(autoSyncDebounceSeconds: seconds);
  }

  void updateLastAutoSyncTimestamp(String timestamp) {
    state = state.copyWith(lastAutoSyncTimestamp: timestamp);
  }
}

// Supabase synchronization state provider
enum SyncStatus { idle, syncing, success, error }

enum SyncPhase {
  idle,
  initializing,
  authenticating,
  syncDiaryDays,
  syncNotes,
  syncTemplates,
  syncAttachments,
  uploadAttachmentFiles,
  downloadDiaryDays,
  downloadNotes,
  downloadTemplates,
  downloadAttachments,
  downloadAttachmentFiles,
  updatingLocalDatabase,
  completed,
  failed,
}

class SyncState {
  final SyncStatus status;
  final SyncPhase phase;
  final double progress;
  final int completedItems;
  final int totalItems;
  final String? errorMessage;

  SyncState({
    required this.status,
    this.phase = SyncPhase.idle,
    this.progress = 0.0,
    this.completedItems = 0,
    this.totalItems = 0,
    this.errorMessage,
  });

  /// Backward-compatible message getter for tests and non-l10n contexts.
  String get message {
    if (errorMessage != null && phase == SyncPhase.failed) {
      return errorMessage!;
    }
    return switch (phase) {
      SyncPhase.idle => 'Ready to sync',
      SyncPhase.initializing => 'Initializing sync...',
      SyncPhase.authenticating => 'Authenticating...',
      SyncPhase.syncDiaryDays => 'Syncing diary days...',
      SyncPhase.syncNotes => 'Syncing notes...',
      SyncPhase.syncTemplates => 'Syncing templates...',
      SyncPhase.syncAttachments => 'Syncing attachments...',
      SyncPhase.uploadAttachmentFiles => 'Uploading photos...',
      SyncPhase.downloadDiaryDays => 'Downloading diary days...',
      SyncPhase.downloadNotes => 'Downloading notes...',
      SyncPhase.downloadTemplates => 'Downloading templates...',
      SyncPhase.downloadAttachments => 'Downloading attachments...',
      SyncPhase.downloadAttachmentFiles => 'Downloading photos...',
      SyncPhase.updatingLocalDatabase => 'Updating local database...',
      SyncPhase.completed => 'Sync completed successfully',
      SyncPhase.failed => errorMessage ?? 'Sync failed',
    };
  }

  SyncState copyWith({
    SyncStatus? status,
    SyncPhase? phase,
    double? progress,
    int? completedItems,
    int? totalItems,
    String? errorMessage,
    // Keep backward-compatible message parameter — maps to phase for tests
    String? message,
  }) {
    return SyncState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      completedItems: completedItems ?? this.completedItems,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Supabase sync state notifier
class SupabaseSyncNotifier extends StateNotifier<SyncState> {
  final Ref ref;

  SupabaseSyncNotifier(this.ref) : super(SyncState(status: SyncStatus.idle)) {
    LogWrapper.logger.i('Initialized SupabaseSyncNotifier');
  }

  Future<void> syncToSupabase() async {
    LogWrapper.logger.i('Starting sync to Supabase');
    try {
      state = SyncState(
        status: SyncStatus.syncing,
        phase: SyncPhase.initializing,
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
        phase: SyncPhase.authenticating,
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

      // Sync diary days (progress 0.2 → 0.5)
      final diaryDays = ref.read(diaryDayLocalDbDataProvider);
      LogWrapper.logger.i('Syncing ${diaryDays.length} diary days');
      state = state.copyWith(
        phase: SyncPhase.syncDiaryDays,
        progress: 0.2,
        completedItems: 0,
        totalItems: diaryDays.length,
      );
      await supabaseApi.syncDiaryDays(diaryDays, userData.userId!,
        onProgress: (completed, total) {
          state = state.copyWith(
            completedItems: completed,
            totalItems: total,
            progress: total > 0 ? 0.2 + (0.3 * completed / total) : 0.5,
          );
        },
      );

      // Sync notes (progress 0.5 → 0.7)
      final notes = ref.read(notesLocalDataProvider);
      LogWrapper.logger.i('Syncing ${notes.length} notes');
      state = state.copyWith(
        phase: SyncPhase.syncNotes,
        progress: 0.5,
        completedItems: 0,
        totalItems: notes.length,
      );
      await supabaseApi.syncNotes(notes, userData.userId!,
        onProgress: (completed, total) {
          state = state.copyWith(
            completedItems: completed,
            totalItems: total,
            progress: total > 0 ? 0.5 + (0.2 * completed / total) : 0.7,
          );
        },
      );

      // Sync templates (progress 0.7 → 0.8)
      final templates = ref.read(noteTemplateLocalDataProvider);
      LogWrapper.logger.i('Syncing ${templates.length} templates');
      state = state.copyWith(
        phase: SyncPhase.syncTemplates,
        progress: 0.7,
        completedItems: 0,
        totalItems: templates.length,
      );
      await supabaseApi.syncTemplates(templates, userData.userId!,
        onProgress: (completed, total) {
          state = state.copyWith(
            completedItems: completed,
            totalItems: total,
            progress: total > 0 ? 0.7 + (0.1 * completed / total) : 0.8,
          );
        },
      );

      // Sync attachment metadata (progress 0.8 → 0.85)
      final attachments = ref.read(noteAttachmentsProvider);
      LogWrapper.logger.i('Syncing ${attachments.length} attachment records');
      state = state.copyWith(
        phase: SyncPhase.syncAttachments,
        progress: 0.8,
        completedItems: 0,
        totalItems: attachments.length,
      );
      await supabaseApi.syncAttachments(attachments, userData.userId!,
        onProgress: (completed, total) {
          state = state.copyWith(
            completedItems: completed,
            totalItems: total,
            progress: total > 0 ? 0.8 + (0.05 * completed / total) : 0.85,
          );
        },
      );

      // Upload unsynced attachment files (progress 0.85 → 0.95)
      final unsyncedAttachments = attachments.where((a) => a.remoteUrl == null).toList();
      LogWrapper.logger.i('Uploading ${unsyncedAttachments.length} unsynced attachment files');
      state = state.copyWith(
        phase: SyncPhase.uploadAttachmentFiles,
        progress: 0.85,
        completedItems: 0,
        totalItems: unsyncedAttachments.length,
      );

      final attachmentsNotifier = ref.read(noteAttachmentsProvider.notifier);
      for (var i = 0; i < unsyncedAttachments.length; i++) {
        try {
          final remoteUrl = await supabaseApi.uploadAttachment(unsyncedAttachments[i]);
          final updated = unsyncedAttachments[i].copyWith(remoteUrl: remoteUrl);
          await attachmentsNotifier.addOrUpdateElement(updated);
        } catch (e) {
          LogWrapper.logger.w('Failed to upload attachment ${unsyncedAttachments[i].id}: $e');
        }
        state = state.copyWith(
          completedItems: i + 1,
          totalItems: unsyncedAttachments.length,
          progress: unsyncedAttachments.isNotEmpty
              ? 0.85 + (0.1 * (i + 1) / unsyncedAttachments.length)
              : 0.95,
        );
      }

      // Clean up orphaned remote attachments (deleted locally)
      try {
        final remoteAttachments = await supabaseApi.fetchAttachments(userData.userId!);
        final localIds = attachments.map((a) => a.id).toSet();
        final orphaned = remoteAttachments.where((a) => !localIds.contains(a.id)).toList();

        if (orphaned.isNotEmpty) {
          LogWrapper.logger.i('Cleaning up ${orphaned.length} orphaned remote attachments');
          for (final attachment in orphaned) {
            try {
              await supabaseApi.deleteAttachmentFile(attachment);
            } catch (e) {
              LogWrapper.logger.w('Failed to delete orphaned storage file ${attachment.id}: $e');
            }
          }
          await supabaseApi.deleteAttachmentMetadata(orphaned.map((a) => a.id).toList());
        }
      } catch (e) {
        LogWrapper.logger.w('Failed to clean up orphaned remote attachments: $e');
      }

      LogWrapper.logger.i('Sync completed successfully');
      state = SyncState(
        status: SyncStatus.success,
        phase: SyncPhase.completed,
        progress: 1.0,
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = SyncState(status: SyncStatus.idle);
        }
      });
    } catch (e) {
      LogWrapper.logger.e('Sync failed: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        phase: SyncPhase.failed,
        errorMessage: 'Sync failed: ${e.toString()}',
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = SyncState(status: SyncStatus.idle);
        }
      });
    }
  }

  Future<void> syncFromSupabase() async {
    LogWrapper.logger.i('Starting sync from Supabase');
    try {
      state = SyncState(
        status: SyncStatus.syncing,
        phase: SyncPhase.initializing,
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
        phase: SyncPhase.authenticating,
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
        phase: SyncPhase.downloadDiaryDays,
        progress: 0.2,
      );

      LogWrapper.logger.d('Fetching diary days for user: ${userData.userId}');
      final diaryDays = await supabaseApi.fetchDiaryDays(userData.userId!);
      LogWrapper.logger.i('Fetched ${diaryDays.length} diary days');

      state = state.copyWith(
        phase: SyncPhase.downloadNotes,
        progress: 0.35,
      );

      LogWrapper.logger.d('Fetching notes for user: ${userData.userId}');
      final notes = await supabaseApi.fetchNotes(userData.userId!);
      LogWrapper.logger.i('Fetched ${notes.length} notes');

      state = state.copyWith(
        phase: SyncPhase.downloadTemplates,
        progress: 0.5,
      );

      LogWrapper.logger.d('Fetching templates for user: ${userData.userId}');
      final templates = await supabaseApi.fetchTemplates(userData.userId!);
      LogWrapper.logger.i('Fetched ${templates.length} templates');

      // Fetch attachment metadata (progress 0.55)
      state = state.copyWith(
        phase: SyncPhase.downloadAttachments,
        progress: 0.55,
      );

      LogWrapper.logger.d('Fetching attachments for user: ${userData.userId}');
      final remoteAttachments = await supabaseApi.fetchAttachments(userData.userId!);
      LogWrapper.logger.i('Fetched ${remoteAttachments.length} attachments');

      state = state.copyWith(
        phase: SyncPhase.updatingLocalDatabase,
        progress: 0.6,
      );

      final diaryDayNotifier = ref.read(diaryDayLocalDbDataProvider.notifier);
      final notesNotifier = ref.read(notesLocalDataProvider.notifier);
      final templatesNotifier = ref.read(noteTemplateLocalDataProvider.notifier);
      final attachmentsNotifier = ref.read(noteAttachmentsProvider.notifier);

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

      // Insert attachment metadata
      for (var attachment in remoteAttachments) {
        await attachmentsNotifier.addOrUpdateElement(attachment);
      }

      // Download missing attachment files (progress 0.7 → 0.95)
      final appDocPath = ref.read(settingsProvider).applicationDocumentsPath;
      final localAttachments = ref.read(noteAttachmentsProvider);
      final missingFiles = localAttachments.where((a) {
        return a.remoteUrl != null && !File(a.filePath).existsSync();
      }).toList();

      LogWrapper.logger.i('Downloading ${missingFiles.length} missing attachment files');
      state = state.copyWith(
        phase: SyncPhase.downloadAttachmentFiles,
        progress: 0.7,
        completedItems: 0,
        totalItems: missingFiles.length,
      );

      for (var i = 0; i < missingFiles.length; i++) {
        try {
          final attachment = missingFiles[i];
          final ext = attachment.filePath.split('.').last;
          final localPath = '$appDocPath/images/${attachment.noteId}/${attachment.id}.$ext';
          await supabaseApi.downloadAttachment(
            attachment: attachment,
            localFilePath: localPath,
          );
          final updated = attachment.copyWith(filePath: localPath);
          await attachmentsNotifier.addOrUpdateElement(updated);
        } catch (e) {
          LogWrapper.logger.w('Failed to download attachment ${missingFiles[i].id}: $e');
        }
        state = state.copyWith(
          completedItems: i + 1,
          totalItems: missingFiles.length,
          progress: missingFiles.isNotEmpty
              ? 0.7 + (0.25 * (i + 1) / missingFiles.length)
              : 0.95,
        );
      }

      LogWrapper.logger.i('Download completed successfully');
      state = SyncState(
        status: SyncStatus.success,
        phase: SyncPhase.completed,
        progress: 1.0,
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = SyncState(status: SyncStatus.idle);
        }
      });
    } catch (e) {
      LogWrapper.logger.e('Download failed: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        phase: SyncPhase.failed,
        errorMessage: 'Download failed: ${e.toString()}',
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = SyncState(status: SyncStatus.idle);
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
