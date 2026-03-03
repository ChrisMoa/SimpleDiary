import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:day_tracker/features/weekly_review/domain/providers/weekly_review_providers.dart';
import 'package:day_tracker/features/weekly_review/presentation/pages/weekly_review_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Page listing all persisted weekly reviews, with the option to generate new ones.
class WeeklyReviewListPage extends ConsumerWidget {
  const WeeklyReviewListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reviews = ref.watch(allWeeklyReviewsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: PageGradientBackground(
        child: reviews.isEmpty
            ? _buildEmptyState(context, theme, l10n)
            : _buildReviewList(context, ref, reviews, theme, l10n),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateCurrentWeekReview(context, ref, l10n),
        icon: const Icon(Icons.auto_awesome),
        label: Text(l10n.generateReview),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            AppSpacing.verticalLg,
            Text(
              l10n.weeklyReview,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalSm,
            Text(
              l10n.noReviewsYet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList(
    BuildContext context,
    WidgetRef ref,
    List<WeeklyReviewData> reviews,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      padding: AppSpacing.paddingAllMd,
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return AnimatedListItem(
          index: index,
          child: _buildReviewCard(context, review, theme, l10n),
        );
      },
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    WeeklyReviewData review,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM d');
    final dateRange =
        '${dateFormat.format(review.weekStart)} – ${dateFormat.format(review.weekEnd)}';

    return AppCard.elevated(
      margin: AppSpacing.paddingVerticalXs,
      padding: AppSpacing.paddingAllMd,
      onTap: () {
        Navigator.of(context).push(
          AppPageRoute(
            builder: (context) => WeeklyReviewDetailPage(review: review),
          ),
        );
      },
      child: Row(
        children: [
          // Week number badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Center(
              child: Text(
                '${review.weekNumber}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          AppSpacing.horizontalMd,

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weekLabel(review.weekNumber),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalXxs,
                Text(
                  dateRange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Score and days
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 14)),
                  AppSpacing.horizontalXxs,
                  Text(
                    review.averageScore.toStringAsFixed(1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalXxs,
              Text(
                l10n.completedDaysCount(review.completedDays),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          AppSpacing.horizontalXs,
          Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Future<void> _generateCurrentWeekReview(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final now = DateTime.now();
    final weekNumber = WeeklyReviewData.isoWeekNumber(now);
    final year = now.year;
    final params = (year: year, week: weekNumber);

    // Check if already exists
    final existing = ref.read(hasReviewForWeekProvider(params));
    if (existing) {
      final review = ref.read(reviewForWeekProvider(params));
      if (review != null && context.mounted) {
        Navigator.of(context).push(
          AppPageRoute(
            builder: (context) => WeeklyReviewDetailPage(review: review),
          ),
        );
      }
      return;
    }

    try {
      final review =
          await ref.read(generateWeeklyReviewProvider(params).future);
      if (context.mounted) {
        AppSnackBar.success(
          context,
          message: l10n.reviewGeneratedFor(review.weekLabel),
        );
        Navigator.of(context).push(
          AppPageRoute(
            builder: (context) => WeeklyReviewDetailPage(review: review),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, message: e.toString());
      }
    }
  }
}
