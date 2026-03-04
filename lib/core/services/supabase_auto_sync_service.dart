import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_provider.dart';
import 'package:day_tracker/features/synchronization/domain/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service that triggers Supabase sync automatically after data changes,
/// with debounce logic to avoid redundant sync operations.
class SupabaseAutoSyncService {
  static DateTime? _lastSyncTime;

  /// Triggers a sync to Supabase if auto-sync is enabled and debounce allows it.
  ///
  /// Checks:
  /// 1. Supabase settings are configured (URL, key, email, password)
  /// 2. Auto-sync is enabled
  /// 3. Not already syncing
  /// 4. Debounce interval has passed since last sync
  static Future<void> triggerSyncIfEnabled(WidgetRef ref) async {
    final settings = ref.read(supabaseSettingsProvider);

    if (!settings.isConfigured) {
      LogWrapper.logger.t('Auto-sync skipped: Supabase not configured');
      return;
    }

    if (!settings.autoSyncEnabled) {
      LogWrapper.logger.t('Auto-sync skipped: disabled');
      return;
    }

    final syncState = ref.read(supabaseSyncProvider);
    if (syncState.status == SyncStatus.syncing) {
      LogWrapper.logger.t('Auto-sync skipped: sync already in progress');
      return;
    }

    final now = DateTime.now();
    if (_lastSyncTime != null &&
        now.difference(_lastSyncTime!).inSeconds <
            settings.autoSyncDebounceSeconds) {
      LogWrapper.logger.t('Auto-sync skipped: debounce (last sync ${now.difference(_lastSyncTime!).inSeconds}s ago)');
      return;
    }

    LogWrapper.logger.i('Auto-sync triggered');
    _lastSyncTime = now;

    try {
      await ref.read(supabaseSyncProvider.notifier).syncToSupabase();

      // Update last auto-sync timestamp in settings
      final timestamp = DateTime.now().toIso8601String();
      ref.read(supabaseSettingsProvider.notifier).updateLastAutoSyncTimestamp(timestamp);
      ref.read(settingsProvider).activeUserSettings.supabaseSettings =
          ref.read(supabaseSettingsProvider);
      ref.read(settingsNotifierProvider).saveSettings().ignore();
    } catch (e) {
      LogWrapper.logger.e('Auto-sync failed: $e');
    }
  }

  /// Resets the debounce timer (useful for testing).
  static void resetDebounce() {
    _lastSyncTime = null;
  }
}
