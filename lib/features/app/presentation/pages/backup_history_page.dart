// ignore_for_file: public_member_api_docs
import 'package:day_tracker/core/backup/backup_metadata.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/backup_service.dart';
import 'package:day_tracker/core/services/backup_scheduler.dart';
import 'package:day_tracker/core/services/cloud_backup_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/habits/data/models/habit.dart';
import 'package:day_tracker/features/habits/data/models/habit_entry.dart';
import 'package:day_tracker/features/habits/domain/providers/habit_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page displaying backup history with restore and delete actions
class BackupHistoryPage extends ConsumerStatefulWidget {
  const BackupHistoryPage({super.key});

  @override
  ConsumerState<BackupHistoryPage> createState() => _BackupHistoryPageState();
}

class _BackupHistoryPageState extends ConsumerState<BackupHistoryPage> {
  List<BackupMetadata>? _backups;
  int _storageUsageBytes = 0;
  bool _isLoading = true;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      final backups = await BackupService().listBackups();
      final storage = await BackupService().getStorageUsageBytes();
      if (mounted) {
        setState(() {
          _backups = backups;
          _storageUsageBytes = storage;
          _isLoading = false;
        });
      }
    } catch (e) {
      LogWrapper.logger.e('Failed to load backups: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupHistory),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? Padding(
              padding: AppSpacing.paddingAllMd,
              child: Column(
                children: List.generate(4, (_) => Padding(
                  padding: AppSpacing.paddingVerticalXs,
                  child: ShimmerPlaceholder(height: 72, borderRadius: AppRadius.borderRadiusLg),
                )),
              ),
            )
          : _buildBody(theme, l10n),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    if (_backups == null || _backups!.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return Column(
      children: [
        // Storage usage header
        _buildStorageHeader(theme, l10n),

        // Backup list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadBackups,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _backups!.length,
              itemBuilder: (context, index) =>
                  _buildBackupCard(theme, l10n, _backups![index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.backup_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: .3),
            ),
            AppSpacing.verticalMd,
            Text(
              l10n.backupNoBackups,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .7),
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              l10n.backupNoBackupsDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageHeader(ThemeData theme, AppLocalizations l10n) {
    final formattedSize = _formatBytes(_storageUsageBytes);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: .3),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          AppSpacing.horizontalXs,
          Text(
            l10n.backupStorageUsed(formattedSize),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_isCloudSyncEnabled)
            IconButton(
              icon: Icon(Icons.cloud_download, color: theme.colorScheme.primary),
              tooltip: l10n.backupCloudBackups,
              onPressed: () => _showCloudBackups(l10n),
              visualDensity: VisualDensity.compact,
            ),
          Text(
            '${_backups?.length ?? 0} ${_backups?.length == 1 ? 'backup' : 'backups'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard(
    ThemeData theme,
    AppLocalizations l10n,
    BackupMetadata backup,
  ) {
    final isSuccess = backup.isSuccessful;

    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: AppSpacing.paddingAllMd,
      borderRadius: AppRadius.borderRadiusMd,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: type badge + date + size
            Row(
              children: [
                _buildTypeBadge(theme, l10n, backup.type),
                if (backup.encrypted) ...[
                  AppSpacing.horizontalXxs,
                  Icon(
                    Icons.lock,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ],
                if (backup.cloudSynced) ...[
                  AppSpacing.horizontalXxs,
                  Icon(
                    Icons.cloud_done,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ],
                AppSpacing.horizontalXs,
                Expanded(
                  child: Text(
                    _formatDateTime(backup.createdAt),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  backup.formattedSize,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .7),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalXs,

            // Content summary
            if (isSuccess)
              Text(
                l10n.backupEntries(
                  backup.diaryDayCount,
                  backup.noteCount,
                  backup.habitCount,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .7),
                ),
              ),

            // Error message
            if (!isSuccess)
              Container(
                padding: AppSpacing.paddingAllXs,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: .3),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 16,
                    ),
                    AppSpacing.horizontalXs,
                    Expanded(
                      child: Text(
                        backup.error ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            AppSpacing.verticalSm,

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSuccess && _isCloudSyncEnabled && !backup.cloudSynced)
                  TextButton.icon(
                    onPressed: () => _uploadToCloud(backup, l10n),
                    icon: const Icon(Icons.cloud_upload, size: 18),
                    label: Text(l10n.backupUploadToCloud),
                  ),
                if (isSuccess)
                  TextButton.icon(
                    onPressed: _isRestoring
                        ? null
                        : () => _confirmRestore(backup, l10n),
                    icon: const Icon(Icons.restore, size: 18),
                    label: Text(l10n.backupRestoreConfirm),
                  ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(backup, l10n),
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: theme.colorScheme.error),
                  label: Text(
                    l10n.delete,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildTypeBadge(
    ThemeData theme,
    AppLocalizations l10n,
    BackupType type,
  ) {
    String label;
    IconData icon;
    switch (type) {
      case BackupType.manual:
        label = l10n.backupTypeManual;
        icon = Icons.touch_app;
        break;
      case BackupType.scheduled:
        label = l10n.backupTypeScheduled;
        icon = Icons.schedule;
        break;
      case BackupType.preRestore:
        label = l10n.backupTypePreRestore;
        icon = Icons.safety_check;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSecondaryContainer),
          AppSpacing.horizontalXxs,
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRestore(
    BackupMetadata backup,
    AppLocalizations l10n,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.backupRestoreConfirm,
      content: l10n.backupRestoreConfirmMessage(
        _formatDateTime(backup.createdAt),
      ),
      confirmLabel: l10n.backupRestoreConfirm,
      cancelLabel: l10n.cancel,
    );

    if (confirmed && mounted) {
      await _restoreBackup(backup, l10n);
    }
  }

  Future<void> _restoreBackup(
    BackupMetadata backup,
    AppLocalizations l10n,
  ) async {
    setState(() => _isRestoring = true);

    try {
      // 1. Create a safety backup first
      final diaryDays = ref.read(diaryDayLocalDbDataProvider);
      final notes = ref.read(notesLocalDataProvider);
      final habits = ref.read(habitsLocalDbDataProvider);
      final habitEntries = ref.read(habitEntriesLocalDbDataProvider);

      await BackupScheduler().runBackup(
        diaryDays: diaryDays,
        notes: notes,
        habits: habits,
        habitEntries: habitEntries,
        type: BackupType.preRestore,
      );

      // 2. Read backup content
      final content = await BackupService().readBackupContent(backup.id);

      // 3. Clear and import diary days
      final diaryDayNotifier =
          ref.read(diaryDayLocalDbDataProvider.notifier);
      await diaryDayNotifier.clearTable();
      for (final dayMap in content['diaryDays']!) {
        final day = _diaryDayFromMap(dayMap);
        if (day != null) {
          await diaryDayNotifier.addElement(day);
        }
      }

      // 4. Clear and import notes
      final notesNotifier = ref.read(notesLocalDataProvider.notifier);
      await notesNotifier.clearTable();
      for (final noteMap in content['notes']!) {
        final note = _noteFromMap(noteMap);
        if (note != null) {
          await notesNotifier.addElement(note);
        }
      }

      // 5. Clear and import habits
      final habitsNotifier = ref.read(habitsLocalDbDataProvider.notifier);
      await habitsNotifier.clearTable();
      for (final habitMap in content['habits']!) {
        final habit = _habitFromMap(habitMap);
        if (habit != null) {
          await habitsNotifier.addElement(habit);
        }
      }

      // 6. Clear and import habit entries
      final habitEntriesNotifier =
          ref.read(habitEntriesLocalDbDataProvider.notifier);
      await habitEntriesNotifier.clearTable();
      for (final entryMap in content['habitEntries']!) {
        final entry = _habitEntryFromMap(entryMap);
        if (entry != null) {
          await habitEntriesNotifier.addElement(entry);
        }
      }

      if (mounted) {
        setState(() => _isRestoring = false);
        AppSnackBar.success(context, message: l10n.backupRestoreSuccess);
        await _loadBackups();
      }
    } catch (e) {
      LogWrapper.logger.e('Restore failed: $e');
      if (mounted) {
        setState(() => _isRestoring = false);
        AppSnackBar.error(context, message: l10n.backupRestoreFailed(e.toString()));
      }
    }
  }

  Future<void> _confirmDelete(
    BackupMetadata backup,
    AppLocalizations l10n,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.backupDeleteConfirm,
      content: l10n.backupDeleteConfirmMessage,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed) {
      await BackupService().deleteBackup(backup.id);
      if (mounted) {
        AppSnackBar.info(context, message: l10n.backupDeleted);
        await _loadBackups();
      }
    }
  }

  // -- Cloud sync helpers --

  bool get _isCloudSyncEnabled =>
      settingsContainer.activeUserSettings.backupSettings.isCloudEnabled;

  Future<void> _uploadToCloud(
    BackupMetadata backup,
    AppLocalizations l10n,
  ) async {
    final success = await CloudBackupService().uploadBackup(backup);
    if (success) {
      final updated = backup.copyWith(cloudSynced: true);
      await BackupService().updateMetadataInIndex(updated);
      if (mounted) {
        AppSnackBar.success(context, message: l10n.backupUploadSuccess);
        await _loadBackups();
      }
    } else if (mounted) {
      AppSnackBar.error(context, message: l10n.backupUploadFailed(''));
    }
  }

  Future<void> _showCloudBackups(AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final cloudFiles = await CloudBackupService().listCloudBackups();

    // Filter out backups already present locally
    final localIds = _backups?.map((b) => b.id).toSet() ?? {};
    final cloudOnlyFiles = cloudFiles
        .where((f) => !localIds.contains(f.name.replaceAll('.json', '')))
        .toList();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: AppSpacing.paddingAllMd,
              child: Row(
                children: [
                  Icon(Icons.cloud, color: theme.colorScheme.primary),
                  AppSpacing.horizontalXs,
                  Text(
                    l10n.backupCloudBackups,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: cloudOnlyFiles.isEmpty
                  ? Center(
                      child: Text(
                        l10n.backupCloudNoBackups,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: .5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: cloudOnlyFiles.length,
                      itemBuilder: (context, index) {
                        final file = cloudOnlyFiles[index];
                        final backupId = file.name.replaceAll('.json', '');
                        return ListTile(
                          leading: Icon(
                            Icons.cloud_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            backupId,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: TextButton.icon(
                            icon: const Icon(Icons.download, size: 18),
                            label: Text(l10n.backupDownloadFromCloud),
                            onPressed: () async {
                              Navigator.pop(context);
                              await _downloadFromCloud(backupId, l10n);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFromCloud(
    String backupId,
    AppLocalizations l10n,
  ) async {
    final metadata = await CloudBackupService().downloadBackup(backupId);
    if (metadata != null && mounted) {
      AppSnackBar.success(context, message: l10n.backupDownloadSuccess);
      await _loadBackups();
    } else if (mounted) {
      AppSnackBar.error(context, message: l10n.backupDownloadFailed(''));
    }
  }

  // -- Helper methods to reconstruct objects from backup maps --

  dynamic _diaryDayFromMap(Map<String, dynamic> map) {
    try {
      return DiaryDay.fromMap(map);
    } catch (e) {
      LogWrapper.logger.w('Failed to parse diary day from backup: $e');
      return null;
    }
  }

  dynamic _noteFromMap(Map<String, dynamic> map) {
    try {
      return Note.fromDbMap(map);
    } catch (e) {
      LogWrapper.logger.w('Failed to parse note from backup: $e');
      return null;
    }
  }

  dynamic _habitFromMap(Map<String, dynamic> map) {
    try {
      return Habit.fromDbMap(map);
    } catch (e) {
      LogWrapper.logger.w('Failed to parse habit from backup: $e');
      return null;
    }
  }

  dynamic _habitEntryFromMap(Map<String, dynamic> map) {
    try {
      return HabitEntry.fromDbMap(map);
    } catch (e) {
      LogWrapper.logger.w('Failed to parse habit entry from backup: $e');
      return null;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
