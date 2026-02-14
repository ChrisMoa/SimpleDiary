import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/domain/providers/insights_provider.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/insight_card.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section displaying insights and achievements
class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return insightsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.errorLoadingInsights(error.toString())),
      ),
      data: (insights) {
        if (insights.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.insightsAndAchievements,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            ...insights.map((insight) {
              final localized = _localizeInsight(insight, l10n);
              return InsightCard(insight: localized);
            }),
          ],
        );
      },
    );
  }

  /// Resolve localized title and description based on InsightType
  Insight _localizeInsight(Insight insight, AppLocalizations l10n) {
    switch (insight.type) {
      case InsightType.milestone:
        return insight.copyWith(
          title: insight.title,
          description: l10n.milestoneReached,
        );
      case InsightType.achievement:
        return insight.copyWith(
          title: l10n.perfectWeek,
          description: l10n.perfectWeekDescription,
        );
      case InsightType.suggestion:
        return insight.copyWith(
          title: l10n.notRecordedToday,
          description: l10n.rememberToRate,
        );
      case InsightType.improvement:
        return insight.copyWith(
          title: l10n.bestCategory,
          description: l10n.bestCategoryDescription(
            insight.metadata?['category'] as String? ?? '',
          ),
        );
      case InsightType.warning:
        return insight;
    }
  }
}
