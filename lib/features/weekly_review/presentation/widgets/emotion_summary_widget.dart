import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/weekly_review/data/models/weekly_review_data.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

/// Shows top emotions logged during the week with frequency counts.
class EmotionSummaryWidget extends StatelessWidget {
  final WeeklyReviewData review;

  const EmotionSummaryWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final emotions = review.topEmotions;

    if (emotions.isEmpty) return const SizedBox.shrink();

    return AppCard.elevated(
      margin: AppSpacing.paddingHorizontalMd,
      padding: AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.topEmotions,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalMd,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: emotions.map((e) {
              final emotion = e['emotion'] as String? ?? '';
              final count = e['count'] as int? ?? 0;
              return _buildEmotionChip(context, emotion, count, theme);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChip(
    BuildContext context,
    String emotion,
    int count,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final isPositive = _isPositiveEmotion(emotion);
    final chipColor = isPositive
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;
    final textColor = isPositive
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _emotionEmoji(emotion),
            style: const TextStyle(fontSize: 16),
          ),
          AppSpacing.horizontalXxs,
          Text(
            _capitalize(emotion),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.horizontalXxs,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isPositiveEmotion(String emotion) {
    const positive = {
      'joy', 'gratitude', 'serenity', 'interest', 'hope',
      'pride', 'amusement', 'inspiration', 'awe', 'love',
    };
    return positive.contains(emotion);
  }

  String _emotionEmoji(String emotion) {
    const emojis = {
      'joy': '😊', 'gratitude': '🙏', 'serenity': '😌',
      'interest': '🤔', 'hope': '🌟', 'pride': '💪',
      'amusement': '😄', 'inspiration': '✨', 'awe': '🤩',
      'love': '❤️', 'sadness': '😢', 'anger': '😠',
      'fear': '😨', 'disgust': '😖', 'shame': '😳',
      'guilt': '😔', 'frustration': '😤', 'loneliness': '🥺',
      'anxiety': '😰', 'neutral': '😐', 'surprised': '😲',
    };
    return emojis[emotion] ?? '🔹';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
