import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/dashboard/data/repositories/activity_detail_repository.dart';
import 'package:day_tracker/features/dashboard/domain/providers/activity_detail_provider.dart';
import 'package:day_tracker/features/dashboard/presentation/pages/activity_detail_page.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays top activities as clickable cards on the dashboard
class TopActivitiesWidget extends ConsumerWidget {
  const TopActivitiesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(topActivitySummariesProvider);
    final l10n = AppLocalizations.of(context);

    if (activities.isEmpty) return const SizedBox.shrink();

    return AppSection(
      title: l10n.topActivities,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: activities.map((activity) {
          return _ActivityChip(activity: activity);
        }).toList(),
      ),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({required this.activity});

  final ActivitySummary activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: activity.category.color,
        radius: 6,
      ),
      label: Text(
        '${activity.activityName} (${activity.count})',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: activity.category.color.withValues(alpha: 0.1),
      side: BorderSide(
        color: activity.category.color.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
      ),
      onPressed: () {
        Navigator.of(context).push(
          AppPageRoute(
            builder: (context) => ActivityDetailPage(
              activityName: activity.activityName,
            ),
          ),
        );
      },
    );
  }
}
