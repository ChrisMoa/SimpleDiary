// lib/features/synchronization/presentation/widgets/supabase_sync_widget.dart
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/synchronization/data/models/supabase_settings.dart';
import 'package:day_tracker/features/synchronization/domain/providers/supabase_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseSyncWidget extends ConsumerStatefulWidget {
  const SupabaseSyncWidget({super.key});

  @override
  ConsumerState<SupabaseSyncWidget> createState() => _SupabaseSyncWidgetState();
}

class _SupabaseSyncWidgetState extends ConsumerState<SupabaseSyncWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);
    final syncState = ref.watch(supabaseSyncProvider);
    final settings = ref.watch(supabaseSettingsProvider);

    // Responsive design considerations
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return AppCard.elevated(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.cloud_sync,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  AppSpacing.horizontalXs,
                  Text(
                    l10n.supabaseSynchronization,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalMd,

              Text(
                l10n.supabaseSyncDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              AppSpacing.verticalXl,

              // Sync Status
              if (syncState.status != SyncStatus.idle) _buildSyncStatus(syncState, theme, isSmallScreen),

              if (syncState.status != SyncStatus.idle) SizedBox(height: isSmallScreen ? 16 : 20),

              // Action Buttons
              Column(
                children: [
                  _buildSyncButton(
                    context: context,
                    icon: Icons.cloud_upload,
                    label: l10n.uploadToSupabase,
                    description: l10n.saveYourDiaryDataToCloud,
                    onPressed: _canSync(settings) ? _onSyncToSupabase : null,
                    theme: theme,
                    isSmallScreen: isSmallScreen,
                  ),
                  AppSpacing.verticalMd,
                  _buildSyncButton(
                    context: context,
                    icon: Icons.cloud_download,
                    label: l10n.downloadFromSupabase,
                    description: l10n.loadDiaryDataFromCloud,
                    onPressed: _canSync(settings) ? _onSyncFromSupabase : null,
                    theme: theme,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback? onPressed,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadius.borderRadiusMd,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: onPressed != null ? theme.colorScheme.surfaceContainer : theme.colorScheme.onSurface.withValues(alpha: .12),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: .2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: onPressed != null ? theme.colorScheme.primaryContainer : theme.colorScheme.onSurface.withValues(alpha: .12),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Icon(
                icon,
                color: onPressed != null ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface.withValues(alpha: .38),
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onPressed != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: .38),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onPressed != null ? theme.colorScheme.onSurface.withValues(alpha: .7) : theme.colorScheme.onSurface.withValues(alpha: .38),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: onPressed != null ? theme.colorScheme.onSurface.withValues(alpha: .5) : theme.colorScheme.onSurface.withValues(alpha: .38),
              size: isSmallScreen ? 16 : 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus(SyncState syncState, ThemeData theme, bool isSmallScreen) {
    Color statusColor;
    IconData statusIcon;

    switch (syncState.status) {
      case SyncStatus.syncing:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.sync;
        break;
      case SyncStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case SyncStatus.error:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = theme.colorScheme.onSurface;
        statusIcon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: .1),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: statusColor.withValues(alpha: .3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: isSmallScreen ? 18 : 20),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  syncState.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
          if (syncState.status == SyncStatus.syncing) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            LinearProgressIndicator(
              value: syncState.progress,
              backgroundColor: statusColor.withValues(alpha: .2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ],
      ),
    );
  }

  bool _canSync(SupabaseSettings settings) {
    return settings.supabaseUrl.isNotEmpty && settings.supabaseAnonKey.isNotEmpty && settings.email.isNotEmpty && settings.password.isNotEmpty;
  }

  Future<void> _onSyncToSupabase() async {
    LogWrapper.logger.d('Sync to Supabase button clicked');
    try {
      await ref.read(supabaseSyncProvider.notifier).syncToSupabase();
    } catch (e) {
      LogWrapper.logger.e('Error during sync to Supabase: $e');
    }
  }

  Future<void> _onSyncFromSupabase() async {
    LogWrapper.logger.d('Sync from Supabase button clicked');
    try {
      await ref.read(supabaseSyncProvider.notifier).syncFromSupabase();
    } catch (e) {
      LogWrapper.logger.e('Error during sync from Supabase: $e');
    }
  }
}
