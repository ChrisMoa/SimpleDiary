import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_page_state_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayRatingWidget extends ConsumerWidget {
  const DayRatingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratings = ref.watch(dayRatingsProvider);
    final isFullyScheduled = ref.watch(isDayFullyScheduledProvider);
    final theme = ref.watch(themeProvider);
    final selectedDate = ref.watch(wizardSelectedDateProvider);

    return Column(
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
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'How was your day? Rate the different aspects of your experience.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Rating cards - scrollable area
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              // Information card if day is not fully scheduled
              if (!isFullyScheduled)
                Card(
                  color: theme.colorScheme.errorContainer.withOpacity(0.7),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Day Schedule Incomplete',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your day schedule has gaps. For a complete diary entry, '
                          'schedule all your activities from morning to evening.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Switch to notes page
                            ref
                                .read(diaryWizardPageStateProvider.notifier)
                                .setNotesPage();
                          },
                          icon: const Icon(Icons.edit_calendar),
                          label: const Text('Complete Schedule'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.onErrorContainer
                                .withOpacity(0.2),
                            foregroundColor: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Rating cards for each type
              ...DayRatings.values.map((ratingType) {
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
                );
              }),

              // Save button - fixed at bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton.icon(
                  onPressed: isFullyScheduled
                      ? () => _saveDiaryDay(context, ref, selectedDate)
                      : null,
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
      ],
    );
  }

  Widget _buildRatingCard(
    BuildContext context,
    ThemeData theme,
    DayRatings ratingType,
    DayRating rating,
    Function(double) onRatingUpdate,
  ) {
    final IconData headerIcon = _getRatingTypeIcon(ratingType);
    final String description = _getRatingTypeDescription(ratingType);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Icon(
                  headerIcon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _capitalizeFirstLetter(ratingType.name),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 16),

            // Rating bar
            Center(
              child: RatingBar.builder(
                initialRating: rating.score > 0 ? rating.score.toDouble() : 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return const Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      );
                    case 1:
                      return const Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.redAccent,
                      );
                    case 2:
                      return const Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                    case 3:
                      return const Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      );
                    case 4:
                      return const Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                    default:
                      return const Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                  }
                },
                onRatingUpdate: onRatingUpdate,
              ),
            ),

            const SizedBox(height: 8),

            // Rating label
            Center(
              child: Text(
                _getRatingLabel(rating.score),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _getRatingColor(rating.score),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
      default:
        return Icons.star;
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
      default:
        return 'Rate this aspect of your day';
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

  Color _getRatingColor(int score) {
    switch (score) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.redAccent;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _saveDiaryDay(
      BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final ratings = ref.read(dayRatingsProvider);
    final allNotes = ref.read(wizardDayNotesProvider);

    // Filter out dummy notes (empty title and description)
    final validNotes = allNotes
        .where((note) => note.title.isNotEmpty || note.description.isNotEmpty)
        .toList();

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
      const SnackBar(
        content: Text('Day rating saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Reset ratings for next day
    ref.read(dayRatingsProvider.notifier).resetRatings();

    // Navigate back if needed
    Navigator.of(context).pop();
  }
}
