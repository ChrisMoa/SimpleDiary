import 'package:day_tracker/features/synchronization/presentation/widgets/file_sync_widget.dart';
import 'package:day_tracker/features/synchronization/presentation/widgets/supabase_sync_widget.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SynchronizePage extends ConsumerWidget {
  const SynchronizePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth >= 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 1200 : double.infinity,
            ),
            child: isLandscape && isTablet
                ? _buildLandscapeLayout(theme, l10n)
                : _buildPortraitLayout(theme, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page Title
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              l10n.synchronization,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // File Synchronization Card
          const FileSyncWidget(),

          const SizedBox(height: 24),

          // Supabase Synchronization Card
          const SupabaseSyncWidget(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Page Title
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.synchronization,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Cards in horizontal layout
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Synchronization Card
                const Expanded(
                  child: FileSyncWidget(),
                ),

                const SizedBox(width: 24),

                // Supabase Synchronization Card
                const Expanded(
                  child: SupabaseSyncWidget(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
