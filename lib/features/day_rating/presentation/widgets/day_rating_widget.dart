import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/day_rating/domain/providers/rating_preferences_provider.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/context_factors_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/emotion_wheel_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/mood_map_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/wellbeing_dimensions_widget.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayRatingWidget extends ConsumerWidget {
  const DayRatingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(ratingPreferencesProvider);
    final theme = ref.watch(themeProvider);

    return AppCard.elevated(
      margin: AppSpacing.paddingAllXs,
      color: theme.colorScheme.secondaryContainer,
      borderRadius: AppRadius.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme, ref, prefs.useLegacyMode),
          AppSpacing.verticalXs,
          Expanded(
            child: prefs.useLegacyMode
                ? _LegacyRatingBody(theme: theme)
                : _EnhancedRatingBody(theme: theme, prefs: prefs),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    bool isLegacy,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.dayRating,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isLegacy
                      ? AppLocalizations.of(context)!.howWasYourDay
                      : 'Rate your wellbeing across key dimensions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // Toggle between legacy and enhanced
          Tooltip(
            message: isLegacy ? 'Switch to Enhanced Mode' : 'Switch to Simple Mode',
            child: IconButton(
              icon: Icon(
                isLegacy ? Icons.science_outlined : Icons.star_outline,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => ref
                  .read(ratingPreferencesProvider.notifier)
                  .setUseLegacyMode(!isLegacy),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legacy 4-category rating body ─────────────────────────────────────────

class _LegacyRatingBody extends ConsumerWidget {
  final ThemeData theme;

  const _LegacyRatingBody({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratings = ref.watch(dayRatingsProvider);
    final selectedDate = ref.watch(wizardSelectedDateProvider);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLandscape && !isSmallScreen)
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildRatingCards(
                context,
                theme,
                ratings,
                ref,
                isSmallScreen: false,
              ),
            )
          else
            Column(
              children: _buildRatingCards(
                context,
                theme,
                ratings,
                ref,
                isSmallScreen: isSmallScreen,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ElevatedButton.icon(
              onPressed: () =>
                  _saveLegacyDay(context, ref, selectedDate, ratings),
              icon: const Icon(Icons.save),
              label: Text(AppLocalizations.of(context)!.saveDayRating),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                minimumSize: const Size(double.infinity, 54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRatingCards(
    BuildContext context,
    ThemeData theme,
    List<DayRating> ratings,
    WidgetRef ref, {
    required bool isSmallScreen,
  }) {
    return DayRatings.values.map((ratingType) {
      final rating = ratings.firstWhere(
        (r) => r.dayRating == ratingType,
        orElse: () => DayRating(dayRating: ratingType),
      );

      return _buildRatingCard(
        context,
        theme,
        ratingType,
        rating,
        (score) {
          ref
              .read(dayRatingsProvider.notifier)
              .updateRating(ratingType, score.toInt());
        },
        isSmallScreen: isSmallScreen,
      );
    }).toList();
  }

  Widget _buildRatingCard(
    BuildContext context,
    ThemeData theme,
    DayRatings ratingType,
    DayRating rating,
    Function(double) onRatingUpdate, {
    required bool isSmallScreen,
  }) {
    final headerIcon = _getRatingTypeIcon(ratingType);
    final description = _getRatingTypeDescription(context, ratingType);

    final cardPadding = isSmallScreen ? 12.0 : 16.0;
    final spacingSmall = isSmallScreen ? 4.0 : 8.0;
    final spacingMedium = isSmallScreen ? 8.0 : 16.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final descriptionFontSize = isSmallScreen ? 12.0 : 14.0;
    final ratingLabelFontSize = isSmallScreen ? 12.0 : 14.0;

    return AppCard.outlined(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      color: theme.colorScheme.secondaryContainer,
      borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
      borderRadius: AppRadius.borderRadiusMd,
      padding: EdgeInsets.all(cardPadding),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: isSmallScreen ? 120 : 150,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    headerIcon,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: spacingSmall),
                  Expanded(
                    child: Text(
                      _capitalizeFirstLetter(ratingType.name),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacingSmall),
              if (!isSmallScreen || MediaQuery.of(context).size.height > 500)
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer
                        .withValues(alpha: 0.8),
                    fontSize: descriptionFontSize,
                  ),
                  maxLines: isSmallScreen ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: spacingMedium),
              Center(
                child: RatingBar.builder(
                  initialRating:
                      rating.score > 0 ? rating.score.toDouble() : 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: isSmallScreen ? 24 : 32,
                  itemBuilder: (context, index) {
                    Color iconColor;
                    switch (index) {
                      case 0:
                        iconColor = Colors.red;
                        break;
                      case 1:
                        iconColor = Colors.red.shade400;
                        break;
                      case 2:
                        iconColor = Colors.yellow.shade700;
                        break;
                      case 3:
                        iconColor = Colors.lightGreen;
                        break;
                      case 4:
                        iconColor = Colors.green;
                        break;
                      default:
                        iconColor = Colors.yellow.shade700;
                    }
                    switch (index) {
                      case 0:
                        return Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: iconColor);
                      case 1:
                        return Icon(
                            Icons.sentiment_dissatisfied, color: iconColor);
                      case 2:
                        return Icon(Icons.sentiment_neutral, color: iconColor);
                      case 3:
                        return Icon(
                            Icons.sentiment_satisfied, color: iconColor);
                      case 4:
                        return Icon(
                            Icons.sentiment_very_satisfied, color: iconColor);
                      default:
                        return Icon(Icons.sentiment_neutral, color: iconColor);
                    }
                  },
                  onRatingUpdate: onRatingUpdate,
                ),
              ),
              SizedBox(height: spacingSmall),
              Center(
                child: Text(
                  _getRatingLabel(rating.score),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _getRatingColor(rating.score, theme),
                    fontWeight: FontWeight.bold,
                    fontSize: ratingLabelFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  IconData _getRatingTypeIcon(DayRatings ratingType) {
    switch (ratingType) {
      case DayRatings.social:
        return Icons.people;
      case DayRatings.productivity:
        return Icons.work;
      case DayRatings.sport:
        return Icons.fitness_center;
      case DayRatings.food:
        return Icons.restaurant;
    }
  }

  String _getRatingTypeDescription(BuildContext context, DayRatings ratingType) {
    final l10n = AppLocalizations.of(context)!;
    switch (ratingType) {
      case DayRatings.social:
        return l10n.ratingSocialDescription;
      case DayRatings.productivity:
        return l10n.ratingProductivityDescription;
      case DayRatings.sport:
        return l10n.ratingSportDescription;
      case DayRatings.food:
        return l10n.ratingFoodDescription;
    }
  }

  String _getRatingLabel(int score) {
    switch (score) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent';
      default:
        return 'Not Rated';
    }
  }

  Color _getRatingColor(int score, ThemeData theme) {
    switch (score) {
      case 1:
        return theme.colorScheme.error;
      case 2:
        return theme.colorScheme.error.withValues(alpha: .7);
      case 3:
        return theme.colorScheme.tertiary;
      case 4:
        return theme.colorScheme.tertiary.withValues(alpha: .7);
      case 5:
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  void _saveLegacyDay(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    List<DayRating> ratings,
  ) {
    final allNotes = ref.read(wizardDayNotesProvider);
    final validNotes = allNotes
        .where((n) => n.title.isNotEmpty || n.description.isNotEmpty)
        .toList();

    final diaryDay = DiaryDay(
      day: selectedDate,
      ratings: ratings,
    );
    diaryDay.notes = validNotes;

    ref.read(diaryDayLocalDbDataProvider.notifier).addElement(diaryDay);
    AppSnackBar.success(context, message: 'Day rating saved successfully!');
    ref.read(dayRatingsProvider.notifier).resetRatings();
  }
}

// ── Enhanced PERMA+ rating body ────────────────────────────────────────────

class _EnhancedRatingBody extends ConsumerWidget {
  final ThemeData theme;
  final dynamic prefs;

  const _EnhancedRatingBody({required this.theme, required this.prefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enhanced = ref.watch(enhancedDayRatingProvider);
    final selectedDate = ref.watch(wizardSelectedDateProvider);
    final notifier = ref.read(enhancedDayRatingProvider.notifier);

    return SingleChildScrollView(
      padding: AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tier 1: Quick Mood Map
          if (prefs.showQuickMood) ...[
            AppCard.outlined(
              padding: AppSpacing.paddingAllMd,
              color: theme.colorScheme.surface,
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: AppRadius.borderRadiusMd,
              child: MoodMapWidget(
                initialPosition: enhanced.quickMood,
                onPositionChanged: notifier.updateQuickMood,
              ),
            ),
            AppSpacing.verticalMd,
          ],

          // Tier 2: Wellbeing Dimensions
          AppCard.outlined(
            padding: AppSpacing.paddingAllMd,
            color: theme.colorScheme.surface,
            borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: AppRadius.borderRadiusMd,
            child: WellbeingDimensionsWidget(
              rating: enhanced.wellbeing,
              enabledDimensions: prefs.enabledDimensions,
              onChanged: notifier.updateWellbeing,
            ),
          ),

          // Tier 3: Emotion Wheel (optional)
          if (prefs.showEmotionWheel) ...[
            AppSpacing.verticalMd,
            AppCard.outlined(
              padding: AppSpacing.paddingAllMd,
              color: theme.colorScheme.surface,
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: AppRadius.borderRadiusMd,
              child: EmotionWheelWidget(
                selectedEmotions: enhanced.emotions,
                onChanged: notifier.updateEmotions,
              ),
            ),
          ],

          // Tier 4: Context Factors (optional)
          if (prefs.showContextFactors) ...[
            AppSpacing.verticalMd,
            AppCard.outlined(
              padding: AppSpacing.paddingAllMd,
              color: theme.colorScheme.surface,
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: AppRadius.borderRadiusMd,
              child: ContextFactorsWidget(
                factors: enhanced.context,
                onChanged: notifier.updateContext,
              ),
            ),
          ],

          AppSpacing.verticalXl,

          // Save button
          ElevatedButton.icon(
            onPressed: () =>
                _saveEnhancedDay(context, ref, selectedDate, enhanced),
            icon: const Icon(Icons.save),
            label: Text(AppLocalizations.of(context)!.saveDayRating),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              minimumSize: const Size(double.infinity, 54),
            ),
          ),

          AppSpacing.verticalSm,
        ],
      ),
    );
  }

  void _saveEnhancedDay(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    EnhancedDayRating enhanced,
  ) {
    final allNotes = ref.read(wizardDayNotesProvider);
    final validNotes = allNotes
        .where((n) => n.title.isNotEmpty || n.description.isNotEmpty)
        .toList();

    // Also build legacy ratings from wellbeing so existing dashboard code works.
    // social → connection, productivity → achievement, sport → energy, food → (mood)
    final legacyRatings = [
      DayRating(
          dayRating: DayRatings.social,
          score: enhanced.wellbeing.connection.clamp(1, 5)),
      DayRating(
          dayRating: DayRatings.productivity,
          score: enhanced.wellbeing.achievement.clamp(1, 5)),
      DayRating(
          dayRating: DayRatings.sport,
          score: enhanced.wellbeing.energy.clamp(1, 5)),
      DayRating(
          dayRating: DayRatings.food,
          score: enhanced.wellbeing.mood.clamp(1, 5)),
    ];

    final diaryDay = DiaryDay(
      day: selectedDate,
      ratings: legacyRatings,
      enhancedRating: enhanced,
    );
    diaryDay.notes = validNotes;

    ref.read(diaryDayLocalDbDataProvider.notifier).addElement(diaryDay);
    AppSnackBar.success(context, message: 'Day rating saved successfully!');
    ref.read(enhancedDayRatingProvider.notifier).reset(selectedDate);
  }
}
