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
    final isFullyScheduled = ref.watch(isDayFullyScheduledProvider);
    final theme = ref.watch(themeProvider);

    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day Rating',
              style: theme.textTheme.titleLarge!.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Rating items
            ...DayRatings.values.map((ratingType) {
              final rating = ratings.firstWhere(
                (r) => r.dayRating == ratingType,
                orElse: () => DayRating(dayRating: ratingType),
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        ratingType.name,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: RatingBar.builder(
                        initialRating:
                            rating.score > 0 ? rating.score.toDouble() : 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 28,
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
                        onRatingUpdate: (score) {
                          ref.read(dayRatingsProvider.notifier).updateRating(
                                ratingType,
                                score.toInt(),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Save button with validation
            Center(
              child: ElevatedButton.icon(
                onPressed:
                    isFullyScheduled ? () => _saveDiaryDay(context, ref) : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Day Rating'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            // Warning if not fully scheduled
            if (!isFullyScheduled)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please fill your entire day schedule before saving',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveDiaryDay(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(wizardSelectedDateProvider);
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
        content: Text('Day rating saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    // Reset ratings for next day
    ref.read(dayRatingsProvider.notifier).resetRatings();
  }
}
