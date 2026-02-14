import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayRatingWidget extends ConsumerWidget {
  const DayRatingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratings = ref.watch(dayRatingsProvider);
    final theme = ref.watch(themeProvider);
    final selectedDate = ref.watch(wizardSelectedDateProvider);

    // Get screen dimensions for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Create a scrollable layout that adapts to different screen sizes
    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with day info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day Rating',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'How was your day? Rate the different aspects of your experience.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Rating cards - scrollable area
          Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Use different layouts based on orientation and screen size
                    if (isLandscape && !isSmallScreen)
                      // For landscape larger screens, use a grid layout
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
                      // For portrait or small screens, use a column layout
                      Column(
                        children: _buildRatingCards(
                          context,
                          theme,
                          ratings,
                          ref,
                          isSmallScreen: isSmallScreen,
                        ),
                      ),

                    // Save button - fixed at bottom
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _saveDiaryDay(context, ref, selectedDate),
                        icon: const Icon(Icons.save),
                        label: const Text('Save Day Rating'),
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
          ref.read(dayRatingsProvider.notifier).updateRating(
                ratingType,
                score.toInt(),
              );
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
    final IconData headerIcon = _getRatingTypeIcon(ratingType);
    final String description = _getRatingTypeDescription(ratingType);

    // Adaptive padding and spacing based on screen size
    final double cardPadding = isSmallScreen ? 12.0 : 16.0;
    final double spacingSmall = isSmallScreen ? 4.0 : 8.0;
    final double spacingMedium = isSmallScreen ? 8.0 : 16.0;

    // Adaptive text sizes
    final double titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final double descriptionFontSize = isSmallScreen ? 12.0 : 14.0;
    final double ratingLabelFontSize = isSmallScreen ? 12.0 : 14.0;

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      color: theme.colorScheme.secondaryContainer,
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
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
                // Header with icon
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

                // Description - only show if there's enough space
                if (!isSmallScreen || MediaQuery.of(context).size.height > 500)
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                      fontSize: descriptionFontSize,
                    ),
                    maxLines: isSmallScreen ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                SizedBox(height: spacingMedium),

                // Rating bar - adapt size based on screen
                Center(
                  child: RatingBar.builder(
                    initialRating: rating.score > 0 ? rating.score.toDouble() : 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: isSmallScreen ? 24 : 32,
                    itemBuilder: (context, index) {
                      // Use theme colors for rating icons
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
                            color: iconColor,
                          );
                        case 1:
                          return Icon(
                            Icons.sentiment_dissatisfied,
                            color: iconColor,
                          );
                        case 2:
                          return Icon(
                            Icons.sentiment_neutral,
                            color: iconColor,
                          );
                        case 3:
                          return Icon(
                            Icons.sentiment_satisfied,
                            color: iconColor,
                          );
                        case 4:
                          return Icon(
                            Icons.sentiment_very_satisfied,
                            color: iconColor,
                          );
                        default:
                          return Icon(
                            Icons.sentiment_neutral,
                            color: iconColor,
                          );
                      }
                    },
                    onRatingUpdate: onRatingUpdate,
                  ),
                ),

                SizedBox(height: spacingSmall),

                // Rating label
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

  String _getRatingTypeDescription(DayRatings ratingType) {
    switch (ratingType) {
      case DayRatings.social:
        return 'How were your social interactions and relationships today?';
      case DayRatings.productivity:
        return 'How productive were you in your work or daily tasks?';
      case DayRatings.sport:
        return 'How was your physical activity and exercise today?';
      case DayRatings.food:
        return 'How healthy and satisfying was your diet today?';
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

  void _saveDiaryDay(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final ratings = ref.read(dayRatingsProvider);
    final allNotes = ref.read(wizardDayNotesProvider);
    final theme = ref.read(themeProvider);

    // Filter out dummy notes (empty title and description)
    final validNotes = allNotes.where((note) => note.title.isNotEmpty || note.description.isNotEmpty).toList();

    // Create DiaryDay
    final diaryDay = DiaryDay(
      day: selectedDate,
      ratings: ratings,
    );

    // Assign the valid notes to the diary day
    diaryDay.notes = validNotes;

    // Save to database
    ref.read(diaryDayLocalDbDataProvider.notifier).addElement(diaryDay);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Day rating saved successfully!',
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Reset ratings for next day
    ref.read(dayRatingsProvider.notifier).resetRatings();
  }
}
