import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:day_tracker/features/weekly_review/domain/providers/weekly_review_providers.dart';
import 'package:day_tracker/features/weekly_review/presentation/widgets/context_highlights_widget.dart';
import 'package:day_tracker/features/weekly_review/presentation/widgets/emotion_summary_widget.dart';
import 'package:day_tracker/features/weekly_review/presentation/widgets/perma_averages_widget.dart';
import 'package:day_tracker/features/weekly_review/presentation/widgets/review_highlights_widget.dart';
import 'package:day_tracker/features/weekly_review/presentation/widgets/week_score_overview.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Full-screen scrollable weekly review with all sections.
class WeeklyReviewDetailPage extends ConsumerWidget {
  final WeeklyReviewData review;

  const WeeklyReviewDetailPage({super.key, required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    // Try to find the previous week's review for comparison
    final prevWeek = review.weekNumber > 1
        ? (year: review.year, week: review.weekNumber - 1)
        : (year: review.year - 1, week: 52);
    final previousReview = ref.watch(reviewForWeekProvider(prevWeek));

    final dateFormat = DateFormat('MMM d');
    final dateRange =
        '${dateFormat.format(review.weekStart)} – ${dateFormat.format(review.weekEnd)}';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.weekLabel(review.weekNumber)),
        centerTitle: true,
      ),
      body: PageGradientBackground(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 0,
                child: Padding(
                  padding: AppSpacing.paddingAllMd,
                  child: Column(
                    children: [
                      Text(
                        l10n.weekLabel(review.weekNumber),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      AppSpacing.verticalXxs,
                      Text(
                        dateRange,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.verticalSm,
                      // Overall score badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 20)),
                            AppSpacing.horizontalXs,
                            Text(
                              review.averageScore.toStringAsFixed(1),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            AppSpacing.horizontalXs,
                            Text(
                              l10n.weeklyAverage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Week score overview
            SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 1,
                child: WeekScoreOverview(review: review),
              ),
            ),
            SliverToBoxAdapter(child: AppSpacing.verticalSm),

            // PERMA+ averages
            SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 2,
                child: PermaAveragesWidget(review: review),
              ),
            ),
            SliverToBoxAdapter(child: AppSpacing.verticalSm),

            // Emotion summary
            SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 3,
                child: EmotionSummaryWidget(review: review),
              ),
            ),
            SliverToBoxAdapter(child: AppSpacing.verticalSm),

            // Context highlights
            SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 4,
                child: ContextHighlightsWidget(review: review),
              ),
            ),
            SliverToBoxAdapter(child: AppSpacing.verticalSm),

            // Review highlights (streak, favorites, comparison)
            SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 5,
                child: ReviewHighlightsWidget(
                  review: review,
                  previousReview: previousReview,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
